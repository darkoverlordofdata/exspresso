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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		  darkoverlordofdata
# @author		  darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright	Copyright (c) 2011 Wiredesignz
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		MIT License
# @link		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Config Class
#
# This class contains functions that enable config files to be managed
#
#

Modules = require(SYSPATH+'core/Modules.coffee')

class system.core.Config

  _is_loaded        : null  # array list of loaded config files
  paths             : null  # array list of paths to load config files at

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

    $config = get_config()  # Get the core config array

    defineProperties @,
      _is_loaded    : {enumerable: false, writeable: false, value: []}
      paths         : {enumerable: false, writeable: false, value: [APPPATH]}
      config        : {enumerable: true,  writeable: false, value: $config}

    log_message('debug', "Config Class Initialized")


  #
  # Load Config File
  #
  #   Checks in MODPATH first. If not found, there, look the APPPATH and package folders.
  #
  # @access	public
  # @param	string  the config file name
  # @param  boolean if configuration values should be loaded into their own section
  # @param  boolean true if errors should just return false, false if an error message should be displayed
  # @return	boolean	if the file was loaded correctly
  #
  load: ($file = 'config', $use_sections = false, $fail_gracefully = false, $module = '') ->

    if typeof $use_sections is 'string'
      [$use_sections, $fail_gracefully, $module] = [false, false, $use_sections]
    else if typeof $fail_gracefully is 'string'
      [$fail_gracefully, $module] = [false, $use_sections]

    if in_array($file, @_is_loaded, true) then return @item($file)

    [$path, $file] = Modules::find($file, $module, 'config/')
    if $path is false
      @_application_load($file, $use_sections, $fail_gracefully)
      return @item($file)
    if $config = Modules::load($file, $path)
      #  reference to the config array
      $current_config = @config
      if $use_sections is true
        if $current_config[$file]?
          $current_config[$file] = array_merge($current_config[$file], $config)
        else
          $current_config[$file] = array_merge($config, {})

      else
        $current_config[$key] = $val for $key, $val of $config
        @_is_loaded.push $file
        return @item($file)

  #
  # Load Application Config File
  #
  #   Looks in APPPATH. If not found, then look in packages (if any)
  #
  # @access	public
  # @param	string	the config file name
  # @param  boolean if configuration values should be loaded into their own section
  # @param  boolean true if errors should just return false, false if an error message should be displayed
  # @return	boolean	if the file was loaded correctly
  #
  _application_load : ($file = '', $use_sections = false, $fail_gracefully = false) ->
    $file = if $file is '' then 'config' else $file.replace(EXT, '')
    $loaded = false

    for $path in @paths

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
          @config[$file] = array_merge($config, {})

      else
        @config[$key] = $val for $key, $val of $config

      @_is_loaded.push $file_path
      $loaded = true

    if $loaded is false
      if $fail_gracefully is true
        return false

      show_error('The configuration file %s does not exist.', $file+EXT)

    return true


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

    $pref


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
  slashItem : ($item) ->
    if not @config[$item]?
      return false

    rtrim(@config[$item], '/') + '/'


  #
  # Site URL
  #
  # @access	public
  # @param	string	the URI string
  # @return	string
  #
  siteUrl : ($uri = '') ->

    if typeof $uri is 'string' and $uri is ''
      return @slashItem('base_url') + @item('index_page')

    if @item('enable_query_strings') is false
      if Array.isArray($uri)
        $uri = $uri.join('/')

      $index = if @item('index_page') is '' then '' else @slashItem('index_page')
      $suffix = if (@item('url_suffix') is false) then '' else @item('url_suffix')
      @slashItem('base_url') + $index + trim($uri, '/') + $suffix

    else
      if typeof $uri is 'object'
        $i = 0
        $str = ''
        for $val, $key of $uri
          $prefix = if ($i is 0) then '' else '&'
          $str+=$prefix + $key + '=' + $val
          $i++

        $uri = $str

      @slashItem('base_url') + @item('index_page') + '?' + $uri



  #
  # System URL
  #
  # @access	public
  # @return	string
  #
  systemUrl :  ->

    $x = SYSPATH.split("/")
    @slashItem('base_url') + $x[$x.length-1] + '/'


  #
  # Set a config file item
  #
  # @access	public
  # @param	string	the config item key
  # @param	string	the config item value
  # @return	void
  #
  setItem : ($item, $value) ->
    @config[$item] = $value


  #
  # Assign to Config
  #
  # This function is called by the front controller (exspresso.php)
  # after the Config class is instantiated.  It permits config items
  # to be assigned or overriden by variables contained in the index.php file
  #
  # @access	private
  # @param	array
  # @return	void
  #
  _assign_toconfig : ($items = {}) ->
    for $val, $key of $items
      @seItem($key, $val)
    return


# END Config class
module.exports = system.core.Config

# End of file Config.coffee
# Location: ./system/core/Config.coffee