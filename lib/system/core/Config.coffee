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
# Exspresso Config Class
#
# This class contains functions that enable config files to be managed
#
#
module.exports = class system.core.Config


  fs = require('fs')

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
  # @property [Object] system controller
  #
  controller: null
  #
  # @property [Object] module environment
  #
  modules: null

  #
  # Constructor
  #
  # Sets the config data from the primary config.coffee file as a class variable
  #
  #
  constructor: ($controller) ->

    $config = get_config()  # Get the core config array

    defineProperties @,
      _is_loaded    : {enumerable: false, writeable: false, value: []}
      paths         : {enumerable: true,  writeable: false, value: [APPPATH]}
      modpaths      : {enumerable: true,  writeable: false, value: []}
      modules       : {enumerable: true,  writeable: false, value: {}}
      config        : {enumerable: true,  writeable: false, value: $config}
      controller    : {enumerable: true,  writeable: false, value: $controller}


    log_message 'debug', "Config Class Initialized"

    #
    # discover the installed modules
    #
    for $path in $config['module_paths']
      for $module in fs.readdirSync($path)
        if fs.existsSync($path+$module+'/'+ucfirst($module)+EXT)
          $class = require($path+$module+'/'+ucfirst($module)+EXT)
          @modules[$module] = new $class($controller)
          @modpaths.push @modules[$module].path+'/'


  #
  # Get Paths
  #
  # @param  [String]  hint  the module to search first
  # @param  [Array<String>] packages  array of app locations to search next
  # @return [Array<String>] the combined list
  #
  getPaths: ($hint = '', $packages = @paths) ->
    return @modpaths.concat($packages) if $hint is ''
    #
    # Search the specified $module first
    #
    if @modules[$hint]?
      $paths = [@modules[$hint].path+'/']
      for $name, $module of @modules
        $paths.push $module.path+'/' unless $name is $hint
      $paths.concat($packages)


  #
  # Load configuration file
  #
  # Checks in MODPATH first. 
  # Then check in the APPPATH.
  # Lastly check in packages
  #
  # @param  [String]  file the config file name
  # @param  [Boolean] use_sections if configuration values should be loaded into their own section
  # @param  [Boolean] fail_gracefully  true if errors should just return false, false if an error message should be displayed
  # @param  [String]  module module name from the uri
  # @return	[Boolean]	true if the file was loaded correctly
  #
  load: ($file = 'config', $use_sections = false, $fail_gracefully = false, $module = '') ->

    if typeof $use_sections is 'string'
      [$use_sections, $fail_gracefully, $module] = [false, false, $use_sections]
    else if typeof $fail_gracefully is 'string'
      [$fail_gracefully, $module] = [false, $use_sections]

    return @item($file) unless @_is_loaded.indexOf($file) is -1

    $file = $file.replace(EXT, '')
    $loaded = false


    for $path in @getPaths($module)

      $config = {}
      $found = false
      $check_locations = [$file, ENVIRONMENT + '/' + $file]
      for $location in $check_locations

        $file_path = $path + 'config/' + $location + EXT

        if fs.existsSync($file_path)
          $found = true
          $config[$key] = $val for $key, $val of require($file_path)

      if not $found
        if $fail_gracefully is true then return false
        else show_error('The config file [%s] does not contain valid configuration settings.', $file_path)

      if $use_sections
        @config[$file] = {} unless @config[$file]?
        @config[$file][$key] = $val for $key, $val of $config

      else
        @config[$key] = $val for $key, $val of $config

      @_is_loaded.push $file_path
      $loaded = true

    if not $loaded
      if $fail_gracefully is true then return false
      else show_error('The config file [%s] does not exist.', $file+EXT)

    @item($file)


  #
  # Fetch a config file item
  #
  #
  # @param  [String]  item the config item name
  # @param  [String]  index the index name
  # @return	[String]  the config item, empty string if not found
  #
  item: ($item, $index = '') ->
    if $index is ''
      return '' if not @config[$item]?
      @config[$item]

    else
      return '' if not @config[$index]?
      return '' if not @config[$index][$item]?
      @config[$index][$item]

  #
  # Slash Item
  #
  # Get a config item and make sure it ends with a slash
  #
  # @param  [String]  item the config item name
  # @return	[Mixed] returns the slashed value, false if not found
  #
  slashItem: ($item) ->
    return false if not @config[$item]?
    rtrim(@config[$item], '/') + '/'


  #
  # Site URL
  #
  # @param  [String]  uri the URI string
  # @return	[String]
  #
  siteUrl: ($uri = '') ->

    if typeof $uri is 'string' and $uri is ''
      return @slashItem('base_url') + @item('index_page')

    $uri = $uri.join('/') if Array.isArray($uri)
    $index = if @item('index_page') is '' then '' else @slashItem('index_page')
    $suffix = if (@item('url_suffix') is false) then '' else @item('url_suffix')
    @slashItem('base_url') + $index + trim($uri, '/') + $suffix

  #
  # System URL
  #
  # @return	[String]
  #
  systemUrl: () ->
    @slashItem('base_url') + SYSPATH.split("/").pop() + '/'


  #
  # Set a config file item
  #
  # @param  [String]  item the config item key
  # @param  [String]  value the config item value
  # @return [Void]
  #
  setItem: ($item, $value) ->
    if 'string' is typeof $item then @config[$item] = $value
    else @setItem($key, $val) for $key, $val of $item
    return

