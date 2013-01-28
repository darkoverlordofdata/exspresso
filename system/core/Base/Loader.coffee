#+--------------------------------------------------------------------+
#+--------------------------------------------------------------------+
#  Loader.coffee
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
# @copyright	Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		MIT License
# @link		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#  ------------------------------------------------------------------------

#
# Loader Class
#
# Loads views and files
#
# @package		Exspresso
# @subpackage	Libraries
# @author		darkoverlordofdata
# @category	Loader
# @link		http://darkoverlordofdata.com/user_guide/libraries/loader.html
#
class global.Base_Loader

  path = require('path')

  # All these are set automatically. Don't mess with them.
  #
  # List of loaded base classes
  #
  # @var array
  #
  _base_classes:        null # Set by the controller class
  #
  # path to load views from
  #
  # @var string
  #
  _ex_view_path:        ''
  #
  # List of paths to load libraries from
  #
  # @var array
  #
  _ex_library_paths:    null
  #
  # List of paths to load models from
  #
  # @var array
  #
  _ex_model_paths:      null
  #
  # List of paths to load helpers from
  #
  # @var array
  #
  _ex_helper_paths:     null
  #
  # Cached variables
  #
  # @var object
  #
  _ex_cached_vars:      null
  #
  # Cached classes
  #
  # @var array
  #
  _ex_classes:          null
  #
  # List of loaded files
  #
  # @var array
  #
  _ex_loaded_files:     null
  #
  # List of loaded models
  #
  # @var array
  #
  _ex_models:           null
  #
  # List of loaded helpers
  #
  # @var array
  #
  _ex_helpers:          null
  #
  # List of class name mappings
  #
  # @var array
  #
  _ex_varmap:
    unit_test: 'unit'
    user_agent: 'agent'
  #
  # Parent controller instance
  #
  # @var object
  #
  Exspresso:                     null
  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  # Initiailize the loader search paths
  #
  # @return 	nothing
  #
  constructor: (@Exspresso)->

    @_ex_view_path          = APPPATH + config_item('views')
    @_ex_library_paths      = [APPPATH, BASEPATH]
    @_ex_helper_paths       = [APPPATH, BASEPATH]
    @_ex_model_paths        = [APPPATH]

    log_message 'debug', "Loader Class Initialized"

  ## --------------------------------------------------------------------

  #
  # Initialize the Loader
  #
  #
  # @param 	object  Exspresso controller instance
  # @param  boolean call autoload?
  # @return object
  #
  initialize: () ->

    @_ex_classes        = {}
    @_ex_loaded_files   = []
    @_ex_models         = []
    @_ex_cached_vars    = {}
    @_ex_helpers        = {}
    @_base_classes      = is_loaded()

    @_ex_autoloader()
    return @

  ## --------------------------------------------------------------------

  #
  # Is Loaded
  #
  # A utility function to test if a class is in the self::$_ex_classes array.
  # This function returns the object name if the class tested for is loaded,
  # and returns FALSE if it isn't.
  #
  # It is mainly used in the form_helper -> _get_validation_object()
  #
  # @param 	string	class being checked for
  # @return 	mixed	class object name on the CI SuperObject or FALSE
  #
  is_loaded: ($class) ->
    if @_ex_classes[$class]?
      return @_ex_classes[$class]

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

    if is_array($library)
      for $class in $library
        @library $class, $params
      return

    if $library is '' or @_base_classes[$library]?
      return false

    if $params isnt null and not is_array($params)
      $params = null

    @_ex_load_class $library, $params, $object_name

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

    if is_array($model)
      for $babe in $model
        @model $babe
      return

    if $model is '' then return

    $path = ''

    # Is the model in a sub-folder? If so, parse out the filename and path.
    $last_slash = strrpos($model, '/')
    if $last_slash isnt false
      #  The path is in front of the last slash
      $path = substr($model, 0, $last_slash + 1)

      #  And the model name behind it
      $model = substr($model, $last_slash + 1)

    if $name is '' then $name = $model

    if in_array($name, @_ex_models, true)
      return

    if @Exspresso[$name]?
      show_error 'The model name you are loading is the name of a resource that is already being used: %s', $name


    for $mod_path in @_ex_model_paths
      if not file_exists($mod_path+'models/'+$path+$model+EXT)
        continue

      if $db_conn isnt false and not class_exists('Exspresso_DB')
        if $db_conn is true then $db_conn = ''
        @Exspresso.load.database $db_conn, false, true

      if not class_exists('Exspresso_Model')
        load_class 'Model', 'core'

      $Model = require($mod_path+'models/'+$path+$model+EXT)
      $model = new $Model(@Exspresso)

      @Exspresso[$name] = $model
      @_ex_models.push $name
      return

    # couldn't find the model
    show_error 'Unable to locate the model you have specified: %s', $model

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

    # Do we even need to load the database class?
    if class_exists('Exspresso_DB') and $return is false and $active_record is null and @Exspresso['db']?
      return false

    $params = $params || Exspresso.server._db

    DB = require(BASEPATH+'database/DB'+EXT)($params, $active_record)

    @Exspresso.queue ($next) -> DB.initialize $next

    if $return is true then return DB #($params, $active_record)

    # Initialize the db variable.  Needed to prevent
    # reference errors with some configurations
    @Exspresso.db = ''

    # Load the DB class
    @Exspresso.db = DB #($params, $active_record)

  ## --------------------------------------------------------------------

  #
  # Load the Utilities Class
  #
  # @access	public
  # @return	string
  #@
  dbutil: ($params = '', $return = false) ->

    if $params is ''
      if not class_exists('Exspresso_DB')
        @database()
      $db = @Exspresso.db
    else
      $db = @database($params, true)

    require(BASEPATH + 'database/DB_forge' + EXT)
    require BASEPATH + 'database/DB_utility'+ EXT
    $class = require(BASEPATH + 'database/drivers/' + $db.dbdriver + '/' + $db.dbdriver + '_utility' + EXT)
    # ex: Exspresso_DB_sqlite_utility

    if $return is true then return new $class(@Exspresso, $db)
    @Exspresso.dbutil = new $class(@Exspresso, $db)

  #  --------------------------------------------------------------------

  #
  # Load the Database Forge Class
  #
  # @access	public
  # @return	string
  #
  dbforge: ($params = '', $return = false) ->

    if $params is ''
      if not class_exists('Exspresso_DB')
        @database()
      $db = @Exspresso.db
    else
      $db = @database($params, true)

    require(BASEPATH + 'database/DB_forge' + EXT)
    $class = require(BASEPATH + 'database/drivers/' + $db.dbdriver + '/' + $db.dbdriver + '_forge' + EXT)

    if $return is true then return new $class(@Exspresso, $db)
    @Exspresso.dbforge = new $class(@Exspresso, $db)

  #  --------------------------------------------------------------------

  #
  # Load View
  #
  # This function is used to load a "view" file.  It has three parameters:
  #
  # 1. The name of the "view" file to be included.
  # 2. An associative array of data to be extracted for use in the view.
  # 3. TRUE/FALSE - whether to return the data or load it.  In
  # some cases it's advantageous to be able to return data so that
  # a developer can process it in some way.
  #
  # @access	public
  # @param	string
  # @param	array
  # @param	bool
  # @return	void
  #
  view: ($view, $vars = {}, $callback = null) ->
    log_message 'debug', 'Exspresso_Loader::view'
    @_ex_load('', $view, $vars, $callback)

  #  --------------------------------------------------------------------

  #
  # Set Variables
  #
  # Once variables are set they become available within
  # the controller class and its "view" files.
  #
  # @access	public
  # @param	array
  # @return	void
  #
  vars: ($vars = {}, $val = '') ->
    if $val isnt '' and is_string($vars)
      $vars = array($vars, $val)


    if is_array($vars) and count($vars) > 0
      for $key, $val of $vars
        @_ex_cached_vars[$key] = $val


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
  file: ($path, $callback) ->
    @_ex_load($path, '', {}, $callback)

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

    for $helper in @_ex_prep_filename($helpers, '_helper')
      if @_ex_helpers[$helper]?
        continue

      $ext_helper = APPPATH+'helpers/'+config_item('subclass_prefix')+$helper+EXT

      # Is this a helper extension request?
      if file_exists($ext_helper)

        $base_helper = BASEPATH+'helpers/'+$helper+EXT
        if not file_exists($base_helper)
          show_error 'Unable to load the requested file: helpers/%s', $helper+EXT

        @_ex_helpers[$helper] = array_merge(require($base_helper), require($ext_helper))
        log_message 'debug', 'Helper loaded: '+$helper
        continue

      # Try to load the helper
      for $path in @_ex_helper_paths
        if file_exists($path+'helpers/'+$helper+EXT)
          @_ex_helpers[$helper] = require($path+'helpers/'+$helper+EXT)
          log_message 'debug', 'Helper loaded: '+$helper
          break

    # unable to load the helper
    if not @_ex_helpers[$helper]
      show_error 'Unable to load the requested file: helpers/%s', $helper+EXT

    # expose the helpers to template engine
    Exspresso.server.set_helpers @_ex_helpers[$helper]

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

    if  not is_array($file)
      $file = [$file]

    for $langfile in $file
      @Exspresso.lang.load $langfile, $lang


  ## --------------------------------------------------------------------

  #
  # Loads a config file
  #
  # @access	public
  # @param	string
  # @return	void
  #
  config: ($file = '', $use_sections = false, $fail_gracefully = false) ->

    @Exspresso.config.load $file, $use_sections, $fail_gracefully


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

    if not class_exists('Exspresso_Driver_Library')
      # we aren't instantiating an object here, that'll be done by the Library itself
      require BASEPATH+'libraries/Driver'+EXT


    # We can save the loader some time since Drivers will #always# be in a subfolder,
    # and typically identically named to the library
    if $library.indexOf('/') is -1
      $library = $library+'/'+$library

    @library($library, $params, $object_name)

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

    array_unshift(@_ex_library_paths, $path)
    array_unshift(@_ex_model_paths, $path)
    array_unshift(@_ex_helper_paths, $path)

    #  Add config file path
    $config = @_ex_get_component('config')
    array_unshift($config._config_paths, $path)



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
    return if $include_base is true then @_ex_library_paths else @_ex_model_paths


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
    $config = @_ex_get_component('config')

    if $path is ''
      $void = array_shift(@_ex_library_paths)
      $void = array_shift(@_ex_model_paths)
      $void = array_shift(@_ex_helper_paths)
      $void = array_shift($config._config_paths)

    else
      $path = rtrim($path, '/') + '/'

      for $var in ['_ex_library_paths', '_ex_model_paths', '_ex_helper_paths']
        if ($key = array_search($path, @[$var])) isnt false
          delete @[$var][$key]



      if ($key = array_search($path, $config._config_paths)) isnt false
        delete $config._config_paths[$key]



    #  make sure the application default paths are still in the array
    @_ex_library_paths = array_unique(array_merge(@_ex_library_paths, [APPPATH, BASEPATH]))
    @_ex_helper_paths = array_unique(array_merge(@_ex_helper_paths, [APPPATH, BASEPATH]))
    @_ex_model_paths = array_unique(array_merge(@_ex_model_paths, [APPPATH]))
    $config._config_paths = array_unique(array_merge($config._config_paths, [APPPATH]))



  #  --------------------------------------------------------------------

  #
  # Loader
  #
  # This function is used to load views and files.
  # Variables are prefixed with _ex_ to avoid symbol collision with
  # variables made available to view files
  #
  # @access	private
  # @param	array
  # @return	void
  #
  _ex_load : ($_ex_path = '', $_ex_view = '', $_ex_vars = {}, $_ex_return = null) ->

    #  Set the path to the requested file
    if $_ex_path is ''
      $_ex_ext = path.extname($_ex_view)
      $_ex_file = if ($_ex_ext is '') then $_ex_view + config_item('view_ext') else $_ex_view
      $_ex_path = rtrim(@_ex_view_path, '/') + '/' + $_ex_file

    else
      $_ex_x = explode('/', $_ex_path)
      $_ex_file = end($_ex_x)


    if not file_exists($_ex_path)
      show_error('Unable to load the requested file: %s', $_ex_file)

    #  This allows anything loaded using $this->load (views, files, etc.)
    #  to become accessible from within the Controller and Model functions.

    #$_ex_CI = Exspresso
    #for $_ex_key, $_ex_var of @Exspresso
    #  if typeof @Exspresso[$_ex_key] isnt 'function'
    #    if not @[$_ex_key]?
    #      @[$_ex_key] = @Exspresso[$_ex_key]

    #
    # Extract and cache variables
    #
    # You can either set variables using the dedicated $this->load_vars()
    # function or via the second parameter of this function. We'll merge
    # the two types and cache them so that views that are embedded within
    # other views can have access to these variables.
    #
    if is_array($_ex_vars)
      @_ex_cached_vars = array_merge(@_ex_cached_vars, $_ex_vars)


    @Exspresso.render $_ex_path, @_ex_cached_vars, ($err, $html) =>

      log_message('debug', 'File loaded: ' + $_ex_path)
      if $_ex_return isnt null
        $_ex_return $err, $html
      else
        @Exspresso.output.append_output $html
        @Exspresso.output._display()





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
  _ex_load_class : ($class, $params = null, $object_name = null) ->
    #  Get the class name, and while we're at it trim any slashes.
    #  The directory path can be included as part of the class name,
    #  but we don't want a leading slash
    $class = str_replace(EXT, '', trim($class, '/'))

    #  Was the path included with the class name?
    #  We look for a slash to determine this
    $subdir = ''
    if ($last_slash = strrpos($class, '/')) isnt false
      #  Extract the path
      $subdir = substr($class, 0, $last_slash + 1)

      #  Get the filename from the path
      $class = substr($class, $last_slash + 1)


    #  We'll test for both lowercase and capitalized versions of the file name
    for $class in [ucfirst($class), strtolower($class)]
      $subclass = APPPATH + 'libraries/' + $subdir + config_item('subclass_prefix') + $class + EXT

      #  Is this a class extension request?
      if file_exists($subclass)
        $baseclass = BASEPATH + 'libraries/' + ucfirst($class) + EXT

        if not file_exists($baseclass)
          log_message('error', "Unable to load the requested class: %s", $class)
          show_error("Unable to load the requested class: %s", $class)


        #  Safety:  Was the class already loaded by a previous call?
        if in_array($subclass, @_ex_loaded_files)
          #  Before we deem this to be a duplicate request, let's see
          #  if a custom object name is being supplied.  If so, we'll
          #  return a new instance of the object
          if not is_null($object_name)
            if not @Exspresso[$object_name]?
              return @_ex_init_class($class, config_item('subclass_prefix'), $params, $object_name)

          $is_duplicate = true
          log_message('debug', $class + " class already loaded. Second attempt ignored.")
          return

        require($baseclass)
        require($subclass)
        @_ex_loaded_files.push $subclass

        return @_ex_init_class($class, config_item('subclass_prefix'), $params, $object_name)


      #  Lets search for the requested library file and load it.
      $is_duplicate = false
      for $path in @_ex_library_paths
        $filepath = $path + 'libraries/' + $subdir + $class + EXT

        #  Does the file exist?  No?  Bummer...
        if not file_exists($filepath)
          continue


        #  Safety:  Was the class already loaded by a previous call?
        if in_array($filepath, @_ex_loaded_files)
          #  Before we deem this to be a duplicate request, let's see
          #  if a custom object name is being supplied.  If so, we'll
          #  return a new instance of the object
          if not is_null($object_name)
            if not @Exspresso[$object_name]?
              return @_ex_init_class($class, '', $params, $object_name)

          $is_duplicate = true
          log_message('debug', $class + " class already loaded. Second attempt ignored.")
          return

        require($filepath)
        @_ex_loaded_files.push $filepath
        return @_ex_init_class($class, '', $params, $object_name)


      #  END FOREACH

      #  One last attempt.  Maybe the library is in a subdirectory, but it wasn't specified?
      if $subdir is ''
        $path = strtolower($class) + '/' + $class
        return @_ex_load_class($path, $params)


      #  If we got this far we were unable to find the requested class.
      #  We do not issue errors if the load call failed due to a duplicate request
      if $is_duplicate is false
        log_message('error', "Unable to load the requested class: %s", $class)
        show_error("Unable to load the requested class: %s", $class)




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
  _ex_init_class : ($class, $prefix = '', $config = false, $object_name = null) ->

    #  Is there an associated config file for this class?  Note: these should always be lowercase
    if $config is false
      $config = {}
    #  Fetch the config paths containing any package paths
    $config_component = @_ex_get_component('config')
    if Array.isArray($config_component._config_paths)
      #  Break on the first found file, thus package files
      #  are not overridden by default paths
      for $path in $config_component._config_paths
        #  We test for both uppercase and lowercase, for servers that
        #  are case-sensitive with regard to file names. Check for environment
        #  first, global next

        if file_exists($path + 'config/' + $class.toLowerCase() + EXT)
          $config = array_merge(require($path + 'config/' + $class.toLowerCase() + EXT), $config)

        else if file_exists($path + 'config/' + ucfirst($class.toLowerCase()) + EXT)
          $config = array_merge(require($path + 'config/' + ucfirst($class.toLowerCase()) + EXT), $config)

        if file_exists($path + 'config/' + ENVIRONMENT + '/' + $class.toLowerCase() + EXT)
          $config = array_merge(require($path + 'config/' + ENVIRONMENT + '/' + $class.toLowerCase() + EXT), $config)
          break

        else if file_exists($path + 'config/' + ENVIRONMENT + '/' + ucfirst($class.toLowerCase()) + EXT)
          $config = array_merge(require($path + 'config/' + ENVIRONMENT + '/' + ucfirst($class.toLowerCase()) + EXT), $config)
          break

    if $prefix is ''
      if class_exists('Exspresso_' + $class)
        $name = 'Exspresso_' + $class

      else if class_exists(config_item('subclass_prefix') + $class)
        $name = config_item('subclass_prefix') + $class

      else
        $name = $class

    else
      $name = $prefix + $class

    #  Is the class name valid?
    if not class_exists($name)
      show_error("Non-existent class: %s", $class)


    #  Set the variable name we will assign the class to
    #  Was a custom class name supplied?  If so we'll use it
    $class = $class.toLowerCase()

    if $object_name is null
      $classvar = if ( not @_ex_varmap[$class]? ) then $class else @_ex_varmap[$class]

    else
      $classvar = $object_name


    #  Save the class name and object name
    @_ex_classes[$class] = $classvar

    #  Instantiate the class
    @Exspresso[$classvar] = new global[$name]($config, @Exspresso)
    return @Exspresso[$classvar]


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
  _ex_autoloader :  ->

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
      for $val, $key in as
        @Exspresso.config.load $val

    #  Autoload helpers and languages
    for $type in ['helper', 'language']
      if $autoload[$type]? and $autoload[$type].length > 0
        @[$type]($autoload[$type])

    #  Load libraries
    if $autoload['libraries']?  and $autoload['libraries'].length > 0
      #  Load the database driver.
      if $autoload['libraries'].indexOf('database') isnt -1
        @database()
        #$autoload['libraries'] = array_diff($autoload['libraries'], ['database'])
      #  Load all other libraries
      for $item in $autoload['libraries']
        @library $item unless $item is 'database'

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
  _ex_object_to_array : ($object) ->
    return $object
  #return if (is_object($object)) then get_object_vars($object) else $object


  #  --------------------------------------------------------------------

  #
  # Get a reference to a specific library or model
  #
  # @access	private
  # @return	bool
  #
  _ex_get_component : ($component) ->
    return @Exspresso[$component]


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
  _ex_prep_filename : ($filename, $extension) ->

    if not is_array($filename)
      return [($filename.replace($extension, '').replace(EXT, '') + $extension).toLowerCase()]

    else
      for $key, $val of $filename
        $filename[$key] = ($val.replace($extension, '').replace(EXT, '') + $extension).toLowerCase()

      return $filename

# END Base_Load class
module.exports = Base_Loader
# End of file Loader.coffee
# Location: ./system/core/Base/Loader.coffee