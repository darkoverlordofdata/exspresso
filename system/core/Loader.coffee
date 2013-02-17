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
# This file was ported from Modular Extensions - HMVC to coffee-script using php2coffee
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright	Copyright (c) 2011 Wiredesignz
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
# Description:
# This library extends the Exspresso_Loader class
# and adds features allowing use of modules and the HMVC design pattern.
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#


require BASEPATH+'core/Modules.coffee'
require BASEPATH+'core/Base/Loader.coffee'

class global.Exspresso_Loader extends Base_Loader

  __defineProperty    = Object.defineProperty
  __defineProperties          = Object.defineProperties
  __getOwnPropertyDescriptor  = Object.getOwnPropertyDescriptor

  _module             : ''
  _ex_plugins         : null


  constructor: ($controller) ->
    super $controller
    @_module = $controller.module

  #
  # Add a module path
  #
  #
  # @param 	string  module to add
  # @return void
  #
  _add_module_paths: ($module = '') ->

    return if $module is ''

    for  $location, $offset of Modules.locations
      # only add a module path if it exists
      if is_dir($module_path = $location+$module+'/')
        array_unshift(@_ex_model_paths, $module_path)
    return

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

    @controller.config.load($file, $use_sections, $fail_gracefully, @_module)


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

    if @_ex_helpers[$helper]? then return

    [$path, $_helper] = Modules.find($helper+'_helper', @_module, 'helpers/')

    if $path is false then return super($helper)

    @_ex_helpers[$_helper] = Modules.load_file($_helper, $path)

    @_ex_helpers[$helper]
    # expose the helpers to template engine
    Exspresso.server.set_helpers @_ex_helpers[$helper]

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

    if not class_exists('Exspresso_Object')
      require BASEPATH+'core/Object'+EXT

    if is_array($library) then return @libraries($library)

    $class = strtolower(end(explode('/', $library)))

    if @_ex_classes[$class]? and ($_alias = @_ex_classes[$class])
      return @controller[$_alias]

    ($_alias = strtolower($object_name)) or ($_alias = $class)

    [$path, $_library] = Modules.find($library, @controller._module, 'libraries/')

    # load library config file as params *

    [$path2, $file] = Modules.find($_alias, @controller._module, 'config/')
    ($path2) and ($params = array_merge(Modules.load_file($file, $path2, 'config'), $params))

    if $path is false

      @_ex_load_class($library, $params, $object_name)
      $_alias = @_ex_classes[$class]

    else

      Child = ($parent) ->
        @[$key]=$obj for $key, $obj of $parent
        return
      Child:: = @controller

      $library = Modules.load_file($_library, $path)

      @_ex_classes[$class] = $_alias
      __defineProperty @controller, $_alias,
        enumerable  : true
        writeable   : false
        value       : new Child(new $library())

      return @controller[$_alias].__constructor($params)



      $library = Modules.load_file($_library, $path)

      #@controller[$_alias] = new $library(@controller, $params)
      __defineProperty @controller, $_alias,
        enumerable  : true
        writeable   : false
        value       : new $library(@controller, $params)

      @_ex_classes[$class] = $_alias

      if @controller._child?
        # sync with child objects
        for $child in @controller._child
          if not $child[$_alias]?
            __defineProperty $child, $_alias,
              enumerable  : true
              writeable   : false
              value       : @controller[$_alias]

    return @controller[$_alias]






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

    if (is_array($model)) then return @models($model)

    ($_alias = $object_name) or ($_alias = end(explode('/', $model)))

    if in_array($_alias, @_ex_models, true)
      return @controller[$_alias]

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

      $Model = Modules.load_file($_model, $path)

      #@controller[$_alias] = new $model(@controller)
      __defineProperty @controller, $_alias,
        enumerable  : true
        writeable   : false
        value       : new $Model(@controller)

      @_ex_models.push $_alias

      # sync with child objects
      if @controller._child?
        for $child in @controller._child
          if not $child[$_alias]?
            __defineProperty $child, $_alias,
              enumerable  : true
              writeable   : false
              value       : @controller[$_alias]

    return @controller[$_alias]

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

    if not @_ex_plugins? then @_ex_plugins = {}

    if @_ex_plugins[$plugin]?
      return

    [$path, $_plugin] = Modules.find($plugin+'_pi', @_module, 'plugins/')

    if ($path is false) then return

    Modules.load_file($_plugin, $path)
    @_ex_plugins[$plugin] = true

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
  view: ($view, $vars = {}, $next) ->
    [$path, $view] = Modules.find($view, @controller._module, 'views/')
    @_ex_view_path = if $path then $path else APPPATH + config_item('views')
    @_ex_load('', $view, $vars, $next)

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
  _ex_autoloader:  ->

    super() # application autoload first
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

module.exports = Exspresso_Loader

