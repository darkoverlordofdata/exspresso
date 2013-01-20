#+--------------------------------------------------------------------+
#  Loader.coffee
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
# This file was ported from Wiredesignz to coffee-script using php2coffee
#
#
#
# Modular Extensions - HMVC
#
# Adapted from the Exspresso Core Classes
# @link	http://darkoverlordofdata.com
#
# Description:
# This library extends the Exspresso_Loader class
# and adds features allowing use of modules and the HMVC design pattern.
#
# Install this file as application/third_party/MX/Loader.php
#
# @copyright	Copyright (c) 2011 Wiredesignz
# @version 	5.4
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE and NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

require BASEPATH+'core/Modules.coffee'

class global.Exspresso_Loader_hmvc extends Exspresso_Loader

  #
  # Module state
  #
  # @var array
  #
  _module: {}
  #
  # List of paths to load plugins from
  #
  # @var array
  #
  _ci_plugins: {}
  #
  # List of variables for rendering templates
  #
  # @var array
  #
  _ci_cached_vars: {}

  ## --------------------------------------------------------------------

  #
  # Initialize the Loader
  #
  #
  # @param 	object  controller instance
  # @param  boolean call autoload
  # @return object
  #
  initialize: ($CI, $autoload = false) ->

    super($CI, $autoload)

    #  set the module name
    @_module = $CI.router.fetch_module()
    #@_module = $CI._module

    #  add this module path to the loader variables
    @_add_module_paths(@_module)


  ## --------------------------------------------------------------------

  #
  # Add a module path loader variables
  #
  #
  # @param 	string  module to add
  # @return void
  #
  _add_module_paths: ($module = '') ->

    if $module is '' #  Load a module config file *
      return

    for  $location, $offset of Modules.locations
      # only add a module path if it exists
      if is_dir($module_path = $location+$module+'/')
        array_unshift(@_ci_model_paths, $module_path)

  ## --------------------------------------------------------------------

  #
  # Load a module config file
  #
  #
  # @param  string  filename
  # @param  boolean loads each config file into a sub-array
  # @param  boolean don't raise hard errors
  # @return object the configration array that was loaded
  #
  config: ($file = 'config', $use_sections = false, $fail_gracefully = false) ->

    @CI.config.load($file, $use_sections, $fail_gracefully, @_module)


  ## --------------------------------------------------------------------

  #
  # Load a module database
  #
  # @access	public
  # @param	string	the DB credentials
  # @param	bool	whether to return the DB object
  # @param	bool	whether to enable active record (this allows us to override the config setting)
  # @return	object
  #
  database: ($params = '',$return = false, $active_record = null) ->


    if class_exists('Exspresso_DB') and $return is false and $active_record is null and @CI.db?  and is_object(@CI.db)
      return

    $params = $params || Exspresso__DB

    DB = require(BASEPATH + 'database/DB' + EXT)($params, $active_record)

    @CI._ctor.push ($callback) -> DB.initialize $callback

    if $return is true then return DB #($params, $active_record)

    @CI.db = DB #($params, $active_record)

  ## --------------------------------------------------------------------

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

    if @_ci_helpers[$helper]? then return

    [$path, $_helper] = Modules.find($helper+'_helper', @_module, 'helpers/')

    if $path is false then return super($helper)

    @_ci_helpers[$_helper] = Modules.load_file($_helper, $path)

    # expose the helpers to template engine
    # for $name, $value of @_ci_helpers[$helper]
    #   Exspresso.server.app.locals[$name] = $value

    @_ci_helpers[$helper]

  ## --------------------------------------------------------------------

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

  ## --------------------------------------------------------------------

  #
  # Load a module language file
  #
  # @access	public
  # @param	array
  # @param	string
  # @return	void
  #
  language: ($langfile, $idiom = '', $return = false, $add_suffix = true, $alt_path = '') ->
    return @CI.lang.load($langfile, $idiom, $return, $add_suffix, $alt_path, @_module)


  ## --------------------------------------------------------------------

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

  ## --------------------------------------------------------------------

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
  library: ($library, $params = null, $object_name = null) ->

    if is_array($library) then return @libraries($library)

    $class = strtolower(end(explode('/', $library)))

    if @_ci_classes[$class]? and ($_alias = @_ci_classes[$class])
      return @CI[$_alias]

    ($_alias = strtolower($object_name)) or ($_alias = $class)

    [$path, $_library] = Modules.find($library, @CI._module, 'libraries/')

    # load library config file as params *
    if $params is null
      $params = {}

    [$path2, $file] = Modules.find($_alias, @CI._module, 'config/')
    ($path2) and ($params = array_merge(Modules.load_file($file, $path2, 'config'), $params))

    if $path is false

      @_ci_load_class($library, $params, $object_name)
      $_alias = @_ci_classes[$class]

    else

      $library = Modules.load_file($_library, $path)

      @CI[$_alias] = new $library($params, @CI)

      @_ci_classes[$class] = $_alias

    return @CI[$_alias]


  ## --------------------------------------------------------------------

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


  ## --------------------------------------------------------------------

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

    if (is_array($model)) then return @models($model)

    ($_alias = $object_name) or ($_alias = end(explode('/', $model)))

    if in_array($_alias, @_ci_models, true)
      return @CI[$_alias]

    # check module *
    [$path, $_model] = Modules.find(strtolower($model), @_module, 'models/')

    if $path is false

      # check application & packages *
      super($model, $object_name)

    else

      class_exists('Exspresso_Model') or load_class('Model', 'core')

      if $connect isnt false and not class_exists('Exspresso_DB')
        if $connect is true then $connect = ''
        @database($connect, false, true)


      $model = Modules.load_file($_model, $path)

      @CI[$_alias] = new $model(@CI)

      @_ci_models.push $_alias

    return @CI[$_alias]

  ## --------------------------------------------------------------------

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

  ## --------------------------------------------------------------------

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
    @CI[$_alias] = Modules.load(array($module , $params))
    return @CI[$_alias]


  ## --------------------------------------------------------------------

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

  ## --------------------------------------------------------------------

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

    if @_ci_plugins[$plugin]?
      return

    [$path, $_plugin] = Modules.find($plugin+'_pi', @_module, 'plugins/')

    if ($path is false) then return

    Modules.load_file($_plugin, $path)
    @_ci_plugins[$plugin] = true

  ## --------------------------------------------------------------------

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

  #  --------------------------------------------------------------------

  #
  # Load a module View
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
  view: ($view, $vars = {}, $callback) ->
    [$path, $view] = Modules.find($view, @CI._module, 'views/')
    @_ci_view_path = if $path then $path else APPPATH + config_item('views')
    @_ci_load('', $view, $vars, $callback)

  #  --------------------------------------------------------------------

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
  _autoloader: ($autoload) ->

    $path = false

    if (@_module)
      [$path, $file] = Modules.find('autoload', @_module, 'config/')

    #  module autoload file
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
        if not ($db = @CI.config.item('database'))
          $db['params'] = 'default'
          $db['active_record'] = true

        @database($db['params'], false, $db['active_record'])
        $autoload['libraries'] = array_diff($autoload['libraries'], ['database'])

      #  autoload libraries
      for $library in $autoload['libraries']
        @library($library)

    #  autoload models
    if $autoload['model']?
      for $model, $alias of $autoload['model']
        if is_numeric($model) then @model($alias) else @model($model, $alias)

    #  autoload module controllers
    if $autoload['modules']?
      for $controller in $autoload['modules']
        ($controller isnt @_module) and @module($controller)

module.exports = Exspresso_Loader_hmvc

