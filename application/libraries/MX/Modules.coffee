#+--------------------------------------------------------------------+
#| Modules.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
# Modules
#
#
# Modular Extensions - HMVC
#
# Adapted from the CodeIgniter Core Classes
# @link	http://codeigniter.com
#
# Description:
# This library provides functions to load and instantiate controllers
# and module controllers allowing use of modules and the HMVC design pattern.
#
# Install this file as application/third_party/MX/Modules.php
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
class global.Modules

  @locations = config_item('modules_locations') or array(APPPATH+'modules/', '../modules/')
  @routes = routes = {}
  @registry = registry = {}
  @views = {}

  ## --------------------------------------------------------------------

  #
  # Returns a list of modules
  #
  @list = list = ->

  ## --------------------------------------------------------------------

  #
  # Run a module controller method
  # Output from module is buffered and returned.
  #
  @run = ($module, $args...) ->

    $method = 'index'

    if ($pos = strrpos($module, '/')) isnt false
      $method = substr($module, $pos + 1)
      $module = substr($module, 0, $pos)


    if $class = load($module)

      if method_exists($class, $method)

        $class[$method].apply($class, $args)

  ## --------------------------------------------------------------------

  #
  # Load a module controller
  #
  @load = ($module) ->

    if is_array($module) then [$module, $params] = each($module) else $params = null

    # get the requested controller class name
    $alias = strtolower(end(explode('/', $module)))

    # return an existing controller from the registry
    if (isset($registry[$alias])) then return $registry[$alias]

    # get the module path
    $segments = explode('/', $module)

    # find the controller
    [$class] = get_instance().router.locate($segments)

    # controller cannot be located
    if not $class? then return

    # set the module directory
    $path = APPPATH+'controllers/'+get_instance().router.fetch_directory()

    # load the controller class
    $class = $class+get_instance().config.item('controller_suffix')
    load_file($class, $path)

    # create and register the new controller
    $controller = ucfirst($class)
    $registry[$alias] = new $controller($params)
    return $registry[$alias]


  ## --------------------------------------------------------------------

  #
  # Load a module file
  #
  @load_file = ($file, $path, $type = 'other', $result = true) ->

    $file = str_replace(EXT, '', $file)
    $location = $path+$file+EXT

    $result = require($location)
    log_message 'debug', "File loaded: #{$location}"
    return $result

  ## --------------------------------------------------------------------

  #
  # Find a file
  # Scans for files located within modules directories.
  # Also scans application directories for models, plugins and views.
  # Generates fatal error if file not found.
  #
  @find = ($file, $module, $base) ->

    $modules = {}

    $segments = explode('/', $file)

    $file = $segments.pop()

    if $base is 'views/'
      $file_ext = if strpos($file, '.') then $file else $file+config_item('view_ext')
    else
      $file_ext = if strpos($file, '.') then $file else $file+EXT

    $path = ltrim(implode('/', $segments)+'/', '/')
    if $module then $modules[$module] = $path else $modules = {}

    if $segments?
      $modules[array_shift($segments)] = ltrim(implode('/', $segments)+'/','/')


    for $location, $offset of @locations

      for $module, $subpath of $modules

        $fullpath = $location+$module+'/'+$base+$subpath

        if is_file($fullpath+$file_ext) then return [$fullpath, $file]

        if $base is 'libraries/' and is_file($fullpath+ucfirst($file_ext))
          return [$fullpath, ucfirst($file)]

    # is the file in an application directory?
    if $base is 'views/' or $base is 'plugins/'
      if is_file(APPPATH+$base+$path+$file_ext) then return [APPPATH+$base+$path, $file]
      show_error "Unable to locate the file: #{$path}#{$file_ext}"

    return [false, $file]

module.exports = Modules

# End of file Modules.coffee
# Location: ./application/libraries/MX/Modules.coffee