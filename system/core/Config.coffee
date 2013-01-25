#+--------------------------------------------------------------------+
#  Config.coffee
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
# Description:
# This library extends the Exspresso_Config class
# and adds features allowing use of modules and the HMVC design pattern.
#

require BASEPATH+'core/Modules.coffee'
require BASEPATH+'core/Base/Config.coffee'

class global.Exspresso_Config extends Base_Config

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

    if in_array($file, @is_loaded, true) then return @item($file)
    $_module = Exspresso.router.fetch_module()
    [$path, $file] = Modules.find($file, $_module, 'config/')
    if $path is false
      super($file, $use_sections, $fail_gracefully)
      return @item($file)
    if $config = Modules.load_file($file, $path, 'config')
      #  reference to the config array
      $current_config = @config
      if $use_sections is true
        if $current_config[$file]?
          log_message 'debug', 'CONFIG 1'
          $current_config[$file] = array_merge($current_config[$file], $config)
        else
          log_message 'debug', 'CONFIG 2'
          $current_config[$file] = $config

      else
        log_message 'debug', 'CONFIG 3'
        $current_config = array_merge($current_config, $config)
        @is_loaded.push $file
        return @item($file)


module.exports = Exspresso_Config