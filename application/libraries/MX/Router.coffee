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

  _module: {}

  # --------------------------------------------------------------------

  #
  #  Load Routes
  #
  #   load routes from module/config/routes
  #   bind each route to the associated cntroller/method
  #   append everything to the existing routes table
  #
  # @access	private
  # @return	object table of route bindings
  #


  fetch_module: ->
    @_module

  _validate_request: ($segments) ->

    if (count($segments) is 0) then return $segments

    # locate module controller
    if ($located = @locate($segments)) then return $located

    # use a default 404_override controller 
    if @_404_override
      $segments = explode('/', @_404_override)
      if ($located = @locate($segments)) then return $located
    
  
    # no controller found
    show_404()
  

  # Locate the controller 
  locate: ($segments) ->

    @_module = ''
    @_directory = ''
    $ext = @config.item('controller_suffix')+EXT

    # use module route if available
    if $segments[0]? and $routes = Modules.parse_routes($segments[0], implode('/', $segments))
      $segments = $routes

    # get the segments array elements
    [$module, $directory, $controller] = array_pad($segments, 3, null)

    # check modules
    for $location, $offset of Modules.locations

      # module exists?
      if (is_dir($source = $location+$module+'/controllers/'))

        @_module = $module
        @_directory = $offset.$module+'/controllers/'

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

  set_class: ($class) ->
    @_class = $class+@config.item('controller_suffix')

module.exports = MX_Router