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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		darkoverlordofdata
# @author		darkoverlordofdata
# @copyright	Copyright (c) 2012, Dark Overlord of Data
# @license		MIT License
# @link		http://darkoverlordofdata.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Exspresso Config Class
#
# This class contains functions that enable config files to be managed
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Libraries
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/config.html
#


class global.Base_Config


  config:         {}
  is_loaded:      []
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
    @config = get_config()

    #  Set the base_url automatically if none was provided

    log_message('debug', "Config Class Initialized")


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

    for $path in @_config_paths

      $config = {}
      $found = false
      $check_locations = [$file, ENVIRONMENT + '/' + $file]
      for $location in $check_locations

        $file_path = $path + 'config/' + $location + EXT

        if file_exists($file_path)
          $found = true
          $config = array_merge($config, require($file_path))


      if not $found
        if $fail_gracefully is true
          return false

        show_error('Your %s file does not appear to contain a valid configuration array.', $file_path)


      if $use_sections is true
        if @config[$file]?
          @config[$file] = array_merge(@config[$file], $config)

        else
          @config[$file] = $config


      else
        @config = array_merge(@config, $config)


      @is_loaded.push $file_path

      $loaded = true


    if $loaded is false
      if $fail_gracefully is true
        return false

      show_error('The configuration file %s does not exist.', $file+EXT)


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
      if not @config[$item]?
        return '' #false


      $pref = @config[$item]

    else
      if not @config[$index]?
        return '' #false


      if not @config[$index][$item]?
        return '' #false


      $pref = @config[$index][$item]


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
    if not @config[$item]?
      return false

    return rtrim(@config[$item], '/') + '/'


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
    @config[$item] = $value


  #  --------------------------------------------------------------------

  #
  # Assign to Config
  #
  # This function is called by the front controller (Exspresso.php)
  # after the Config class is instantiated.  It permits config items
  # to be assigned or overriden by variables contained in the index.php file
  #
  # @access	private
  # @param	array
  # @return	void
  #
  _assign_toconfig : ($items = {}) ->
    for $val, $key of $items
      @set_item($key, $val)


# END Base_Config class
module.exports = Base_Config

# End of file Config.coffee
# Location: ./system/core/Base/Config.coffee