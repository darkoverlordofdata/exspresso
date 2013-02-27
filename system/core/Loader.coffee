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
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright	Copyright (c) 2011 Wiredesignz
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
#
require BASEPATH+'core/Modules.coffee'


class global.Exspresso_Loader

  path = require('path')

  _module               : ''    # uri module
  _view_path            : ''    # path to view modules (*.eco)
  _library_paths        : null  # array of paths to libraries
  _model_paths          : null  # array of paths to models
  _helper_paths         : null  # array of paths to helpers
  _base_classes         : null  # cache of classes loaded by Exspresso
  _classes              : null  # cache of classes loaded by Loader
  _cached_vars          : null  # cache of view data variables
  _loaded_files         : null  # array list of loaded files
  _models               : null  # array list of loaded models
  _helpers              : null  # chache of loaded helpers
  _plugins              : null  # chache of loaded plugins
  _varmap               : null  # standard object aliases

  #
  # Initiailize the loader search paths
  #
  # @return 	nothing
  #
  constructor: ($controller)->

    defineProperties @,
      controller      : {enumerable: true, writeable: false, value: $controller}


    @_module          = $controller.module
    @_view_path       = APPPATH + config_item('views')
    @_library_paths   = [APPPATH, BASEPATH]
    @_helper_paths    = [APPPATH, BASEPATH]
    @_model_paths     = [APPPATH]
    @_varmap          =
      unit_test       : 'unit'
      user_agent      : 'agent'

    log_message 'debug', "Loader Class Initialized"

  #
  # Initialize the Loader
  #
  #
  # @param 	object  Exspresso controller instance
  # @param  boolean call autoload?
  # @return object
  #
  initialize: () ->

    @_loaded_files   = []
    @_models         = []
    @_cached_vars    = {}
    @_classes        = {}
    @_helpers        = {}
    @_base_classes   = is_loaded()

    @_autoloader()
    return @

  #
  # Is Loaded
  #
  # A utility function to test if a class is in the self::$_classes array.
  # This function returns the object name if the class tested for is loaded,
  # and returns FALSE if it isn't.
  #
  # It is mainly used in the form_helper -> _get_validation_object()
  #
  # @param 	string	class being checked for
  # @return 	mixed	class object name on the CI SuperObject or FALSE
  #
  is_loaded: ($class) ->
    if @_classes[$class]?
      return @_classes[$class]

    return false

  #
  # Module Class Loader
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
  library: ($library, $params = {}, $object_name = null) ->

    $controller = @controller

    if is_array($library) then return @libraries($library)

    $class = strtolower(end(explode('/', $library)))

    if @_classes[$class]? and ($_alias = @_classes[$class])
      return $controller[$_alias]

    ($_alias = strtolower($object_name)) or ($_alias = $class)

    [$path, $_library] = Modules.find($library, $controller.module, 'libraries/')

    # load library config file as params *

    [$path2, $file] = Modules.find($_alias, $controller.module, 'config/')
    ($path2) and ($params = array_merge(Modules.load_file($file, $path2, 'config'), $params))

    if $path is false

      @_load_class($library, $params, $object_name)
      $_alias = @_classes[$class]

    else

      $Library = Modules.load_file($_library, $path)
      @_classes[$class] = $_alias
      defineProperty $controller, $_alias,
        enumerable  : true
        writeable   : false
        value       : create_mixin($controller, $Library, $controller, $params)

    return $controller[$_alias]

  #
  # Load an array of libraries
  #
  # @access	public
  # @param	array
  # @return	void
  #
  libraries: ($libraries) ->
    for $_library in $libraries
      @library($_library)
    return

  #
  # Module Model Loader
  #
  # This function lets users load and instantiate models.
  #
  # @access	public
  # @param	string	the name of the class
  # @param	string	name for the model
  # @param	bool	database connection
  # @return	void
  #
  model: ($model, $object_name = null,$connect = false) ->

    $controller = @controller

    if (is_array($model)) then return @models($model)

    ($_alias = $object_name) or ($_alias = end(explode('/', $model)))

    if in_array($_alias, @_models, true)
      return $controller[$_alias]

    # check module
    [$path, $_model] = Modules.find(strtolower($model), @_module, 'models/')

    if $path is false

      # check application & packages
      @_application_model($model, $object_name)

    else

      class_exists('Exspresso_Model') or load_class('Model', 'core')

      if $connect isnt false and not class_exists('Exspresso_DB')
        if $connect is true then $connect = ''
        @database($connect, false, true)

      $Model = Modules.load_file($_model, $path)
      defineProperty $controller, $_alias,
        enumerable  : true
        writeable   : false
        value       : create_mixin($controller, $Model, $controller)

      @_models.push $_alias

    return $controller[$_alias]

  #
  # Load an array of models
  #
  # @access	public
  # @param	array
  # @return	void
  #
  models: ($models) ->
    for $_model in $models
      @model($_model)
    return

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
  _application_model: ($model, $name = '', $db_conn = false) ->

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

    if in_array($name, @_models, true)
      return

    if @controller[$name]?
      show_error 'The model name you are loading is the name of a resource that is already being used: %s', $name


    for $mod_path in @_model_paths
      if not file_exists($mod_path+'models/'+$path+$model+EXT)
        continue

      if $db_conn isnt false and not class_exists('Exspresso_DB')
        if $db_conn is true then $db_conn = ''
        @controller.load.database $db_conn, false, true

      if not class_exists('Exspresso_Model')
        load_class 'Model', 'core'

      $Model = require($mod_path+'models/'+$path+$model+EXT)
      defineProperty @controller, $name
        enumerable  : true
        writeable   : false
        value       : create_mixin($controller, $Model, $controller)

      @_models.push $name
      return

    # couldn't find the model
    show_error 'Unable to locate the model you have specified: %s', $model
    return

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
    if class_exists('Exspresso_DB') and $return is false and $active_record is null and @controller['db']?
      return false

    $params = $params || Exspresso.server._db

    DB = require(BASEPATH+'database/DB'+EXT)($params, $active_record)

    @controller.queue ($next) -> DB.initialize $next

    if $return is true then return DB #($params, $active_record)

    # Load the DB class
    defineProperty @controller, 'db'
      enumerable  : true
      writeable   : false
      value       : DB

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
      $db = @controller.db
    else
      $db = @database($params, true)

    require(BASEPATH + 'database/DB_forge' + EXT)
    require BASEPATH + 'database/DB_utility'+ EXT
    $class = require(BASEPATH + 'database/drivers/' + $db.dbdriver + '/' + $db.dbdriver + '_utility' + EXT)
    # ex: Exspresso_DB_sqlite_utility

    if $return is true then return new $class(@controller, $db)
    defineProperty @controller, 'dbutil'
      enumerable  : true
      writeable   : false
      value       : new $class(@controller, $db)

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
      $db = @controller.db
    else
      $db = @database($params, true)

    require(BASEPATH + 'database/DB_forge' + EXT)
    $class = require(BASEPATH + 'database/drivers/' + $db.dbdriver + '/' + $db.dbdriver + '_forge' + EXT)

    if $return is true then return new $class(@controller, $db)
    defineProperty @controller, 'dbforge'
      enumerable  : true
      writeable   : false
      value       : new $class(@controller, $db)

  #
  # Load a module controller
  #
  # @access	public
  # @param	string	the name of the class
  # @param	string	name for the model
  # @param	bool	database connection
  # @return	void
  #
  module: ($module, $params = null)	->

    if is_array($module) then return @modules($module)

    $_alias = strtolower(end(explode('/', $module)))
    @controller[$_alias] = Modules.load(array($module , $params))
    return @controller[$_alias]


  #
  # Load an array of controllers
  #
  # @access	public
  # @param	array
  # @return	void
  #
  modules: ($modules) ->
    for $_module in $modules
      @module($_module)
    return

  #
  # Load a module plugin
  #
  # @access	public
  # @param	string	the name of the class
  # @param	string	name for the model
  # @param	bool	database connection
  # @return	void
  #
  plugin: ($plugin)	->

    if (is_array($plugin)) then return @plugins($plugin)

    if not @_plugins? then @_plugins = {}

    if @_plugins[$plugin]?
      return

    [$path, $_plugin] = Modules.find($plugin+'_pi', @_module, 'plugins/')

    if ($path is false) then return

    Modules.load_file($_plugin, $path)
    @_plugins[$plugin] = true

  #
  # Load an array of plugins
  #
  # @access	public
  # @param	array
  # @return	void
  #
  plugins: ($plugins) ->
    for $_plugin in $plugins
      @plugin($_plugin)
    return

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
  view: ($view, $vars = {}, $next = null) ->
    [$path, $view] = Modules.find($view, @controller.module, 'views/')
    @_view_path = if $path then $path else APPPATH + config_item('views')
    @_load('', $view, $vars, $next)

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
        @_cached_vars[$key] = $val
    return


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
  file: ($path, $next) ->
    @_load($path, '', {}, $next)

  #
  # Load a module helper
  #
  # This function loads the specified helper file.
  #
  # @access	public
  # @param	mixed
  # @return	object module reference to the helpers
  #
  helper: ($helper) ->

    if is_array($helper) then return @helpers($helper)

    if @_helpers[$helper]? then return

    [$path, $_helper] = Modules.find($helper+'_helper', @_module, 'helpers/')

    if $path is false then return @_application_helper($helper)

    @_helpers[$_helper] = Modules.load_file($_helper, $path)

    # expose the helpers to template engine
    Exspresso.server.set_helpers @_helpers[$helper]

  #
  # Load an array of helpers
  #
  # @access	public
  # @param	array
  # @return	void
  #
  helpers: ($helpers) ->
    for $_helper in $helpers
      @helper $_helper
    return

  #
  # Load Helper
  #
  # This function loads the specified helper file.
  #
  # @access	public
  # @param	mixed
  # @return	void
  #
  _application_helper: ($helpers = []) ->

    for $helper in @_prep_filename($helpers, '_helper')
      if @_helpers[$helper]?
        continue

      $ext_helper = APPPATH+'helpers/'+config_item('subclass_prefix')+$helper+EXT

      # Is this a helper extension request?
      if file_exists($ext_helper)

        $base_helper = BASEPATH+'helpers/'+$helper+EXT
        if not file_exists($base_helper)
          show_error 'Unable to load the requested file: helpers/%s', $helper+EXT

        @_helpers[$helper] = array_merge(require($base_helper), require($ext_helper))
        log_message 'debug', 'Helper loaded: '+$helper
        continue

      # Try to load the helper
      for $path in @_helper_paths
        if file_exists($path+'helpers/'+$helper+EXT)
          @_helpers[$helper] = require($path+'helpers/'+$helper+EXT)
          log_message 'debug', 'Helper loaded: '+$helper
          break

    # unable to load the helper
    if not @_helpers[$helper]
      show_error 'Unable to load the requested file: helpers/%s', $helper+EXT

    # expose the helpers to template engine
    Exspresso.server.set_helpers @_helpers[$helper]

  #
  # Load a module language file
  #
  # @access	public
  # @param	array
  # @param	string
  # @return	void
  #
  language: ($langfile, $idiom = '', $return = false) ->
    return @controller.lang.load($langfile, $idiom, $return)

  #
  # Load an array of languages
  #
  # @access	public
  # @param	array
  # @return	void
  #
  languages: ($languages) ->
    for $_language in $languages
      @language($language)
    return

  #
  # Loads a config file
  #
  # @access	public
  # @param	string
  # @return	void
  #
  config: ($file = '', $use_sections = false, $fail_gracefully = false) ->

    @controller.config.load $file, $use_sections, $fail_gracefully, @_module


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

  driver: ($library = '', $params = null, $object_name = null) ->

    if not class_exists('Exspresso_Driver_Library')
      # we aren't instantiating an object here, that'll be done by the Library itself
      require BASEPATH+'libraries/Driver'+EXT


    # We can save the loader some time since Drivers will #always# be in a subfolder,
    # and typically identically named to the library
    if $library.indexOf('/') is -1
      $library = ucfirst($library)+'/'+$library

    @library($library, $params, $object_name)

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

    array_unshift(@_library_paths, $path)
    array_unshift(@_model_paths, $path)
    array_unshift(@_helper_paths, $path)

    #  Add config file path
    $config = @_get_component('config')
    array_unshift($config._config_paths, $path)
    return



  #
  # Get Package Paths
  #
  # Return a list of all package paths, by default it will ignore BASEPATH.
  #
  # @access	public
  # @param	string
  # @return	void
  #
  get_package_paths: ($include_base = false) ->
    return if $include_base is true then @_library_paths else @_model_paths


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
  remove_package_path: ($path = '', $remove_config_path = true) ->
    $config = @_get_component('config')

    if $path is ''
      $void = array_shift(@_library_paths)
      $void = array_shift(@_model_paths)
      $void = array_shift(@_helper_paths)
      $void = array_shift($config._config_paths)

    else
      $path = rtrim($path, '/') + '/'

      for $var in ['_library_paths', '_model_paths', '_helper_paths']
        if ($key = array_search($path, @[$var])) isnt false
          delete @[$var][$key]

      if ($key = array_search($path, $config._config_paths)) isnt false
        delete $config._config_paths[$key]

    #  make sure the application default paths are still in the array
    @_library_paths = array_unique(array_merge(@_library_paths, [APPPATH, BASEPATH]))
    @_helper_paths = array_unique(array_merge(@_helper_paths, [APPPATH, BASEPATH]))
    @_model_paths = array_unique(array_merge(@_model_paths, [APPPATH]))
    $config._config_paths = array_unique(array_merge($config._config_paths, [APPPATH]))
    return



  #
  # Loader
  #
  # This function is used to load views and files.
  # Variables are prefixed with _ to avoid symbol collision with
  # variables made available to view files
  #
  # @access	private
  # @param	array
  # @return	void
  #
  _load: ($_path = '', $_view = '', $_vars = {}, $_return = null) ->

    #  Set the path to the requested file
    if $_path is ''
      $_ext = path.extname($_view)
      $_file = if ($_ext is '') then $_view + config_item('view_ext') else $_view
      $_path = rtrim(@_view_path, '/') + '/' + $_file

    else
      $_x = explode('/', $_path)
      $_file = end($_x)


    if not file_exists($_path)
      show_error('Unable to load the requested file: %s', $_file)

    #
    # Extract and cache variables
    #
    # You can either set variables using the dedicated $this->load_vars()
    # function or via the second parameter of this function. We'll merge
    # the two types and cache them so that views that are embedded within
    # other views can have access to these variables.
    #
    if is_array($_vars)
      @_cached_vars = array_merge(@_cached_vars, $_vars)


    @controller.render $_path, @_cached_vars, ($err, $html) =>

      log_message('debug', 'File loaded: ' + $_path)
      if $_return isnt null
        $_return $err, $html
      else
        @controller.output.append_output $html
        @controller.next()

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
  _load_class : ($class, $params = null, $object_name = null) ->
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
        if in_array($subclass, @_loaded_files)
          #  Before we deem this to be a duplicate request, let's see
          #  if a custom object name is being supplied.  If so, we'll
          #  return a new instance of the object
          if not is_null($object_name)
            if not @controller[$object_name]?
              return @_init_class($class, config_item('subclass_prefix'), $params, $object_name)

          $is_duplicate = true
          log_message('debug', $class + " class already loaded. Second attempt ignored.")
          return

        require($baseclass)
        require($subclass)
        @_loaded_files.push $subclass

        return @_init_class($class, config_item('subclass_prefix'), $params, $object_name)


      #  Lets search for the requested library file and load it.
      $is_duplicate = false
      for $path in @_library_paths
        $filepath = $path + 'libraries/' + $subdir + $class + EXT

        #  Does the file exist?  No?  Bummer...
        if not file_exists($filepath)
          continue


        #  Safety:  Was the class already loaded by a previous call?
        if in_array($filepath, @_loaded_files)
          #  Before we deem this to be a duplicate request, let's see
          #  if a custom object name is being supplied.  If so, we'll
          #  return a new instance of the object
          if not is_null($object_name)
            if not @controller[$object_name]?
              return @_init_class($class, '', $params, $object_name)

          $is_duplicate = true
          log_message('debug', $class + " class already loaded. Second attempt ignored.")
          return

        require($filepath)
        @_loaded_files.push $filepath
        return @_init_class($class, '', $params, $object_name)


    #  END FOREACH

    #  One last attempt.  Maybe the library is in a subdirectory, but it wasn't specified?
    if $subdir is ''
      $path = strtolower($class) + '/' + $class
      return @_load_class($path, $params)


    #  If we got this far we were unable to find the requested class.
    #  We do not issue errors if the load call failed due to a duplicate request
    if $is_duplicate is false
      log_message('error', "Unable to load the requested class: %s", $class)
      show_error("Unable to load the requested class: %s", $class)
    return



  #
  # Instantiates a class
  #
  # @access	private
  # @param	string
  # @param	string
  # @param	string	an optional object name
  # @return	null
  #
  _init_class : ($class, $prefix = '', $config = false, $object_name = null) ->

    #  Is there an associated config file for this class?  Note: these should always be lowercase
    if $config is false
      $config = {}
    #  Fetch the config paths containing any package paths
    $config_component = @_get_component('config')
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
      $classvar = if ( not @_varmap[$class]? ) then $class else @_varmap[$class]

    else
      $classvar = $object_name


    $controller = @controller
    #  Save the class name and object name
    @_classes[$class] = $classvar
    #  Instantiate the class
    $Class = global[$name]

    defineProperty $controller, $classvar,
      enumerable  : true
      writeable   : false
      value       : create_mixin($controller, $Class, $controller, $config)

    $controller[$classvar]


  #
  # Autoload module items
  #
  # The config/autoload.php file contains an array that permits sub-systems,
  # libraries, and helpers to be loaded automatically.
  #
  # @access	private
  # @param	array
  # @return	void
  #
  _autoloader:  ->

    @_application_autoloader() # application autoload first
    $path = false

    if (@_module)
      [$path, $file] = Modules.find('autoload', @_module, 'config/')

    #  module autoload file
    $autoload = {}
    if ($path isnt false)
      $autoload = array_merge(Modules.load_file($file, $path, 'autoload'), $autoload)

    #  nothing to do
    if count($autoload) is 0 then return

    #  autoload package paths
    if $autoload['packages']?
      for $package_path in $autoload['packages']
        @add_package_path($package_path)

    #  autoload config
    if $autoload['config']?
      for $config in $autoload['config']
        @config($config)

    #  autoload helpers, plugins, languages
    for $type in ['helper', 'plugin', 'language']
      if $autoload[$type]?
        for $item in $autoload[$type]
          @[$type]($item)

    #  autoload database & libraries
    if $autoload['libraries']?
      if in_array('database', $autoload['libraries'])
        #  autoload database
        if not ($db = @controller.config.item('database'))
          $db['params'] = 'default'
          $db['active_record'] = true

        @database($db['params'], false, $db['active_record'])
        $autoload['libraries'] = array_diff($autoload['libraries'], ['database'])

      #  autoload libraries
      for $library in $autoload['libraries']
        @library($library)

    #  autoload drivers
    if $autoload['drivers']?
      for $driver in $autoload['drivers']
        @driver($driver)


    #  autoload models
    if $autoload['model']?
      for $model, $alias of $autoload['model']
        if is_numeric($model) then @model($alias) else @model($model, $alias)

    #  autoload module controllers
    if $autoload['modules']?
      for $controller in $autoload['modules']
        ($controller isnt @_module) and @module($controller)

    return
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
  _application_autoloader :  ->

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
        @controller.config.load $val

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

    #  autoload drivers
    if $autoload['drivers']?
      for $item in $autoload['drivers']
        @driver $item

    #  Autoload models
    if $autoload['model']?
      @model $autoload['model']

    return

  #
  # Object to Array
  #
  # Takes an object as input and converts the class variables to array key/vals
  #
  # @access	private
  # @param	object
  # @return	array
  #
  _object_to_array : ($object) ->
    $object


  #
  # Get a reference to a specific library or model
  #
  # @access	private
  # @return	bool
  #
  _get_component : ($component) ->
    @controller[$component]


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
  _prep_filename : ($filename, $extension) ->

    if not is_array($filename)
      return [($filename.replace($extension, '').replace(EXT, '') + $extension).toLowerCase()]

    else
      for $key, $val of $filename
        $filename[$key] = ($val.replace($extension, '').replace(EXT, '') + $extension).toLowerCase()

      return $filename

# END Exspresso_Loader class
module.exports = Exspresso_Loader
# End of file Loader.coffee
# Location: ./system/core/Loader.coffee