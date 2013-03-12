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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author		  darkoverlordofdata
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @copyright	Copyright (c) 2011 Wiredesignz
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see 		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#
# Exspresso Config Class
#
# This class contains functions that enable config files to be managed
#
#
class system.core.Config


  fs = require('fs')
  Modules = require(SYSPATH+'core/Modules.coffee')

  _is_loaded: null  #  array list of loaded config files

  #
  # @property [Object] array list of paths to load config files at
  #
  paths: null
  #
  # @property [Object] config data loaded from files
  #
  config: null

  #
  # Constructor
  #
  # Sets the config data from the primary config.coffee file as a class variable
  #
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
  # @param  [String]  file the config file name
  # @param  [Boolean] use_sections if configuration values should be loaded into their own section
  # @param  [Boolean] fail_gracefully  true if errors should just return false, false if an error message should be displayed
  # @param  [String]  module module name from the uri
  # @return	[Boolean]	if the file was loaded correctly
  #
  load: ($file = 'config', $use_sections = false, $fail_gracefully = false, $module = '') ->

    if typeof $use_sections is 'string'
      [$use_sections, $fail_gracefully, $module] = [false, false, $use_sections]
    else if typeof $fail_gracefully is 'string'
      [$fail_gracefully, $module] = [false, $use_sections]

    #if in_array($file, @_is_loaded, true) then return @item($file)
    return @item($file) unless @_is_loaded.indexOf($file) is -1

    [$path, $file] = Modules::find($file, $module, 'config/')
    if $path is false
      @_application_load($file, $use_sections, $fail_gracefully)
      return @item($file)
    if $config = Modules::load($file, $path)
      if $use_sections is true
        @config[$file] = {} unless @config[$file]?
        @config[$file][$key] = $val for $key, $val of $config

      else
        @config[$key] = $val for $key, $val of $config
      @_is_loaded.push $file
      return @item($file)

  #
  # Load Application Config File
  #
  #   Looks in APPPATH. If not found, then look in packages (if any)
  #
  # @param  [String]  file the config file name
  # @param  [Boolean] use_sections if configuration values should be loaded into their own section
  # @param  [Boolean] fail_gracefully  true if errors should just return false, false if an error message should be displayed
  # @return	[Boolean]	if the file was loaded correctly
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

        if fs.existsSync($file_path)
          $found = true
          $config = array_merge($config, require($file_path))

      if not $found
        if $fail_gracefully is true
          return false

        show_error('Your %s file does not appear to contain a valid configuration array.', $file_path)

      if $use_sections is true
        @config[$file] = {} unless @config[$file]?
        @config[$file][$key] = $val for $key, $val of $config

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
  # @param  [String]  item the config item name
  # @param  [String]  index the index name
  # @return	[String]  the config item, empty string if not found
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
  # @param  [String]  item the config item name
  # @return	[Mixed] returns the slashed value, false if not found
  #
  slashItem : ($item) ->
    if not @config[$item]?
      return false

    rtrim(@config[$item], '/') + '/'


  #
  # Site URL
  #
  # @param  [String]  uri the URI string
  # @return	[String]
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
  # @return	[String]
  #
  systemUrl :  ->

    $x = SYSPATH.split("/")
    @slashItem('base_url') + $x[$x.length-1] + '/'


  #
  # Set a config file item
  #
  # @param  [String]  item the config item key
  # @param  [String]  value the config item value
  # @return [Void]
  #
  setItem : ($item, $value) ->
    if 'string' is typeof $item then @config[$item] = $value
    else @setItem($key, $val) for $key, $val of $items
    return

# END Config class
module.exports = system.core.Config

# End of file Config.coffee
# Location: ./system/core/Config.coffee