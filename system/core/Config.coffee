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

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, basename, defined, end, explode, file_exists, implode, in_array, is_array, item, preg_replace, rtrim, set_item, slash_item, str_replace, strtolower, trim}	= require(FCPATH + 'lib')
{Exspresso, config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class, show_error} = require(BASEPATH + 'core/Common')


#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter Config Class
#
# This class contains functions that enable config files to be managed
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Libraries
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/config.html
#


module.exports = class Exspresso.CI_Config


  _config:        {}
  _is_loaded:     {}
  _config_paths:  [APPPATH]

  #
  # Constructor
  #
  # Sets the $config data from the primary config.php file as a class variable
  #
  # @access   public
  # @param   string	the config file name
  # @param   boolean  if configuration values should be loaded into their own section
  # @param   boolean  true if errors should just return false, false if an error message should be displayed
  # @return  boolean  if the file was successfully loaded or not
  #
  constructor :  ->
    @_config = get_config()

    #  Set the base_url automatically if none was provided
    if @_config['base_url'] is ''
      ###
      if $_SERVER['HTTP_HOST']?
        $base_url = if $_SERVER['HTTPS']?  and strtolower($_SERVER['HTTPS']) isnt 'off' then 'https' else 'http'
        $base_url+='://' + $_SERVER['HTTP_HOST']
        $base_url+=str_replace(basename($_SERVER['SCRIPT_NAME']), '', $_SERVER['SCRIPT_NAME'])


      else
      ###
      $base_url = 'http://localhost/'

      @set_item 'base_url', $base_url

    @_initialize()
    log_message('debug', "Config Class Initialized")

  #
  # Initialize
  #
  # Initialize the Exspresso application config values
  #
  # @access   private
  # @return  void
  #
  _initialize: () ->

    express = require('express')                    # Express 3.0 Framework
    $app = require(BASEPATH + 'core/Exspresso').app

    $app.set 'env', ENVIRONMENT
    $app.set 'port', @_config.port
    $app.set 'site_name', @_config.site_name
    $app.use express.logger(@_config.logger)
    return


#  --------------------------------------------------------------------

  #
  # Load Config File
  #
  # @access	public
  # @param	string	the config file name
  # @param   boolean  if configuration values should be loaded into their own section
  # @param   boolean  true if errors should just return false, false if an error message should be displayed
  # @return	boolean	if the file was loaded correctly
  #
  load : ($file = '', $use_sections = false, $fail_gracefully = false) ->
    $file = if $file is '' then 'config' else $file.replace(EXT, '')
    $loaded = false

    for $path of @_config_paths

      $config = {}
      $found = false
      $check_locations = [$file, ENVIRONMENT + '/' + $file]
      for $location of $check_locations

        $file_path = $path + 'config/' + $location + EXT

        if file_exists($file_path)
          $config = array_merge($config, require($file_path))


      if not $found
        if $fail_gracefully is true
          return false

        show_error('Your ' + $file_path + ' file does not appear to contain a valid configuration array.')


      if $use_sections is true
        if @_config[$file]?
          @_config[$file] = array_merge(@_config[$file], $config)

        else
          @_config[$file] = $config


      else
        @_config = array_merge(@_config, $config)


      @_is_loaded.push $file_path

      $loaded = true
      log_message('debug', 'Config file loaded: ' + $file_path)


    if $loaded is false
      if $fail_gracefully is true
        return false

      show_error('The configuration file ' + $file + EXT + ' does not exist.')


    return true


  #  --------------------------------------------------------------------

  #
  # Fetch a config file item
  #
  #
  # @access	public
  # @param	string	the config item name
  # @param	string	the index name
  # @param	bool
  # @return	string
  #
  item : ($item, $index = '') ->
    if $index is ''
      if not @_config[$item]?
        return false


      $pref = @_config[$item]

    else
      if not @_config[$index]?
        return false


      if not @_config[$index][$item]?
        return false


      $pref = @_config[$index][$item]


    return $pref


  #  --------------------------------------------------------------------

  #
  # Fetch a config file item - adds slash after item
  #
  # The second parameter allows a slash to be added to the end of
  # the item, in the case of a path.
  #
  # @access	public
  # @param	string	the config item name
  # @param	bool
  # @return	string
  #
  slash_item : ($item) ->
    if not @_config[$item]?
      return false


    return rtrim(@_config[$item], '/') + '/'


  #  --------------------------------------------------------------------

  #
  # Site URL
  #
  # @access	public
  # @param	string	the URI string
  # @return	string
  #
  site_url : ($uri = '') ->

    if typeof $uri is 'string' and $uri is ''
      return @slash_item('base_url') + @item('index_page')


    if @item('enable_query_strings') is false
      if Array.isArray($uri)
        $uri = $uri.join('/')


      $index = if @item('index_page') is '' then '' else @slash_item('index_page')
      $suffix = if (@item('url_suffix') is false) then '' else @item('url_suffix')
      return @slash_item('base_url') + $index + trim($uri, '/') + $suffix

    else
      if typeof $uri is 'object'
        $i = 0
        $str = ''
        for $val, $key of $uri
          $prefix = if ($i is 0) then '' else '&'
          $str+=$prefix + $key + '=' + $val
          $i++


        $uri = $str


      return @slash_item('base_url') + @item('index_page') + '?' + $uri



  #  --------------------------------------------------------------------

  #
  # System URL
  #
  # @access	public
  # @return	string
  #
  system_url :  ->

    $x = BASEPATH.split("/")
    return @slash_item('base_url') + $x[$x.length-1] + '/'


  #  --------------------------------------------------------------------

  #
  # Set a config file item
  #
  # @access	public
  # @param	string	the config item key
  # @param	string	the config item value
  # @return	void
  #
  set_item : ($item, $value) ->
    @_config[$item] = $value


  #  --------------------------------------------------------------------

  #
  # Assign to Config
  #
  # This function is called by the front controller (CodeIgniter.php)
  # after the Config class is instantiated.  It permits config items
  # to be assigned or overriden by variables contained in the index.php file
  #
  # @access	private
  # @param	array
  # @return	void
  #
  _assign_to_config : ($items = {}) ->
    for $val, $key of $items
      @set_item($key, $val)


# END CI_Config class

# End of file Config.coffee
# Location: ./system/core/Config.coffee