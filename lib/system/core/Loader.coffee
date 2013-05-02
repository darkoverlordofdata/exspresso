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
# Loader Class
#
# Loads classes, helpers, models, views, etc.
#
#
module.exports = class system.core.Loader

  querystring = require('querystring')
  path = require('path')
  fs = require('fs')

  _module             : ''      # uri module
  _view_ext           : ''      # the default view file extension
  _model_paths        : null    # array of paths to models (app paths)
  _view_paths         : null    # array of paths to views
  _class_paths        : null    # array of paths to classes (sys paths)
  _classes            : null    # cache of classes loaded by Loader
  _cached_vars        : null    # cache of view data variables
  _loaded_files       : null    # array list of loaded files
  _models             : null    # array list of loaded models
  _helpers            : null    # chache of loaded helpers
  _varmap             : null    # standard object aliases

  #
  # Initiailize the loader search paths
  #
  # @param  [system.core.Object]  controller  the parent controller object
  #
  constructor: ($controller)->

    defineProperties @,
      controller      : {enumerable: true, writeable: false, value: $controller}
      _cached_vars    : {enumerable: true, writeable: false, value: {}}
      _loaded_files   : {enumerable: true, writeable: false, value: []}
      _models         : {enumerable: true, writeable: false, value: []}
      _classes        : {enumerable: true, writeable: false, value: {}}
      _helpers        : {enumerable: true, writeable: false, value: {}}

    @_model_paths = config_item('model_paths')
    @_view_ext = config_item('view_ext')
    @_view_paths = config_item('view_paths')
    @_class_paths = config_item('controller_paths')

    log_message 'debug', "Loader Class Initialized"

  #
  # Class Loader
  #
  # Dynamically loads classes using a standard search convention.
  # Manages loading of the associated configuration.
  #
  # @param  [String]  library the name of the class to load
  # @param  [Object]  params  the optional parameters as a hash
  # @param  [String]  an optional object name
  # @return [Object] the instantiated class
  #
  library: ($library, $params = {}, $object_name = null) ->
    if 'object' is typeof $library
      for $class in $library
        @library $class, $params
      return

    $class = $library.split('/').pop().toLowerCase()
    if @_classes[$class]? and ($alias = @_classes[$class])
      return @controller[$alias]

    ($alias = $object_name?.toLowerCase()) or ($alias = $class)

    @_load_class($library, $params, $object_name)
    $alias = @_classes[$class]
    @controller[$alias]


  #
  # Model Loader
  #
  # Dynamically loads models using a standard search convention.
  # Optionally ensure that the db is connected.
  #
  # @private
  # @param  [String]  model  the name of the model class to load
  # @param  [String]  object_name  name for the model
  # @return	[Boolean] connect make a database connection?
  # @return [Object] the instantiated class
  #
  model: ($model, $name = '', $db_conn = false) ->

    if 'object' is typeof $model
      @model $item for $item in $model
      return
    return if $model is ''

    # Is the model in a sub-folder? If so, parse out the filename and path.
    $subdir = ''
    $last_slash = $model.lastIndexOf('/')
    if $last_slash isnt false
      #  The path is in front of the last slash
      $subdir = $model.substr(0, $last_slash + 1)

      #  And the model name behind it
      $model = $model.substr($last_slash + 1)

    $name = $model.toLowerCase() if $name is ''

    return unless @_models.indexOf($name) is -1

    if @controller[$name]?
      show_error 'The model name you are loading is the name of a resource that is already being used: %s', $name

    for $path in @controller.config.getPaths(@controller.module, @getModelPaths())

      if fs.existsSync($path+'models/'+$subdir+$model+EXT)

        if $db_conn isnt false and not system.db.DbDriver?
          if $db_conn is true then $db_conn = ''
          @controller.load.database $db_conn, false, true

        system.core.Model? or load_class(SYSPATH+'core/Model.coffee')

        $Model = load_class($path+'models/'+$subdir+$model+EXT)
        defineProperty @controller, $name,
          enumerable  : true
          writeable   : false
          value       : magic(@controller, $Model, @controller)

        @_models.push $name
        return @controller[$name]

    # couldn't find the model
    show_error 'Unable to locate the model you have specified: %s', $model
    return

  #
  # Database Loader
  #
  # Dynamically loads the appropriate database driver classes.
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
    @controller.queue ($next) ->
      $db.initialize $next

    return $db if $return is true

    try
      defineProperty @controller, 'db',
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
  # Dynamically loads the appropriate database driver classes.
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
    $class = load_class(SYSPATH + 'db/drivers/' + $db.dbdriver + '/' + ucfirst($db.dbdriver) + 'Utility.coffee')

    if $return is true then return new $class(@controller, $db)
    defineProperty @controller, 'dbutil',
      enumerable  : true
      writeable   : false
      value       : new $class(@controller, $db)

  #
  # Load the Database Forge Class
  #
  # Dynamically loads the appropriate database driver classes.
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
    $class = load_class(SYSPATH + 'db/drivers/' + $db.dbdriver + '/' + ucfirst($db.dbdriver) + 'Forge.coffee')

    if $return is true then return new $class(@controller, $db)
    defineProperty @controller, 'dbforge',
      enumerable  : true
      writeable   : false
      value       : new $class(@controller, $db)

  #
  # Load View
  #
  # Dynamically load a view file, and render it with the $vars hash.
  # By default, the view is rendered, but may also be returned as a string
  # to the async callback function.
  #
  # The view file default extension is '.eco'
  #
  # @param  [String]  view  the view tamplate to use
  # @param  [Array] vars  hash of variables to render in the template
  # @param	[Function]  next  the async callback
  # @return [Void]
  #
  view: ($view, $vars = {}, $next = null) ->

    #
    # If we get an Error object, show it as content
    #
    if $view instanceof Error
      $vars = {err: new system.core.ExspressoError($view)}
      $view = APPPATH+'errors/5xx'
    else if $vars instanceof Error
      $vars = {err: new system.core.ExspressoError($vars)}
      $view = APPPATH+'errors/5xx'

    #
    # Default extendsion: '.eco'
    #
    $ext = path.extname($view)
    $ext = if $ext is '' then @_view_ext else ''

    if $view.charAt(0) is '/'
      #
      # If the path is absolute, just use that
      #
      $pos = $view.lastIndexOf('/')
      $path = $view.substr(0,$pos)
      $view = $view.substr($pos+1)

    else
      #
      # Othewise, we must search for the view file
      #
      $orig = $view # save original view
      $pos = $view.indexOf('/')
      if $pos isnt -1
        #
        # there is a subdir, it could be the module
        #
        $module = $view.substr(0,$pos)
        if @controller.config.modules[$module]?
          $view = $view.substr($pos+1)
        else
          $pos = -1
          $module = @controller.module
      else
        $module = @controller.module

      $path = false
      for $root in @controller.config.getPaths($module, @getViewPaths())

        if fs.existsSync($root+'views/'+$view+$ext)
          $path = $root+'views/'
          break

        if $pos isnt -1
          if fs.existsSync($root+'views/'+$orig+$ext)
            $view = $orig
            $path = $root+'views/'
            break

      if $path is false # then we didn't find it
        if fs.existsSync(APPPATH+'views/'+$orig+$ext)
          $view = $orig
          $path = APPPATH+'views/'

    #
    #  Set the path to the requested file
    #
    $file = $view+$ext
    $path = $path.replace(/[\/]+$/g, '')+'/'+$file # rtrim /

    if not fs.existsSync($path)
      return show_error('Unable to load the requested file: %s', $file)

    @_cached_vars[$key] = $var for $key, $var of $vars

    @controller.render $path, @_cached_vars, ($err, $html) =>

      if $next isnt null
        $next $err, $html
      else
        @controller.output.appendOutput $html
        @controller.next()


  #
  # Set Variables
  #
  # Set variables to use when merging a view to output
  #
  # @param  [String]  vars  the variable name
  # @param  [String]  val the variable value
  # @return [Void]
  #
  vars: ($vars = {}, $val = '') ->
    $vars = array($vars, $val) if typeof $val is 'string' and $val isnt ''

    if 'object' is typeof $vars and Object.keys($vars).length > 0
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
    if @_cached_vars[$var]? then @_cached_vars[$var] else null

  #
  # Load Helper
  #
  # Dynamically loads the helper files
  #
  # @private
  # @param  [Array] helpers an array of helper names to load
  # @return [Void]
  #
  helper: ($helpers) ->

    if 'object' is typeof $helpers
      for $helper in $helpers
        @helper $helper
      return

    $helper = $helpers+'_helper'
    if @_helpers[$helper]?
      return @controller.server.setHelpers @_helpers[$helper]

    #
    # Are we extending a system helper?
    #
    $ext_helper = APPPATH+'helpers/'+config_item('subclass_prefix')+'_'+$helper+EXT
    if fs.existsSync($ext_helper)

      $base_helper = SYSPATH+'helpers/'+$helper+EXT
      if not fs.existsSync($base_helper)
        show_error 'Unable to load the requested base file: helpers/%s', $helper+EXT

      @_helpers[$helper] = require($base_helper)
      # override with 'subclass'
      @_helpers[$helper][$key] = $val for $key, $val of require($ext_helper)
      # export?
      if @_helpers[$helper].is_global is true
        for $name, $body of @_helpers[$helper]
          define $name, $body

      log_message 'debug', 'Helper loaded: '+$helper
      return @controller.server.setHelpers @_helpers[$helper]

    #
    # Search modules, then application
    #
    for $path in @controller.config.getPaths(@controller.module, @getClassPaths())
      if fs.existsSync($path+'helpers/'+$helper+EXT)
        @_helpers[$helper] = require($path+'helpers/'+$helper+EXT)
        # export?
        if @_helpers[$helper].is_global is true
          for $name, $body of @_helpers[$helper]
            define $name, $body
        log_message 'debug', 'Helper loaded: '+$helper
        return @controller.server.setHelpers @_helpers[$helper]

    show_error 'Unable to load the requested file: helpers/%s', $helper+EXT



  #
  # Load an I18n file
  #
  # @param  [String]  langfile  the filename to load
  # @param  [String]  code  the iso code for the desired language
  # @return [Object]  hash table of loaded language keys
  #
  language: ($langfile, $module = @controller.module, $code = '') ->

    if 'object' is typeof $langfile
      for $file in $langfile
        @languange $file, $module, $code
      return

    @controller.i18n.load($langfile, $module, $code)


  #
  # Load a config file
  #
  # @param  [String]  file  the config file to load
  # @param  [Boolean] use_sections  the use_sections flag
  # @param  [Boolean] fail_gracefully the fail_gracefully flag
  # @return [Void]
  #
  config: ($file = '', $use_sections = false, $fail_gracefully = false) ->
    @controller.config.load($file, $use_sections, $fail_gracefully, @controller.module)


  #
  # Driver
  #
  # Load a driver library
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
    $library = $library+'/'+ucfirst($library) if $library.indexOf('/') is -1

    @library($library, $params, $object_name)

  #
  # Add Module Path
  #
  # Adds a module path to the loader paths
  #
  # @param  [String]  path  the path to add
  # @return [Void]
  #
  addModulePath: ($path) ->

    $path = $path.replace(/[\/]+$/g, '')+'/'

    @_model_paths.unshift $path if @_model_paths.indexOf($path) is -1
    @_view_paths.unshift $path if @_view_paths.indexOf($path) is -1
    @_class_paths.unshift $path if @_class_paths.indexOf($path) is -1
    #
    #  Add to config file paths
    #
    @controller.config.paths.unshift $path if @controller.config.paths.indexOf($path) is -1
    return

  #
  # Get Model Paths
  #
  # Gets the loader paths array for models
  #
  # @return [Array] an array of path strings
  #
  getModelPaths:() -> @_model_paths

  #
  # Get View Paths
  #
  # Gets the loader paths array for views
  #
  # @return [Array] an array of path strings
  #
  getViewPaths: () -> @_view_paths

  #
  # Get Class Paths
  #
  # Gets the loader paths array for classes
  #
  # @return [Array] an array of path strings
  #
  getClassPaths:() -> @_class_paths

  #
  # Remove Module Path
  #
  # Remove a module path from the loader paths
  #
  # @param  [String]  path  the path to remove
  # @param  [Boolean] remove_config_path
  # @return [Void]
  #
  removeModulePath: ($path = '') ->

    if $path is ''
      @_class_paths.shift()
      @_model_paths.shift()
      @_view_paths.shift()
      @controller.config.paths.shift()

    else
      $path = $path.replace(/[\/]+$/g, '')+'/' # rtrim /

      for $var in ['_class_paths', '_model_paths', '_view_paths']
        for $key, $val of @[$var]
          if $val is $path
            delete @[$var][$key]
            break

      for $key, $val of $config.paths
        if $val is $path
          delete $config.paths[$key]
          break

    #
    #  make sure the core paths don't get clobered
    #
    @_model_paths.unshift APPPATH if @_model_paths.indexOf(APPPATH) is -1
    @_view_paths.unshift APPPATH+'views/' if @_view_paths.indexOf(APPPATH+'views/') is -1
    @_view_paths.unshift APPPATH+'themes/default/views/' if @_view_paths.indexOf(APPPATH+'themes/default/views/') is -1
    @_class_paths.unshift SYSPATH if @_class_paths.indexOf(SYSPATH) is -1

    @controller.config.paths.unshift APPPATH if @controller.config.paths.indexOf(APPPATH) is -1

    return

  #
  # Load class
  #
  # Load a class, searching standard locations
  #
  # @private
  # @param  [String]  the item that is being loaded
  # @param  [Mixed]  any additional parameters
  # @param  [String]  an optional object name
  # @return [Void]
  #
  _load_class : ($class, $params = null, $object_name = null) ->
    $class = ltrim($class, '/').replace(EXT, '')

    $subdir = ''
    if ($last_slash = $class.lastIndexOf('/')) isnt -1
      # split the subdir and class name
      $subdir = $class.substr(0, $last_slash + 1)
      $class = $class.substr($last_slash + 1)
    $class = ucfirst($class)

    #
    # Subclass a system class?
    #
    $subclass = APPPATH + 'lib/' + $subdir + config_item('subclass_prefix') + $class + EXT
    if fs.existsSync($subclass)
      $baseclass = SYSPATH + 'lib/' + $class + EXT

      if not fs.existsSync($baseclass)
        log_message('error', "Unable to load the requested class: %s", $class)
        show_error("Unable to load the requested class: %s", $class)

      if @_loaded_files.indexOf($subclass) isnt -1
        if $object_name?
          if not @controller[$object_name]?
            return @_init_class(APPPATH, $class, config_item('subclass_prefix'), $params, $object_name)

        $is_duplicate = true
        return

      load_class $baseclass
      $klass = load_class($subclass)
      @_loaded_files.push $subclass
      return @_init_class(APPPATH, $class, config_item('subclass_prefix'), $params, $object_name)

    #
    # Search for class
    #
    $is_duplicate = false
    for $path in @controller.config.getPaths(@controller.module, @getClassPaths())
      $filepath = $path + 'lib/' + $subdir + $class + EXT

      if fs.existsSync($filepath)
        if @_loaded_files.indexOf($filepath) isnt -1
          if $object_name?
            if not @controller[$object_name]?
              return @_init_class($path, $class, '', $params, $object_name)

          $is_duplicate = true
          return

        $klass = load_class($filepath)
        @_loaded_files.push $filepath
        return @_init_class($path, $class, '', $params, $object_name, $klass)

    #
    # Is the class in a subdir
    #
    if $subdir is ''
      $path = $class.toLowerCase() + '/' + $class
      return @_load_class($path, $params)

    #
    # Not found
    #
    return show_error("Unable to load the requested class: %s", $class) unless $is_duplicate
    return

  #
  # Instantiates a class and set the initial values from config
  #
  # @private
  # @param  [String]  path  the path the class was found in
  # @param  [String]  class the class name
  # @param  [String]  prefix  the subclass prefix (unused?)
  # @param  [Object]  config  the config params
  # @param  [String]  an optional object name
  # @param  [Object]  klass the class object
  # @return	[Object] the new instance
  #
  _init_class : ($path, $class, $prefix = '', $params = {}, $object_name = null, $klass) ->

    $config = {}

    # if not found in classpath, fallback to apppath
    $paths = if $path is APPPATH then [APPPATH] else [$path, APPPATH]
    for $path in $paths
      if fs.existsSync($path + 'config/' + $class.toLowerCase() + EXT)
        $config[$key] = $val for $key, $val of require($path + 'config/' + $class.toLowerCase() + EXT)

        if fs.existsSync($path + 'config/' + ENVIRONMENT + '/' + $class.toLowerCase() + EXT)
          $config[$key] = $val for $key, $val of require($path + 'config/' + ENVIRONMENT + '/' + $class.toLowerCase() + EXT)
        break

    $config[$key] = $val for $key, $val of $params

    #  Set the variable name we will assign the class to
    #  Was a custom class name supplied?  If so we'll use it
    $class = $class.toLowerCase()

    $classvar = if $object_name is null then $class else $object_name


    $controller = @controller
    #  Save the class name and object name
    @_classes[$class] = $classvar
    #  Instantiate the class

    defineProperty $controller, $classvar,
      enumerable  : true
      writeable   : false
      value       : magic($controller, $klass, $controller, $config)

    $controller[$classvar]


  #
  # Initialize
  #
  # Autoload the specified resources
  #
  # @return [Void]
  #
  initialize:  ->

    $autoload = {}
    if fs.existsSync(APPPATH + 'config/autoload.coffee')
      $autoload[$key] = $val for $key, $val of require(APPPATH + 'config/autoload.coffee')

    if fs.existsSync(APPPATH + 'config/' + ENVIRONMENT + '/autoload.coffee')
      $autoload[$key] = $val for $key, $val of require(APPPATH + 'config/' + ENVIRONMENT + '/autoload.coffee')

    return if Object.keys($autoload).length is 0

    #  Autoload packages
    if $autoload['packages']?
      for $package_path in $autoload['packages']
        @addModulePath $package_path

    #  Load any custom config file
    if $autoload['config']?
      for $config in $autoload['config']
        @controller.config($config)

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
  # Database Driver Factory
  #
  #
  _db_factory: ($params = '', active_record_override = null) ->
    #  Load the DB config file if a DSN string wasn't passed
    if 'string' is typeof($params)
      if $params.indexOf('://') is -1
        #  Is the config file in the environment folder?
        if not fs.existsSync($file_path = APPPATH + 'config/' + ENVIRONMENT + '/database.coffee')
          if not fs.existsSync($file_path = APPPATH + 'config/database.coffee')
            show_error('The configuration file database.coffee does not exist.')

      {db, active_group, active_record} = require($file_path)

      if not db?  or Object.keys(db).length is 0
        show_error 'No database connection settings were found in the database config file.'

      if $params isnt ''
        active_group = $params

      if not active_group? or not db[active_group]?
        show_error 'Invalid database connection group.'

      $params = db[active_group]

      if db[active_group]['url']?

        if ($dns = parse_url(db[active_group]['url'])) is false
          show_error 'Invalid DB Connection String'

        $params.dbdriver = $dns['scheme']
        $params.hostname = if $dns['host']? then rawurldecode($dns['host']) else ''
        $params.username = if $dns['user']? then rawurldecode($dns['user']) else ''
        $params.password = if $dns['pass']? then rawurldecode($dns['pass']) else ''
        $params.database = if $dns['path']? then rawurldecode($dns['path'].substr(1)) else ''


    else if 'string' is typeof($params)

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
        database  : if $dns['path']? then rawurldecode($dns['path'].substr(1)) else ''

      # additional items?
      if $dns['query']?

        $extra = querystring.parse($dns['query'])

        for $key, $val of $extra
          if $val.toUpperCase() is "TRUE"
            $val = true
          else if $val.toUpperCase() is "FALSE"
            $val = false
          $params[$key] = $val

    if not $params['dbdriver']?  or $params['dbdriver'] is ''
      show_error('DB Connection not specified.')

    if active_record_override isnt null
      active_record = active_record_override

    DbDriver = load_class(SYSPATH + 'db/Driver.coffee')
    if not active_record?  or active_record is true
      DbActiveRecord = load_class(SYSPATH + 'db/ActiveRecord.coffee')
      if not system.db.DbDriver?
        class system.db.DbDriver extends DbActiveRecord

    else if not system.db.DbDriver?
      class system.db.DbDriver extends DbDriver

    if not fs.existsSync(SYSPATH + 'db/drivers/' + $params['dbdriver'] + '/' + ucfirst($params['dbdriver']) + 'Driver.coffee')
      throw new Error("Unsuported DB driver: " + $params['dbdriver'])

    $driver = load_class(SYSPATH + 'db/drivers/' + $params['dbdriver'] + '/' + ucfirst($params['dbdriver']) + 'Driver.coffee')

    #  Instantiate the DB adapter
    $db = new $driver($params, @controller)

    if $db.autoinit is true
      $db.initialize()

    if $params['stricton']?  and $params['stricton'] is true
      $db.query('SET SESSION sql_mode="STRICT_ALL_TABLES"')

    return $db

