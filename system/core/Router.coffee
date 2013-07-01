#+--------------------------------------------------------------------+
#  Router.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+

#
# Exspresso Router Class
#
module.exports = class system.core.Router

  fs = require('fs')

  #
  # @property [Object] Hash of bindings for each route
  #
  config                  : null          # config object
  routes                  : null          # route dispatch bindings
  _default_controller     : false         # matches route '/'
  _default_method         : 'indexAction' # when no method is supplied
  _path                   : ''            # mapped path
  _module                 : ''            # mapped module
  _class                  : ''            # mapped class
  _method                 : ''            # mapped method

  #
  # Initialize the router hash
  #
  constructor: ($controller) ->

    defineProperties @,
      config        : {enumerable: true,  writeable: false, value: $controller.config}
      routes        : {enumerable: true,  writeable: false, value: {}}

    log_message 'debug', "Router Class Initialized"


  #
  # Set the route mapping
  #
  # @param [String] uri the uri to parse
  # @return [Void]
  #
  setMapping: ($uri) ->

    @_path = ''
    @_module = ''
    @_class = ''
    @_method = ''

    if $uri is ''
      if @_default_controller is false
        return show_error("Default controller not specified")
      $uri = @_default_controller

    if ($segments = @map_uri($uri))
      $segments[1] = @_default_method unless $segments[1]?
      @setClass $segments[0]
      @setMethod $segments[1]
      true

    else
      log_message 'error', "Unable to validate uri %s", $uri
      false


  #
  # Set Route
  #
  # @param  [String]  route the route being set
  # @param  [Function]  function  function to execute when route matches
  # @return [Void]
  #
  setRoute: ($route, $function) ->
    @routes[$route] = $function

  #
  # Set the class name
  #
  # @param  [String]  class the class name
  # @return [Void]
  #
  setClass: ($class) ->
    @_class = $class+@config.item('controller_suffix')


  #
  # Get the current class
  #
  # @return	[String] the class name
  #
  getClass: ->
    return @_class


  #
  #  Set the method name
  #
  # @param  [String]  method  the method name
  # @return [Void]
  #
  setMethod: ($method) ->
    if /^\w*Action$/.test($method)
      @_method = $method
    else
      @_method = "#{$method}Action"


  #
  #  Get the current method
  #
  # @return	[String] the method name
  #
  getMethod: ->
    return @_default_method if @_method is @getClass()
    @_method || @_default_method

  #
  # Set the path
  #
  # @param  [String] path path to the controller class file
  # @return [Void]
  #
  setPath: ($path) ->
    @_path = $path.replace('/', '').replace('.', '') + '/'


  #
  # Get the path
  #
  # @return	[String] the controller class path
  #
  getPath: ->
    @_path

  #
  # Get the current module
  #
  # @return	[String] the module
  #
  getModule: ->
    @_module


  #
  # Load Routes
  #
  # Load routes from config/routes.coffee.
  # Go through all modules and addins to load
  # additional routing.
  #
  # @return [Object]  routes
  #
  loadRoutes: () ->

    if not @config.load('routes', true, true)
      show_error 'The config/routes file does not exist.'

    # start with the application routes
    $routes = @config.item('routes')

    # Set a default controller
    if $routes['default_controller']?
      @_default_controller = $routes['default_controller']
      delete $routes['default_controller']
      if @_default_controller.indexOf('/') is -1
        @parse_uri @_default_controller+'/'+@_default_method

      $routes['/'] = @_default_controller

    # add the module routes
    for $name, $module of @config.modules
      if fs.existsSync($file_path = $module.path+'/config/routes.coffee')
        $routes[$key] = $val for $key, $val of require($file_path)

    $routes

  #
  # Map the uri
  #
  # @param  [String]  uri the uri string
  # @return [Array] uri segments that specify the controller
  #
  map_uri: ($uri) ->

    $segments = $uri.split('/')
    @_module = ''
    @_path = ''
    $ext = @config.item('controller_suffix')+EXT

    if $segments.length < 3
      $segments = $segments.concat([null, null, null].slice(0, 3-$segments.length))
    [$module, $subdir, $controller] = $segments

    #
    # Search modules first
    #
    for $path in @config.item('module_paths')
      if is_dir($root = $path+$module+'/controllers/')
        return false unless @config.modules[$module].active

        #
        # Search in module for a controller match
        #
        @_module = $module
        @_path = $root

        #
        # .../controllers/subdir.coffee
        #
        return $segments.slice(1) if ($subdir and is_file($root+$subdir+$ext))
          
        #
        # .../controllers/subdir
        #
        if $subdir and is_dir($root+$subdir+'/')

          $root += $subdir+'/'
          @_path += $subdir+'/'

          #
          # .../controllers/subdir/subdir.coffee
          #
          return $segments.slice(1) if is_file($root+$subdir+$ext)

          #
          # .../controllers/subdir/controller.coffee
          #
          return $segments.slice(2) if($controller and is_file($root+$controller+$ext))

        #
        # .../controllers/module.coffee
        #
        return $segments if is_file($root+$module+$ext)

    #
    # .../controllers/module.coffee
    #
    if is_file(APPPATH+'controllers/'+$module+$ext)
      @_path = APPPATH+'controllers/'
      return $segments

    #
    # .../controllers/module/subdir.coffee
    #
    if($subdir and is_file(APPPATH+'controllers/'+$module+'/'+$subdir+$ext))
      @_path = APPPATH+'controllers/'+$module+'/'
      return $segments.slice(1)

    #
    # .../controllers/module/index.coffee
    #
    if (is_file(APPPATH+'controllers/'+$module+'/'+@default_controller+$ext))
      @_path = APPPATH+'controllers/'+$module+'/'
      return @default_controller.split('/')


