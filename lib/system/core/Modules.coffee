#+--------------------------------------------------------------------+
#| Modules.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# This file was ported from Modular Extensions - HMVC to coffee-script using php2coffee
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright	Copyright (c) 2011 Wiredesignz
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
# Modules
#
# This file was ported from Wiredesignz to coffee-script using php2coffee
#
# Modular Extensions - HMVC
#
# Description:
# This library provides functions to load and instantiate controllers
# and module controllers allowing use of modules and the HMVC design pattern.
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

  #
  # Returns a list of modules
  #
  @list = ->

    $modules = []
    for $location, $offset of Modules.locations
      $modules.concat(readdirSync($location))
    $modules

  #
  # Load a module file
  #
  @loadFile = ($file, $path, $type = 'other', $result = true) ->

    $file = str_replace(EXT, '', $file)
    $location = $path+$file+EXT

    $result = require($location)
    log_message 'debug', "File loaded: %s", $location
    return $result

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

        if $base is 'lib/' and is_file($fullpath+ucfirst($file_ext))
          return [$fullpath, ucfirst($file)]

    # is the file in an application directory?
    if $base is 'views/' or $base is 'plugins/'
      if is_file(APPPATH+$base+$path+$file_ext) then return [APPPATH+$base+$path, $file]
      show_error "Unable to locate the file: %s", $path+$file_ext

    return [false, $file]

module.exports = Modules

# End of file Modules.coffee
# Location: ./core/Modules.coffee