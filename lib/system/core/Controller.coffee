#+--------------------------------------------------------------------+
#| Controller.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+

#
# Exspresso Application Controller Class
#
# This class object is the super class for all controllers
#
# @see http://coffeedoc.info/github/darkoverlordofdata/exspresso/master/Controller Graph
#
module.exports = class system.core.Controller extends system.core.Object

  #
  # @property [String] module name
  #
  module: ''
  #
  # @property [String] class name
  #
  class: ''
  #
  # @property [String] method name
  #
  method: ''
  #
  # @property [Object] http request object
  #
  req: null
  #
  # @property [Object] http response object
  #
  res: null
  #
  # @property [Object] benchmark object
  #
  bm: null
  #
  # @property [Object] config object
  #
  config: null
  #
  # @property [Object] hooks object
  #
  hooks: null
  #
  # @property [Object] input object
  #
  input: null
  #
  # @property [Object] i18n object
  #
  i18n: null
  #
  # @property [Object] output object
  #
  output: null
  #
  # @property [Object] security object
  #
  security: null
  #
  # @property [Object] server object
  #
  server: null
  #
  # @property [Object] uri object
  #
  uri: null


  #
  # Initialize Controller objects
  #
  # @param  [system.core.Server]  server Server object
  # @param  [system.core.Benchmark]  benchmark Benchmark object
  # @param  [system.core.Hooks]  hooks Hooks object
  # @param  [system.core.Config  config Config object
  # @param  [system.core.URI]  uri URI object
  # @param  [system.core.Output]  output Output object
  # @param  [system.core.Security]  security Security object
  # @param  [system.core.Input]  input Input object
  # @param  [system.core.I18n]  i18n I18n object
  # @param  [Object]  req Request object
  # @param  [Object]  res Response object
  # @param  [String]  module Module name
  # @param  [String]  class Class name
  # @param  [String]  method Method name
  # @return [Void]
  #
  constructor: ($server, $bench, $hooks, $config, $uri, $output, $security, $input, $i18n, $req, $res, $module, $class, $method) ->

    # Assign all the class objects that were instantiated by the
    # bootstrap file (exspresso.coffee) to local class variables
    # so that Exspresso can run as one big super object.
    @define
      # Singltons instantiated by the system controller
      config      : $config      # system.core.Config
      server      : $server      # system.core.Server

      # Unique instance per request
      bm          : $bench       # system.core.Benchmark
      hooks       : $hooks       # system.core.Hooks
      input       : $input       # system.core.Input
      i18n        : $i18n        # system.core.I18n
      output      : $output      # system.core.Output
      security    : $security    # system.core.Security
      uri         : $uri         # system.core.URI

      # connect objects
      req         : $req         # http Request object
      res         : $res         # http Response object

      # $uri segments
      module      : $module      # $uri module name
      class       : $class       # $uri class name
      method      : $method      # $uri method name

      # methods
      redirect    : @redirect    # redirect url
      render      : @render      # render view

      # bootstrap the loader object into the controller:
      load: load_core('Loader', @)

    for $prop in ['bm', 'hooks', 'input', 'i18n', 'output', 'security', 'uri']
      defineProperties @[$prop],
        controller: {enumerable: true,  writeable: false, value: @}

    log_message 'debug', "Controller Class Initialized"

    @load.initialize()  # do the autoloads


  #
  # Render a view
  #
  #
  # Use magic to make the controller context the
  # superclass of the data hash, allowing loaded
  # libraries to be referenced in a view:
  #
  # @example
  #
  #   <%- @pagination.createLinks() %>
  #
  #
  # @param  [String]  view path to the view template
  # @param  [Object]  data hash of data to render with template
  # @param  [Function]  next  callback
  # @return [Void]
  #
  render: ($view, $data = {}, $next) ->

    $data.$this = @ # some template engines, such as swig
                    # lose track of the context
    @res.render $view, magic(@, $data), ($err, $html) =>

      return $next($err, $html) if $next?
      return show_error($err) if $err
      @res.writeHead 200,
        'Content-Length'  : $html.length
        'Content-Type'    : 'text/html; charset=utf-8'
      @res.end $html

  #
  # Redirect to another url
  #
  # @param  [String]  url the url to redirect to
  # @return [Void]
  #
  redirect: ($url) ->

    @res.writeHead 302,
      'Location': $url
    @res.end null


