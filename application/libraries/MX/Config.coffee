#+--------------------------------------------------------------------+
#  Config.coffee
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
#
# Modular Extensions - HMVC
#
# Adapted from the CodeIgniter Core Classes
# @link	http://codeigniter.com
#
# Description:
# This library extends the CodeIgniter CI_Config class
# and adds features allowing use of modules and the HMVC design pattern.
#
# Install this file as application/third_party/MX/Config.php
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
#*/

CI = require(dirname(__filename)+'/Ci.coffee')
Modules = require(dirname(__filename)+'/Modules.coffee')
require BASEPATH+'core/Config.coffee'


class global.MX_Config extends CI_Config

  #  --------------------------------------------------------------------

  #
  # Load Module Config File
  #
  # @access	public
  # @param	string	the config file name
  # @param   boolean  if configuration values should be loaded into their own section
  # @param   boolean  true if errors should just return false, false if an error message should be displayed
  # @return	boolean	if the file was loaded correctly
  #
  load: ($file = 'config',$use_sections = false, $fail_gracefully = false) ->

    log_message 'debug', 'MX_Config::load'
  
    if in_array($file, @is_loaded, true) then return @item($file)
    $_module = CI.$APP.router.fetch_module()
    [$path, $file] = Modules.find($file, $_module, 'config/')
    if $path is false
      super($file, $use_sections, $fail_gracefully)
      return @item($file)
    if $config = Modules.load_file($file, $path, 'config')
      #  reference to the config array
      $current_config = @config
      if $use_sections is true
        if $current_config[$file]?
          $current_config[$file] = array_merge($current_config[$file], $config)
        else
          $current_config[$file] = $config

      else
        $current_config = array_merge($current_config, $config)
        @is_loaded.push $file
        return @item($file)


module.exports = MX_Config