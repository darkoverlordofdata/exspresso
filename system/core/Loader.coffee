#+--------------------------------------------------------------------+
#  Loader.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
# 
#  This file is a part of Expresso
# 
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the GNU General Public License Version 3
# 
#+--------------------------------------------------------------------+
#
#	Loader Class
#
# Loads views and files
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, WEBROOT} = require(process.cwd() + '/index')
{array_merge, file_exists, is_dir, ltrim, realpath, rtrim, trim, ucfirst} = require(FCPATH + '/helper')
{Exspresso, config_item, get_config, get_instance, is_loaded, load_class, log_message} = require(BASEPATH + 'core/Common')

app             = require(BASEPATH + 'core/Exspresso')  # Exspresso application module
express         = require('express')                    # Express 3.0 Framework

class CI_Loader

  # All these are set automatically. Don't mess with them.
  #
  # List of loaeded base classes
  #
  # @var array
  #
  _base_classes:        {} # Set by the controller class
  #
  # path to load views from
  #
  # @var string
  #
  _ci_view_path:        ''
  #
  # List of paths to load libraries from
  #
  # @var array
  #
  _ci_library_paths:    []
  #
  # List of paths to load models from
  #
  # @var array
  #
  _ci_model_paths:      []
  #
  # List of paths to load helpers from
  #
  # @var array
  #
  _ci_helper_paths:     []
  #
  # List of paths to load middleware from
  #
  # @var array
  #
  _ci_middleware_paths: []
  #
  # Cached variables
  #
  # @var object
  #
  _ci_cached_vars:      {}
  #
  # Cached classes
  #
  # @var array
  #
  _ci_classes:          {}
  #
  # List of loaded files
  #
  # @var array
  #
  _ci_loaded_files:     []
  #
  # List of loaded models
  #
  # @var array
  #
  _ci_models:           []
  #
  # List of loaded helpers
  #
  # @var array
  #
  _ci_helpers:          {}
  #
  # List of loaded middleware
  #
  # @var array
  #
  _ci_middleware:       {}
  #
  # List of class name mappings
  #
  # @var array
  #
  _ci_varmap:
    unit_test: 'unit'
    user_agent: 'agent'

  _ci_initializing:     false
  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  # Initiailize the loader search paths
  #
  # @return 	nothing
  #
  constructor: ->

    config = get_config()
    @_ci_view_path          = APPPATH + config.views
    @_ci_library_paths      = [APPPATH, BASEPATH]
    @_ci_middleware_paths   = [APPPATH, BASEPATH]
    @_ci_helper_paths       = [APPPATH, BASEPATH]
    @_ci_model_paths        = [APPPATH]
  
    log_message 'debug', "Loader Class Initialized"
    console.log "Loader Class Initialized"

  ## --------------------------------------------------------------------

  #
  # Initialize the Loader
  #
  # This method is called once in CI_Controller.
  #
  # @param 	object  CI_Controller class static self
  # @return 	object
  #
  initialize: () ->

    @_ci_classes        = {}
    @_ci_loaded_files   = []
    @_ci_models         = []
    @_ci_middleware     = {}
    @_base_classes      = is_loaded()

    @_ci_initializing = true
    @_ci_autoloader()
    @_ci_initializing = false
    return @

  ## --------------------------------------------------------------------

  #
  # Is Loaded
  #
  # A utility function to test if a class is in the self::$_ci_classes array.
  # This function returns the object name if the class tested for is loaded,
  # and returns FALSE if it isn't.
  #
  # It is mainly used in the form_helper -> _get_validation_object()
  #
  # @param 	string	class being checked for
  # @return 	mixed	class object name on the CI SuperObject or FALSE
  #
  is_loaded: ($class) ->
    if @_ci_classes[$class]?
      return @_ci_classes[$class]

    return false

  ## --------------------------------------------------------------------

  #
  # Class Loader
  #
  # This function lets users load and instantiate classes.
  # It is designed to be called from a user's app controllers.
  #
  # @access	public
  # @param	string	the name of the class
  # @param	mixed	the optional parameters
  # @param	string	an optional object name
  # @return	void
  #
  library: ($library = '', $params = null, $object_name = null) ->

    if Array.isArray($library)
      for $class in $library
        @library $class, $params
      return

    if $library is '' or @_base_classes[$library]?
      return false

    if $params isnt null and not Array.isArray($params)
      $params = null

    @_ci_load_class $library, $params, $object_name


  ## --------------------------------------------------------------------

  #
  # Model Loader
  #
  # This function lets users load and instantiate models.
  #
  # @access	public
  # @param	string	the name of the class
  # @param	string	name for the model
  # @param	bool	database connection
  # @return	void
  #
  model: ($model, $name = '', $db_conn = false) ->

    if Array.isArray($model)
      for $babe in $model
        @model $babe
      return

    if $model is '' then return

    $path = ''

    # Is the model in a sub-folder? If so, parse out the filename and path.
    if $last_slash = ($model.lastIndexOf('/')) isnt -1
      # The path is in front of the last slash
      $path = $model.substr(0, $last_slash + 1)

      # And the model name behind it
      $model = $model.substr($last_slash + 1)

    if $name is '' then $name = $model

    if @_ci_initializing
      return unless @_ci_models.indexOf($name) is -1

    $CI = get_instance()

    if $CI[$name]?
      console.log 'The model name you are loading is the name of a resource that is already being used: '+$name
      return

    for $mod_path in @_ci_model_paths
      if not file_exists($mod_path+'models/'+$path+$model+EXT)
        continue

      if $db_conn isnt false and not Exspresso['CI_DB']?
        if $db_conn is true then $db_conn = ''
        $CI.load.database $db_conn, false, true

      if not Exspresso['CI_Model']?
        load_class 'Model', 'core'

      $Model = require($mod_path+'models/'+$path+$model+EXT)
      $CI[$name] = new $Model()

      #console.log $CI[$name]

      @_ci_models.push $name
      return

    # couldn't find the model
    console.log 'Unable to locate the model you have specified: '+$model

  ## --------------------------------------------------------------------

  #
  # Database Loader
  #
  # @access	public
  # @param	string	the DB credentials
  # @param	bool	whether to return the DB object
  # @param	bool	whether to enable active record (this allows us to override the config setting)
  # @return	object
  #
  database: ($params = '', $return = false, $active_record = null) ->

    # Grab the super object
    $CI = get_instance()

    # Do we even need to load the database class?
    if Exspresso['CI_DB']? and $return is false and $active_record is null and $CI['db']?
      return false

    DB = require(BASEPATH+'database/DB'+EXT)

    if $return is true then return DB($params, $active_record)

    # Initialize the db variable.  Needed to prevent
    # reference errors with some configurations
    $CI.db = ''

    # Load the DB class
    $CI.db = DB($params, $active_record)

  ## --------------------------------------------------------------------
  
  #
  # Load the Utilities Class
  #
  # @access	public
  # @return	string
  #@
  dbutil: ->

    if not Exspresso['CI_DB']? then @database()

    $CI = get_instance()

    require_once BASEPATH+'database/DB_utility'+EXT
    require_once BASEPATH+'database/drivers/'+$CI.db.dbdriver+'/'+$CI.db.dbdriver+'_utility'+EXT
    $class = 'CI_DB_'+$CI.db.dbdriver+'_utility'
    # ex: CI_DB_sqlite_utility

    $CI.dbutil = new $class()

  ## --------------------------------------------------------------------

  #
  # Load File
  #
  # This is a generic file loader
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  file: ($path, $return = false) ->

    return @_ci_load({_ci_path: $path, _ci_return: $return})

  ## --------------------------------------------------------------------

  #
  # Load Helper
  #
  # This function loads the specified helper file.
  #
  # @access	public
  # @param	mixed
  # @return	void
  #
  helpers: ($helpers = []) ->
    @helper $helpers

  helper: ($helpers = []) ->

    for $helper in @_ci_prep_filename($helpers, '_helper')
      if @_ci_helpers[$helper]?
        continue

      $ext_helper = APPPATH+'helpers/'+config_item('subclass_prefix')+$helper+EXT

      # Is this a helper extension request?
      if file_exists($ext_helper)

        $base_helper = BASEPATH+'helpers/'+$helper+EXT
        if not file_exists($base_helper)
          console.log 'Unable to load the requested file: helpers/'+$helper+EXT
          return

        @_ci_helpers[$helper] = array_merge(require($base_helper), require($ext_helper))
        log_message 'debug', 'Helper loaded: '+$helper
        continue

      # Try to load the helper
      for $path in @_ci_helper_paths
        if file_exists($path+'helpers/'+$helper+EXT)
          @_ci_helpers[$helper] = require($path+'helpers/'+$helper+EXT)
          log_message 'debug', 'Helper loaded: '+$helper
          break

      # unable to load the helper
      if not @_ci_helpers[$helper]
        console.log 'Unable to load the requested file: helpers/'+$helper+EXT

  ## --------------------------------------------------------------------

  #
  # Load Middleware
  #
  # This function loads the specified connect middleware
  #
  # @access	public
  # @param	mixed
  # @return	void
  #
  middleware: ($middlewares = []) ->

    for $middleware in $middlewares
      if @_ci_middleware[$middleware]?
        continue

      # Try to load the middleware
      $loaded = false
      for $path in @_ci_middleware_paths
        if file_exists($path+'middleware/'+$middleware+EXT)
          require($path+'middleware/'+$middleware+EXT)()
          $loaded = true
          console.log 'Middleware loaded: '+$middleware
          break

      # unable to load the helper
      if not $loaded
        console.log 'Unable to load the requested file: middleware/'+$middleware+EXT

  ## --------------------------------------------------------------------

  #
  # Loads a language file
  #
  # @access	public
  # @param	array
  # @param	string
  # @return	void
  #
  language: ($file = [], $lang = '') ->

    $CI = get_instance()

    if  not Array.isArray($file)
      $file = [$file]

    for $langfile in $file
      $CI.lang.load $langfile, $lang


  ## --------------------------------------------------------------------

  #
  # Loads a config file
  #
  # @access	public
  # @param	string
  # @return	void
  #
  config: ($file = '', $use_sections = false, $fail_gracefully = false) ->

    $CI = get_instance()
    $CI.config.load $file, $use_sections, $fail_gracefully


  ## --------------------------------------------------------------------

  #
  # Driver
  #
  # Loads a driver library
  #
  # @param	string	the name of the class
  # @param	mixed	the optional parameters
  # @param	string	an optional object name
  # @return	void
  #

  driver: ($library = '', $params = NULL, $object_name = NULL) ->

    if not Exspresso['CI_Driver_Library']?
      # we aren't instantiating an object here, that'll be done by the Library itself
      require BASEPATH+'libraries/Driver'+EXT


    # We can save the loader some time since Drivers will #always# be in a subfolder,
    # and typically identically named to the library
    if $library.indexOf('/') is -1
      $library = $library+'/'+$library

    return @library($library, $params, $object_name)

  ## --------------------------------------------------------------------

  #
  # Add Package Path
  #
  # Prepends a parent path to the library, model, helper, and config path arrays
  #
  # @access	public
  # @param	string
  # @return	void
  #
  add_package_path: ($path) ->

    $path = rtrim($path, '/')+'/'
    
    @_ci_library_paths.unshift($path)
    @_ci_model_paths.unshift($path)
    @_ci_helper_paths.unshift($path)
    
    # Add config file path
    $config = @_ci_get_component('config')
    $config.config_paths.unshift($path)

  #  --------------------------------------------------------------------

  #
  # Get Package Paths
  #
  # Return a list of all package paths, by default it will ignore BASEPATH.
  #
  # @access	public
  # @param	string
  # @return	void
  #
  get_package_paths : ($include_base = false) ->
    return if $include_base is true then @_ci_library_paths else @_ci_model_paths


  #  --------------------------------------------------------------------
  
  #
  # Remove Package Path
  #
  # Remove a path from the library, model, and helper path arrays if it exists
  # If no path is provided, the most recently added path is removed.
  #
  # @access	public
  # @param	type
  # @return	type
  #
  remove_package_path : ($path = '', $remove_config_path = true) ->
    $config = @_ci_get_component('config')
  
    if $path is ''
      @_ci_library_paths.shift()
      @_ci_model_paths.shift()
      @_ci_helper_paths.shift()
      $config._config_paths.shift()
  
    else
      $path = rtrim($path, '/') + '/'
  
      if @_ci_library_paths.indexOf($path) isnt -1
        @_ci_library_paths = @_remove_path($path, @_ci_library_paths, [APPPATH, BASEPATH])

      if @_ci_helper_paths.indexOf($path) isnt -1
        @_ci_helper_paths = @_remove_path($path, @_ci_helper_paths, [APPPATH, BASEPATH])

      if @_ci_model_paths.indexOf($path) isnt -1
        @_ci_model_paths = @_remove_path($path, @_ci_model_paths, [APPPATH])

      if $config._config_paths.indexOf($path) isnt -1
        $config._config_paths = @_remove_path($path, $config._config_paths, [APPPATH])


  _remove_path: ($key, $original, $keeping = []) ->

    $ret = []
    for $item in $original
      $ret.push item unless $item is $key and $keeping.indexOf($item) is -1
    return $ret

  #  --------------------------------------------------------------------

  #
  # Load class
  #
  # This function loads the requested class.
  #
  # @access	private
  # @param	string	the item that is being loaded
  # @param	mixed	any additional parameters
  # @param	string	an optional object name
  # @return	void
  #
  _ci_load_class : ($class, $params = null, $object_name = null) ->
    #  Get the class name, and while we're at it trim any slashes.
    #  The directory path can be included as part of the class name,
    #  but we don't want a leading slash
    $class = trim($class.replace(EXT, ''), '/')

    #  Was the path included with the class name?
    #  We look for a slash to determine this
    $subdir = ''
    if $last_slash = $class.indexOf('/') isnt -1
      #  Extract the path
      $subdir = $class.substr(0, $last_slash + 1)

      #  Get the filename from the path
      $class = $class.substr($last_slash + 1)


    #  We'll test for both lowercase and capitalized versions of the file name
    for $class in [ucfirst($class), $class.toLowerCase()]
      $subclass = APPPATH + 'libraries/' + $subdir + config_item('subclass_prefix') + $class + EXT

      #  Is this a class extension request?
      if file_exists($subclass)
        $baseclass = BASEPATH + 'libraries/' + ucfirst($class) + EXT

        if not file_exists($baseclass)
          log_message('error', "Unable to load the requested class: " + $class)
          return
          #show_error("Unable to load the requested class: " + $class)


        #  Safety:  Was the class already loaded by a previous call?
        if @_ci_loaded_files.indexOf($subclass) isnt -1
          #  Before we deem this to be a duplicate request, let's see
          #  if a custom object name is being supplied.  If so, we'll
          #  return a new instance of the object
          if $object_name isnt null
            $CI = get_instance()
            if not $CI[$object_name]?
              return @_ci_init_class($class, config_item('subclass_prefix'), $params, $object_name)



          $is_duplicate = true
          log_message('debug', $class + " class already loaded. Second attempt ignored.")
          return


        require($baseclass)
        require($subclass)
        @_ci_loaded_files.push $subclass

        return @_ci_init_class($class, config_item('subclass_prefix'), $params, $object_name)


      #  Lets search for the requested library file and load it.
      $is_duplicate = false
      for $path in @_ci_library_paths
        $filepath = $path + 'libraries/' + $subdir + $class + EXT

        #  Does the file exist?  No?  Bummer...
        if not file_exists($filepath)
          continue


        #  Safety:  Was the class already loaded by a previous call?
        if @_ci_loaded_files.indexOf($filepath) isnt -1
          #  Before we deem this to be a duplicate request, let's see
          #  if a custom object name is being supplied.  If so, we'll
          #  return a new instance of the object
          if $object_name isnt null
            $CI = get_instance()
            if not $CI[$object_name]?
              return @_ci_init_class($class, '', $params, $object_name)



          $is_duplicate = true
          log_message('debug', $class + " class already loaded. Second attempt ignored.")
          return


        require($filepath)
        @_ci_loaded_files.push $filepath
        return @_ci_init_class($class, '', $params, $object_name)


    #  END FOREACH

    #  One last attempt.  Maybe the library is in a subdirectory, but it wasn't specified?
    if $subdir is ''
      $path = $class.toLowerCase() + '/' + $class
      return @_ci_load_class($path, $params)


    #  If we got this far we were unable to find the requested class.
    #  We do not issue errors if the load call failed due to a duplicate request
    if $is_duplicate is false
      log_message('error', "Unable to load the requested class: " + $class)
      #show_error("Unable to load the requested class: " + $class)
    return


  #  --------------------------------------------------------------------

  #
  # Instantiates a class
  #
  # @access	private
  # @param	string
  # @param	string
  # @param	string	an optional object name
  # @return	null
  #
  _ci_init_class : ($class, $prefix = '', $config = false, $object_name = null) ->
    #  Is there an associated config file for this class?  Note: these should always be lowercase
    if $config is null
      $config = {}
    #  Fetch the config paths containing any package paths
      $config_component = @_ci_get_component('config')

      if Array.isArray($config_component._config_paths)
        #  Break on the first found file, thus package files
        #  are not overridden by default paths
        for $path in $config_component._config_paths
          #  We test for both uppercase and lowercase, for servers that
          #  are case-sensitive with regard to file names. Check for environment
          #  first, global next

          if file_exists($path + 'config/' + $class.toLowerCase() + EXT)
            $config = require($path + 'config/' + $class.toLowerCase() + EXT)

          else if file_exists($path + 'config/' + ucfirst($class.toLowerCase()) + EXT)
            $config = require($path + 'config/' + ucfirst($class.toLowerCase()) + EXT)

          if file_exists($path + 'config/' + ENVIRONMENT + '/' + $class.toLowerCase() + EXT)
            $config = array_merge($config, require($path + 'config/' + ENVIRONMENT + '/' + $class.toLowerCase() + EXT))
            break

          else if file_exists($path + 'config/' + ENVIRONMENT + '/' + ucfirst($class.toLowerCase()) + EXT)
            $config = array_merge($config, require($path + 'config/' + ENVIRONMENT + '/' + ucfirst($class.toLowerCase()) + EXT))
            break

    if $prefix is ''
      if class_exists('CI_' + $class)
        $name = 'CI_' + $class

      else if class_exists(config_item('subclass_prefix') + $class)
        $name = config_item('subclass_prefix') + $class

      else
        $name = $class

    else
      $name = $prefix + $class

    #  Is the class name valid?
    if not class_exists($name)
      log_message('error', "Non-existent class: " + $name)
      return
      #show_error("Non-existent class: " + $class)


    #  Set the variable name we will assign the class to
    #  Was a custom class name supplied?  If so we'll use it
    $class = $class.toLowerCase()

    if $object_name is null
      $classvar = if ( not @_ci_varmap[$class]? ) then $class else @_ci_varmap[$class]

    else
      $classvar = $object_name


    #  Save the class name and object name
    @_ci_classes[$class] = $classvar

    #  Instantiate the class
    $CI = get_instance()
    if $config isnt null
      $CI[$classvar] = new $name($config)

    else
      $CI[$classvar] = new $name



  #  --------------------------------------------------------------------

  #
  # Autoloader
  #
  # The config/autoload.php file contains an array that permits sub-systems,
  # libraries, and helpers to be loaded automatically.
  #
  # @access	private
  # @param	array
  # @return	void
  #
  _ci_autoloader :  ->

    $autoload = {}
    $found = false
    if file_exists(APPPATH + 'config/autoload' + EXT)
      $found = true
      $autoload = array_merge($autoload, require(APPPATH + 'config/autoload' + EXT))
    if file_exists(APPPATH + 'config/' + ENVIRONMENT + '/autoload' + EXT)
      $found = true
      $autoload = array_merge($autoload, require(APPPATH + 'config/' + ENVIRONMENT + '/autoload' + EXT))

    return unless $found

    #  Autoload packages
    if $autoload['packages']?
      for $package_path in $autoload['packages']
        @add_package_path $package_path

    #  Load any custom config file
    if $autoload['config'].length > 0
      $CI = get_instance()
      for $val, $key in as
        $CI.config.load $val

    #  Autoload helpers and languages
    for $type in ['helper', 'language']
      if $autoload[$type]? and $autoload[$type].length > 0
        @$type($autoload[$type])

    #  Load libraries
    if $autoload['libraries']?  and $autoload['libraries'].length > 0
      #  Load the database driver.
      if $autoload['libraries'].indexOf('database') isnt -1
        @database()
        #$autoload['libraries'] = array_diff($autoload['libraries'], ['database'])
      #  Load all other libraries
      for $item in $autoload['libraries']
        @library $item unless $item = 'database'

    #  Autoload models
    if $autoload['model']?
      @model $autoload['model']


    #  Autoload models
    if $autoload['middleware']?
      @middleware $autoload['middleware']


  #  --------------------------------------------------------------------

  #
  # Object to Array
  #
  # Takes an object as input and converts the class variables to array key/vals
  #
  # @access	private
  # @param	object
  # @return	array
  #
  _ci_object_to_array : ($object) ->
    return $object
  #return if (is_object($object)) then get_object_vars($object) else $object


  #  --------------------------------------------------------------------

  #
  # Get a reference to a specific library or model
  #
  # @access	private
  # @return	bool
  #
  _ci_get_component : ($component) ->
    $CI = get_instance()
    return $CI[$component]


  #  --------------------------------------------------------------------

  #
  # Prep filename
  #
  # This function preps the name of various items to make loading them more reliable.
  # example:
  #
  #
  # @access	private
  # @param	mixed
  # @return	array
  #
  _ci_prep_filename : ($filename, $extension) ->

    if typeof $filename is 'string'
      return [($filename.replace($extension, '').replace(EXT, '') + $extension).toLowerCase()]

    else
      for $key, $val of $filename
        $filename[$key] = ($val.replace($extension, '').replace(EXT, '') + $extension).toLowerCase()

      return $filename

# END CI_Load class

Exspresso.CI_Loader = CI_Loader
module.exports =  CI_Loader

# End of file Loader.coffee
# Location: ./Loader.coffee