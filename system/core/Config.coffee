#+--------------------------------------------------------------------+
#| Config.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Darklite is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
# Exspress Config Class
#
# This class contains functions that enable config files to be managed
#
#
log_message = (type, message) ->

get_config = () ->
  
common = require(SYSPATH + 'core/Common')
  
class Exspress.Config

  $config: {}
  $is_loaded: {}
  $_config_paths: [APPPATH]

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
    @config = common.get_config()
    log_message('debug', "Config Class Initialized")

    #  Set the base_url automatically if none was provided
    if @config['base_url'] is ''
      ###
      if $_SERVER['HTTP_HOST']?
        $base_url = if $_SERVER['HTTPS']?  and strtolower($_SERVER['HTTPS']) isnt 'off' then 'https' else 'http'
        $base_url+='://' + $_SERVER['HTTP_HOST']
        $base_url+=str_replace(basename($_SERVER['SCRIPT_NAME']), '', $_SERVER['SCRIPT_NAME'])


      else
      ###
      $base_url = 'http://localhost/'


      @set_item 'base_url', $base_url



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
    $file = if ($file is '') then 'config' else str_replace(EXT, '', $file)
    $found = false
    $loaded = false

    for $path in as
      $check_locations = [ENVIRONMENT + '/' + $file, $file]
      else [$file]

      for $location in as
        $file_path = $path + 'config/' + $location + EXT

        if in_array($file_path, @is_loaded, TRUE)
          $loaded = TRUE
          continue2


        if file_exists($file_path)
          $found = TRUE
          break



      if $found is false
        continue


      eval include_all($file_path)

      if not $config?  or  not is_array($config)
        if $fail_gracefully is TRUE
          return false

        show_error('Your ' + $file_path + ' file does not appear to contain a valid configuration array.')


      if $use_sections is TRUE
        if @config[$file]?
          @config[$file] = array_merge(@config[$file], $config)

        else
          @config[$file] = $config


      else
        @config = array_merge(@config, $config)


      @is_loaded.push $file_path
      delete $config

      $loaded = TRUE
      log_message('debug', 'Config file loaded: ' + $file_path)


    if $loaded is false
      if $fail_gracefully is TRUE
        return false

      show_error('The configuration file ' + $file + EXT + ' does not exist.')


    return TRUE


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
        return false


      $pref = @config[$item]

    else
      if not @config[$index]?
        return false


      if not @config[$index][$item]?
        return false


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
    if $uri is ''
      return @slash_item('base_url') + @item('index_page')


    if @item('enable_query_strings') is false
      if is_array($uri)
        $uri = implode('/', $uri)


      $index = if @item('index_page') is '' then '' else @slash_item('index_page')
      $suffix = if (@item('url_suffix') is false) then '' else @item('url_suffix')
      return @slash_item('base_url') + $index + trim($uri, '/') + $suffix

    else
      if is_array($uri)
        $i = 0
        $str = ''
        for $val, $key in as
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
    $x = explode("/", preg_replace("|/*(.+?)/*$|", "\\1", BASEPATH))
    return @slash_item('base_url') + end($x) + '/'


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
  # This function is called by the front controller (CodeIgniter.php)
  # after the Config class is instantiated.  It permits config items
  # to be assigned or overriden by variables contained in the index.php file
  #
  # @access	private
  # @param	array
  # @return	void
  #
  _assign_to_config : ($items = {}) ->
    if is_array($items)
      for $val, $key in as
        @set_item($key, $val)





# End of file Config.coffee
# Location: ./Config.coffee