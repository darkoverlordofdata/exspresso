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
# @see 		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#
# Loader Class
#
# Loads claees, views and other files
#
#
class system.core.Loader

  path = require('path')
  Modules = require(SYSPATH+'core/Modules.coffee')

  _module               : ''    # uri module
  _view_path            : ''    # path to view modules (*.eco)
  _library_paths        : null  # array of paths to libraries
  _model_paths          : null  # array of paths to models
  _helper_paths         : null  # array of paths to helpers
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
  # @param  [system.core.Object]  controller  the parent controller object
  #
  constructor: ($controller)->

    defineProperties @,
      controller      : {enumerable: true, writeable: false, value: $controller}
      
    @_view_path       = APPPATH + config_item('views')
    @_library_paths   = [APPPATH, SYSPATH]
    @_helper_paths    = [APPPATH, SYSPATH]
    @_model_paths     = [APPPATH]
    @_varmap          =
      unit_test       : 'unit'
      user_agent      : 'agent'

    log_message 'debug', "Loader Class Initialized"

  #
  # Perform the autoloads
  #
  # @return [Void]
  #
  initialize: () ->

    defineProperties @,
      _loaded_files   : {enumerable: true, writeable: false, value: []}
      _models         : {enumerable: true, writeable: false, value: []}
      _cached_vars    : {enumerable: true, writeable: false, value: {}}
      _classes        : {enumerable: true, writeable: false, value: {}}
      _helpers        : {enumerable: true, writeable: false, value: {}}

    @_autoloader()
    @

  #
  # Is Loaded
  #
  # A utility function to test if a class is in the self::$_classes array.
  # This function returns the object name if the class tested for is loaded,
  # and returns FALSE if it isn't.
  #
  # It is mainly used in the form_helper _get_validation_object()
  #
  # @param  [String]  class class name being checked for
  # @return [String]  the loaded class object name or FALSE
  #
  isLoaded: ($class) ->
    if @_classes[$class]?
      return @_classes[$class]
    return false

  #
  # Module Class Loader
  #
  # This function lets users load and instantiate classes.
  # It is designed to be called from a user's app controllers.
  #
  # @param  [String]  library the name of the class to load
  # @param  [Object]  params  the optional parameters as a hash
  # @param  [String]  an optional object name
  # @return [Object] the instantiated class
  #
  library: ($library, $params = {}, $object_name = null) ->

    $controller = @controller

    if is_array($library) then return @libraries($library)

    $class = strtolower(end(explode('/', $library)))

    if @_classes[$class]? and ($_alias = @_classes[$class])
      return $controller[$_alias]

    ($_alias = strtolower($object_name)) or ($_alias = $class)

    [$path, $_library] = Modules::find($library, $controller.module, 'lib/')

    # load library config file as params *

    [$path2, $file] = Modules::find($_alias, $controller.module, 'config/')
    ($path2) and ($params = array_merge(Modules::load($file, $path2), $params))
    if $path is false

      @_load_class($library, $params, $object_name)
      $_alias = @_classes[$class]

    else

      $Library = Modules::load($_library, $path)
      @_classes[$class] = $_alias
      defineProperty $controller, $_alias,
        enumerable  : true
        writeable   : false
        value       : create_mixin($controller, $Library, $controller, $params)

    $controller[$_alias]

  #
  # Load an array of libraries
  #
  # @param  [Array] libraries list of class names to load
  # @return [Void]
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
  # @param  [String]  model  the name of the model class to load
  # @param  [String]  object_name  name for the model
  # @return	[Boolean] connect make a database connection?
  # @return [Object] the instantiated class
  #
  model: ($model, $object_name = null, $connect = false) ->

    $controller = @controller

    if (is_array($model)) then return @models($model)

    ($_alias = $object_name) or ($_alias = end(explode('/', $model)).toLowerCase())

    if in_array($_alias, @_models, true)
      return $controller[$_alias]

    # check module
    [$path, $_model] = Modules::find($model, @controller.module, 'models/')

    if $path is false

      # check application & packages
      @_application_model($model, $object_name)

    else

      system.core.Model? or load_class(SYSPATH+'core/Model.coffee')

      if $connect isnt false and not system.db.DbDriver?
        if $connect is true then $connect = ''
        @database($connect, false, true)

      #$Model = Modules::load($_model, $path)
      $Model = load_class($path+$_model)

      defineProperty $controller, $_alias,
        enumerable  : true
        writeable   : false
        value       : create_mixin($controller, $Model, $controller)

      @_models.push $_alias

    $controller[$_alias]

  #
  # Load an array of models
  #
  # @param  [Array] libraries list of model names to load
  # @return [Void]
  #
  models: ($models) ->
    for $_model in $models
      @model($_model)
    return

  #
  # Model Loader
  #
  # If the requested model was not in a module, look in the application path
  #
  # @private
  # @param  [String]  model  the name of the model class to load
  # @param  [String]  object_name  name for the model
  # @return	[Boolean] connect make a database connection?
  # @return [Object] the instantiated class
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

      if $db_conn isnt false and not system.db.DbDriver?
        if $db_conn is true then $db_conn = ''
        @controller.load.database $db_conn, false, true

      system.core.Model? or load_class(SYSPATH+'core/Model.coffee')

      $Model = load_class($mod_path+'models/'+$path+$model+EXT)
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
  # @param  [String]  params  either a resource url specifier or simple the driver name
  # @return	[Boolean]	return  whether to return the DB object
  # @return	[Boolean]	active_record whether to enable active record (this allows us to override the config setting)
  # @return [system.db.Driver]  the connected database driver
  #
  database: ($params = '', $return = false, $active_record = null) ->

    # Do we even need to load the database class?
    if system.db?
      if (system.db.DbDriver? and $return is false and $active_record is null and @controller['db']?)
        return false

    $db = @_db_factory($params || exspresso.dbDriver, $active_record)
    @controller.queue ($next) -> $db.initialize $next

    if $return is true then return $db

    try # defineProperty throws an error here on heroku...

      defineProperty @controller, 'db'
        enumerable  : true
        writeable   : false
        value       : $db
      return

    catch $err
      log_message 'debug', '<--- defineProperty issue handled'

    @controller.db = $db




  #
  # Load the DB Utilities Class
  #
  # @param  [String]  params  either a resource url specifier or simple the driver name
  # @return	[Boolean]	return  whether to return the DB object
  # @return [system.db.Utility]  the connected database utility driver
  #
  dbutil: ($params = '', $return = false) ->

    if $params is ''
      if not system.db.DbDriver?
        @database()
      $db = @controller.db
    else
      $db = @database($params, true)

    load_class SYSPATH + 'db/Forge.coffee'
    load_class SYSPATH + 'db/Utility.coffee'
    $class = load_class(SYSPATH + 'db/drivers/' + $db.dbdriver + '/' + ucfirst($db.dbdriver) + 'Utility' + EXT)

    if $return is true then return new $class(@controller, $db)
    defineProperty @controller, 'dbutil'
      enumerable  : true
      writeable   : false
      value       : new $class(@controller, $db)

  #
  # Load the Database Forge Class
  #
  # @param  [String]  params  either a resource url specifier or simple the driver name
  # @return	[Boolean]	return  whether to return the DB object
  # @return [system.db.Forge]  the connected database forge driver
  #
  dbforge: ($params = '', $return = false) ->

    if $params is ''
      if not system.db.DbDriver?
        @database()
      $db = @controller.db
    else
      $db = @database($params, true)

    load_class SYSPATH + 'db/Forge.coffee'
    $class = load_class(SYSPATH + 'db/drivers/' + $db.dbdriver + '/' + ucfirst($db.dbdriver) + 'Forge' + EXT)

    if $return is true then return new $class(@controller, $db)
    defineProperty @controller, 'dbforge'
      enumerable  : true
      writeable   : false
      value       : new $class(@controller, $db)

  #
  # Load a module plugin
  #
  # @param  [String]  the name of the class
  # @param  [String]  name for the model
  # @return	[Boolean]	database connection
  # @return [Void]
  #
  plugin: ($plugin)	->

    if (is_array($plugin)) then return @plugins($plugin)

    return if @_plugins[$plugin]?

    [$path, $_plugin] = Modules::find($plugin+'_pi', @controller.module, 'plugins/')
    if ($path is false) then return

    Modules::load($_plugin, $path)
    @_plugins[$plugin] = true

  #
  # Load an array of plugins
  #
  # @param  [Array]
  # @return [Void]
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
  # @param  [String]  view  the view tamplate to use
  # @param  [Array] vars  hash of variables to render in the template
  # @param	[Function]  next  the async callback
  # @return [Void]
  #
  view: ($view, $vars = {}, $next = null) ->
    [$path, $view] = Modules::find($view, @controller.module, 'views/')
    @_view_path = if $path then $path else APPPATH + config_item('views')
    @_load('', $view, $vars, $next)

  #
  # Set Variables
  #
  # Once variables are set they become available within
  # the controller class and its "view" files.
  #
  # @param  [String]  vars  the variable name
  # @param  [String]  val the variable value
  # @return [Void]
  #
  vars: ($vars = {}, $val = '') ->
    if $val isnt '' and is_string($vars)
      $vars = array($vars, $val)

    if is_array($vars) and count($vars) > 0
      for $key, $val of $vars
        @_cached_vars[$key] = $val
    return

  #
  # Get Variable
  #
  # Check if a variable is set and retrieve it.
  #
  # @param  [String]  var the variable name
  # @return [Mixed] the variable value
  #
  getVar: ($var) ->
    if isset(@_cached_vars[$var]) then @_cached_vars[$var] else null

  #
  # Load File
  #
  # This is a generic file loader
  #
  # @param  [String]  path  the path to the file
  # @param	[Function]  next  async callback
  # @return	[Void]
  #
  file: ($path, $next) ->
    @_load($path, '', {}, $next)

  #
  # Load a module helper
  #
  # This function loads the specified helper file.
  #
  # @param  [String]  helper  helper name to load
  # @return [Object]  module reference to the helpers
  #
  helper: ($helper) ->

    if is_array($helper) then return @helpers($helper)

    return if @_helpers[$helper]?

    [$path, $_helper] = Modules::find($helper+'_helper', @controller.module, 'helpers/')
    if $path is false then return @_application_helper($helper)

    @_helpers[$_helper] = Modules::load($_helper, $path)

    # expose the helpers to template engine
    @controller.server.setHelpers @_helpers[$helper]

  #
  # Load an array of helpers
  #
  # @param  [Array] helpers an array of helper names to load
  # @return [Void]
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
  # @private
  # @param  [Array] helpers an array of helper names to load
  # @return [Void]
  #
  _application_helper: ($helpers = []) ->

    for $helper in @_prep_filename($helpers, '_helper')
      if @_helpers[$helper]?
        continue

      $ext_helper = APPPATH+'helpers/'+config_item('subclass_prefix')+'_'+$helper+EXT

      # Is this a helper extension request?
      if file_exists($ext_helper)

        $base_helper = SYSPATH+'helpers/'+$helper+EXT
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
    @controller.server.setHelpers @_helpers[$helper]

  #
  # Load a module localization file
  #
  # @param  [String]  langfile  the filename to load
  # @param  [String]  code  the iso code for the desired language
  # @return [Object]  hash table of loaded language keys
  #
  language: ($langfile, $code = '', $return = false) ->
    return @controller.i18n.load($langfile, $code, $return)

  #
  # Load an array of languages
  #
  # @param  [Array] languages an array of language file names to load
  # @return [Void]
  #
  languages: ($languages) ->
    for $_language in $languages
      @language($language)
    return

  #
  # Loads a config file
  #
  # @param  [String]  file  the config file to load
  # @param  [Boolean] use_sections  the use_sections flag
  # @param  [Boolean] fail_gracefully the fail_gracefully flag
  # @return [Void]
  #
  config: ($file = '', $use_sections = false, $fail_gracefully = false) ->

    @controller.config.load $file, $use_sections, $fail_gracefully, @controller.module


  #
  # Driver
  #
  # Loads a driver library
  #
  # @param  [String]  library the name of the driver to load
  # @param  [Object]  params  the optional parameters
  # @param  [String]  object_name an optional object name
  # @return [Object] the loaded object
  #
  driver: ($library = '', $params = null, $object_name = null) ->

    if not system.core.Driver?
      # we aren't instantiating an object here, that'll be done by the Library itself
      load_class SYSPATH+'lib/Driver.coffee'


    # We can save the loader some time since Drivers will #always# be in a subfolder,
    # and typically identically named to the library
    if $library.indexOf('/') is -1
      $library = $library+'/'+ucfirst($library)

    @library($library, $params, $object_name)

  #
  # Add Package Path
  #
  # Prepends a parent path to the library, model, helper, and config path arrays
  #
  # @param  [String]  path  the path to add
  # @return [Void]
  #
  addPackagePath: ($path) ->

    $path = rtrim($path, '/')+'/'

    array_unshift(@_library_paths, $path)
    array_unshift(@_model_paths, $path)
    array_unshift(@_helper_paths, $path)

    #  Add config file path
    array_unshift(@controller.config.paths, $path)
    return



  #
  # Get Package Paths
  #
  # Return a list of all package paths, by default it will ignore SYSPATH.
  #
  # @param  [Boolean] include_base  True will include system classes
  # @return [Array] an array of path strings
  #
  getPackagePaths: ($include_base = false) ->
    return if $include_base is true then @_library_paths else @_model_paths


  #
  # Remove Package Path
  #
  # Remove a path from the library, model, and helper path arrays if it exists
  # If no path is provided, the most recently added path is removed.
  #
  # @param  [String]  path  the path to remove
  # @param  [Boolean] remove_config_path
  # @return [Void]
  #
  removePackagePath: ($path = '', $remove_config_path = true) ->

    if $path is ''
      $void = array_shift(@_library_paths)
      $void = array_shift(@_model_paths)
      $void = array_shift(@_helper_paths)
      $void = array_shift(@controller.config.paths)

    else
      $path = rtrim($path, '/') + '/'

      for $var in ['_library_paths', '_model_paths', '_helper_paths']
        if ($key = array_search($path, @[$var])) isnt false
          delete @[$var][$key]

      if ($key = array_search($path, $config.paths)) isnt false
        delete $config.paths[$key]

    #  make sure the application default paths are still in the array
    @_library_paths = array_unique(array_merge(@_library_paths, [APPPATH, SYSPATH]))
    @_helper_paths = array_unique(array_merge(@_helper_paths, [APPPATH, SYSPATH]))
    @_model_paths = array_unique(array_merge(@_model_paths, [APPPATH]))
    $config.paths = array_unique(array_merge(@controller.config.paths, [APPPATH]))
    return



  #
  # Loader
  #
  # This function is used to load views and files.
  #
  # @private
  # @param  [Array]
  # @return [Void]
  #
  _load: ($path = '', $view = '', $vars = {}, $next = null) ->

    #  Set the path to the requested file
    if $path is ''
      $ext = path.extname($view)
      $file = if ($ext is '') then $view + config_item('view_ext') else $view
      $path = rtrim(@_view_path, '/') + '/' + $file

    else
      $x = explode('/', $path)
      $file = end($x)


    if not file_exists($path)
      show_error('Unable to load the requested file: %s', $file)

    #
    # Extract and cache variables
    #
    # You can either set variables using the dedicated $this->load_vars()
    # function or via the second parameter of this function. We'll merge
    # the two types and cache them so that views that are embedded within
    # other views can have access to these variables.
    #
    if is_array($vars)
      @_cached_vars = array_merge(@_cached_vars, $vars)


    @controller.render $path, @_cached_vars, ($err, $html) =>

      log_message('debug', 'File loaded: ' + $path)
      if $next isnt null
        $next $err, $html
      else
        @controller.output.appendOutput $html
        @controller.next()

  #
  # Load class
  #
  # This function loads the requested class.
  #
  # @private
  # @param  [String]  the item that is being loaded
  # @param  [Mixed]  any additional parameters
  # @param  [String]  an optional object name
  # @return [Void]
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
      $subclass = APPPATH + 'lib/' + $subdir + config_item('subclass_prefix') + $class + EXT

      #  Is this a class extension request?
      if file_exists($subclass)
        $baseclass = SYSPATH + 'lib/' + ucfirst($class) + EXT

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

        load_class $baseclass
        $klass = load_class($subclass)
        @_loaded_files.push $subclass

        return @_init_class($class, config_item('subclass_prefix'), $params, $object_name)


      #  Lets search for the requested library file and load it.
      $is_duplicate = false
      for $path in @_library_paths
        $filepath = $path + 'lib/' + $subdir + $class + EXT

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

        $klass = load_class($filepath)
        @_loaded_files.push $filepath
        return @_init_class($class, '', $params, $object_name, $klass)


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
  # @private
  # @param  [String]
  # @param  [String]
  # @param  [String]  an optional object name
  # @return	null
  #
  _init_class : ($class, $prefix = '', $config = false, $object_name = null, $klass) ->

    #  Is there an associated config file for this class?  Note: these should always be lowercase
    if $config is false
      $config = {}
    #  Fetch the config paths containing any package paths
    if Array.isArray(@controller.config.paths)
      #  Break on the first found file, thus package files
      #  are not overridden by default paths
      for $path in @controller.config.paths
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
      if class_exists('Exspresso' + $class)
        $name = 'Exspresso' + $class

      else if class_exists(config_item('subclass_prefix') + $class)
        $name = config_item('subclass_prefix') + $class

      else
        $name = $class

    else
      $name = $prefix + $class

    #  Is the class name valid?
    #if not class_exists($name)
    #  show_error("Non-existent class: %s", $class)


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

    defineProperty $controller, $classvar,
      enumerable  : true
      writeable   : false
      value       : create_mixin($controller, $klass, $controller, $config)

    $controller[$classvar]


  #
  # Autoload module items
  #
  # The config/autoload.php file contains an array that permits sub-systems,
  # libraries, and helpers to be loaded automatically.
  #
  # @private
  # @param  [Array]
  # @return [Void]
  #
  _autoloader:  ->

    @_application_autoloader() # application autoload first
    $path = false

    if (@controller.module)
      [$path, $file] = Modules::find('autoload', @controller.module, 'config/')

    #  module autoload file
    $autoload = {}
    if ($path isnt false)
      $autoload = array_merge(Modules::load($file, $path), $autoload)

    #  nothing to do
    if count($autoload) is 0 then return

    #  autoload package paths
    if $autoload['packages']?
      for $package_path in $autoload['packages']
        @addPackagePath($package_path)

    #  autoload config
    if $autoload['config']?
      for $config in $autoload['config']
        @controller.config($config)

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
        ($controller isnt @controller.module) and @module($controller)

    return
  #
  # Autoloader
  #
  # The config/autoload.php file contains an array that permits sub-systems,
  # libraries, and helpers to be loaded automatically.
  #
  # @private
  # @param  [Array]
  # @return [Void]
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
        @addPackagePath $package_path

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
  # Prep filename
  #
  # This function preps the name of various items to make loading them more reliable.
  # example:
  #
  #
  # @private
  # @param  [Mixed]
  # @return	array
  #
  _prep_filename : ($filename, $extension) ->

    if not is_array($filename)
      return [($filename.replace($extension, '').replace(EXT, '') + $extension).toLowerCase()]

    else
      for $key, $val of $filename
        $filename[$key] = ($val.replace($extension, '').replace(EXT, '') + $extension).toLowerCase()

      return $filename

  #
  # Database Driver Factory
  #
  #
  _db_factory: ($params = '', active_record_override = null) ->
    #  Load the DB config file if a DSN string wasn't passed
    if is_string($params) and strpos($params, '://') is false
      #  Is the config file in the environment folder?
      if not file_exists($file_path = APPPATH + 'config/' + ENVIRONMENT + '/database' + EXT)
        if not file_exists($file_path = APPPATH + 'config/database' + EXT)
          show_error('The configuration file database%s does not exist.', EXT)

      {db, active_group, active_record} = require($file_path)

      if not db?  or count(db) is 0
        show_error 'No database connection settings were found in the database config file.'

      if $params isnt ''
        active_group = $params

      if not active_group?  or  not db[active_group]?
        show_error 'You have specified an invalid database connection group.'

      $params = db[active_group]

      if db[active_group]['url']?

        if ($dns = parse_url(db[active_group]['url'])) is false
          show_error 'Invalid DB Connection String'

        $params.dbdriver = $dns['scheme']
        $params.hostname = if $dns['host']? then rawurldecode($dns['host']) else ''
        $params.username = if $dns['user']? then rawurldecode($dns['user']) else ''
        $params.password = if $dns['pass']? then rawurldecode($dns['pass']) else ''
        $params.database = if $dns['path']? then rawurldecode(substr($dns['path'], 1)) else ''


    else if is_string($params)

      # parse the URL from the DSN string
      #  Database settings can be passed as discreet
      #  parameters or as a data source name in the first
      #  parameter. DSNs must have this prototype:
      #  $dsn = 'driver://username:password@hostname/database';
      #

      if ($dns = parse_url($params)) is false
        show_error 'Invalid DB Connection String'

      $params =
        dbdriver  : $dns['scheme']
        hostname  : if $dns['host']? then rawurldecode($dns['host']) else ''
        username  : if $dns['user']? then rawurldecode($dns['user']) else ''
        password  : if $dns['pass']? then rawurldecode($dns['pass']) else ''
        database  : if $dns['path']? then rawurldecode(substr($dns['path'], 1)) else ''

      #  were additional config items set?
      if $dns['query']?
        $extra = {}
        parse_str($dns['query'], $extra)

        for $key, $val of $extra
          #  booleans please
          if strtoupper($val) is "TRUE"
            $val = true

          else if strtoupper($val) is "FALSE"
            $val = false

          $params[$key] = $val

    #  No DB specified yet?  Beat them senseless...
    if not $params['dbdriver']?  or $params['dbdriver'] is ''
      show_error('You have not selected a database type to connect to.')

    #  Load the DB classes.  Note: Since the active record class is optional
    #  we need to dynamically create a class that extends proper parent class
    #  based on whether we're using the active record class or not.

    if active_record_override isnt null
      active_record = active_record_override


    DbDriver = load_class(SYSPATH + 'db/Driver.coffee')
    if not active_record?  or active_record is true
      DbActiveRecord = load_class(SYSPATH + 'db/ActiveRecord.coffee')

      if not system.db.DbDriver?
        class system.db.DbDriver extends DbActiveRecord

    else if not system.db.DbDriver?
      class system.db.DbDriver extends DbDriver


    if not file_exists(SYSPATH + 'db/drivers/' + $params['dbdriver'] + '/' + ucfirst($params['dbdriver']) + 'Driver' + EXT)
      throw new Error("Unsuported DB driver: " + $params['dbdriver'])

    $driver = load_class(SYSPATH + 'db/drivers/' + $params['dbdriver'] + '/' + ucfirst($params['dbdriver']) + 'Driver' + EXT)

    #  Instantiate the DB adapter
    $db = new $driver($params)

    if $db.autoinit is true
      $db.initialize()

    if $params['stricton']?  and $params['stricton'] is true
      $db.query('SET SESSION sql_mode="STRICT_ALL_TABLES"')


    return $db


# END Loader class
module.exports = system.core.Loader


# End of file Loader.coffee
# Location: ./system/core/Loader.coffee