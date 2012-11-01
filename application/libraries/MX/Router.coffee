#+--------------------------------------------------------------------+
#  Router.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#
#  load the MX core module class
Modules = require(dirname(__filename)+'/Modules.coffee')
fs = require('fs')

#
# Modular Extensions - HMVC
#
# Adapted from the CodeIgniter Core Classes
# @link	http://codeigniter.com
#
# Description:
# This library extends the CodeIgniter router class.
#
# Install this file as application/third_party/MX/Router.php
#
# @copyright	Copyright (c) 2011 Wiredesignz
# @version 	5.4
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE and NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

class global.MX_Router extends CI_Router

  _module: ''

  # --------------------------------------------------------------------

  #
  # Set the route mapping
  #
  # This function determines what should be served based on the URI request,
  # as well as any "routes" that have been set in the routing config file.
  #
  # @access	private
  # @return	void
  #
  _set_routing: ($uri) ->
    @_module = ''
    super $uri

  # --------------------------------------------------------------------

  #
  #  Load Routes
  #
  # This function loads routes that may exist in
  # the module/config/routes.php file
  #
  # @access	private
  # @return	object routes
  #
  _load_routes: ->

    $routes = super()

    for $location, $offset of Modules.locations
      $modules = fs.readdirSync($location)
      for $module in $modules
        $path = $location + $module + '/config/'

        if file_exists($path+'routes.coffee')
          $routes = array_merge($routes, Modules.load_file('routes', $path, 'route'))

          # set module view location:
          if is_dir($loc = $location + $module + '/views')
            Modules.views[$module] = $loc

    return $routes


  # --------------------------------------------------------------------

  #
  # Controller binding
  #
  #   Routing call back to invoke the controller when the request is received
  #
  #   @param object $class
  #   @param string method
  #   @return function
  #
  bind: ($path, $class, $method) ->
    if @fetch_module() is ''
      $views = ''
      $ext = ''
    else
      $views = Modules.views[@fetch_module()]+'/'
      $ext = '.'+@config.config['view_ext']

    @routes[$path] = do($class, $method, $views, $ext) ->
      # --------------------------------------------------------------------

      #
      # Invoke the contoller
      #
      #   Instantiates the controller and calls the requested method.
      #   Any URI segments present (besides the class/function) will be passed
      #   to the method for convenience
      #
      #   @param {Object} the server request object
      #   @param {Object} the server response object
      #   @param {Function} the next middleware on the stack
      #   @param {Array} the remaining arguments
      #
      return ($req, $res, $next, $args...) ->

        # a new copy of the controller class for each request:
        $CI = new $class()

        # --------------------------------------------------------------------

        #
        # Load View
        #
        #   Load & render the view with optional data
        #
        #   @param string path to view
        #   @param object data hash table of data
        #   @param function optional callback
        #   @return void
        #
        $CI.load.view = ($view, $data, $fn) ->
          # check if the view is in this module
          if $views and (file_exists($views+$view) or file_exists($views+$view+$ext))
            $res.render $views+$view, $data, $fn
          # otherwise use an application view
          else
            $res.render $view, $data, $fn
          return

        # --------------------------------------------------------------------

        #
        # Redirect
        #
        #   redirect to another url
        #
        #   @param string path to redirect
        #   @return void
        #
        $CI.redirect = ($path) ->
          $res.redirect $path
          return

        # was database added by the controller constructor?
        if $CI.db?
          # initialize the database connection
          $CI.db.initialize ->
            # now call the controller method
            $CI[$method].apply $CI, $args
        else
          # just call the controller method
          $CI[$method].apply $CI, $args

        return

  # --------------------------------------------------------------------

  #
  # Validates the supplied segments.  Attempts to determine the path to
  # the controller.
  #
  # @access	private
  # @param	array
  # @return	array
  #
  _validate_request: ($segments) ->

    if (count($segments) is 0) then return $segments

    # locate module controller
    #if ($located = @locate($segments)) then return $located
    $located = @locate($segments)
    if ($located) then return $located


    # use a default 404_override controller 
    if @_404_override
      $segments = explode('/', @_404_override)
      if ($located = @locate($segments)) then return $located
    
  
    # no controller found
    #show_404()
    # Nothing else to do at this point but show a 404
    log_message 'error', "Unable to validate uri %j", $segments
    return []


  # Locate the controller 
  locate: ($segments) ->

    @_module = ''
    @_directory = ''
    $ext = @config.item('controller_suffix')+EXT

    # use module route if available
    #if $segments[0]? and $routes = Modules.parse_routes($segments[0], implode('/', $segments))
      #$segments = $routes

    # get the segments array elements
    [$module, $directory, $controller] = array_pad($segments, 3, null)

    # check modules
    for $location, $offset of Modules.locations

      # module exists?
      if (is_dir($source = $location+$module+'/controllers/'))

        @_module = $module
        @_directory = $offset+$module+'/controllers/'

        # module sub-controller exists?
        if($directory and is_file($source+$directory+$ext))
          return array_slice($segments, 1)

        # module sub-directory exists?
        if($directory and is_dir($source+$directory+'/'))

          $source = $source+$directory+'/'
          @_directory += $directory+'/'

          # module sub-directory controller exists?
          if(is_file($source+$directory+$ext))
            return array_slice($segments, 1)


          # module sub-directory sub-controller exists?
          if($controller and is_file($source+$controller+$ext))
            return array_slice($segments, 2)

        # module controller exists?
        if(is_file($source+$module+$ext))
          return $segments

    # application controller exists?
    if (is_file(APPPATH+'controllers/'+$module+$ext))
      return $segments

    # application sub-directory controller exists?
    if($directory and is_file(APPPATH+'controllers/'+$module+'/'+$directory+$ext))
      @_directory = $module+'/'
      return array_slice($segments, 1)

    # application sub-directory default controller exists?
    if (is_file(APPPATH+'controllers/'+$module+'/'+@default_controller+$ext))
      @_directory = $module+'/'
      return array(@default_controller)

  # --------------------------------------------------------------------

  #
  # Set the class name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_class: ($class) ->
    @_class = $class+@config.item('controller_suffix')

  # --------------------------------------------------------------------

  #
  # Fetch the current module
  #
  # @access	public
  # @return	string
  #
  fetch_module: ->
    @_module


module.exports = MX_Router