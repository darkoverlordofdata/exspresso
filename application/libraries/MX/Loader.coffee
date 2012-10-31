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
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#
#
# Modular Extensions - HMVC
#
# Adapted from the CodeIgniter Core Classes
# @link	http://codeigniter.com
#
# Description:
# This library extends the CodeIgniter CI_Loader class
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

Modules = require(dirname(__filename)+'/Modules.coffee')


class global.MX_Loader extends CI_Loader

  _module: {}
  
  _ci_plugins: {}
  _ci_cached_vars: {}
  
  initialize: ($CI, $autoload = false) ->

    super($CI, $autoload)

    #  set the module name
    @_module = CI.$APP.router.fetch_module()

    #  add this module path to the loader variables
    @_add_module_paths(@_module)



  #  Add a module path loader variables *
  _add_module_paths: ($module = '') ->

    if $module is '' #  Load a module config file *
      return

    for  $location, $offset of Modules.locations
      # only add a module path if it exists
      if is_dir($module_path = $location+$module+'/')
        array_unshift(@_ci_model_paths, $module_path)

  # Load a module config file *
  config: ($file = 'config', $use_sections = false, $fail_gracefully = false) ->
    
    CI.$APP.config.load($file, $use_sections, $fail_gracefully, @_module)


  #  Load the database drivers *
  database: ($params = '',$return = false,$active_record = null) ->

    
    if class_exists('CI_DB') and $return is false and $active_record is null and CI.$APP.db?  and is_object(CI.$APP.db)
      return

    DB = require(BASEPATH + 'database/DB' + EXT)

    if $return is true then return DB($params, $active_record)

    CI.$APP.db = DB($params, $active_record)

  # Load a module helper *
  helper: ($helper) ->

    if is_array($helper) then return @helpers($helper)

    if @_ci_helpers[$helper]? then return

    [$path, $_helper] = Modules.find($helper+'_helper', @_module, 'helpers/')

    if $path is false then return super($helper)

    Modules.load_file($_helper, $path)
    @_ci_helpers[$_helper] = true

  # Load an array of helpers *
  helpers: ($helpers) ->
    for $_helper in $helpers
      @helper $_helper

  # Load a module language file *
  language: ($langfile, $idiom = '', $return = false, $add_suffix = true, $alt_path = '') ->
    
    return CI.$APP.lang.load($langfile, $idiom, $return, $add_suffix, $alt_path, @_module)

    
  languages: ($languages) ->
    for $_language in $languages
      @language($language)
      
  #  Load a module library *
  library: ($library, $params = null,$object_name = null) ->


    if is_array($library) then return @libraries($library)

    $class = strtolower(end(explode('/', $library)))

    if @_ci_classes[$class]? and ($_alias = @_ci_classes[$class])
      return CI.$APP.$_alias

    ($_alias = strtolower($object_name)) or ($_alias = $class)

    [$path, $_library] = Modules.find($library, @_module, 'libraries/')

    # load library config file as params *
    if $params is null
      [$path2, $file] = Modules.find($_alias, @_module, 'config/')
      ($path2) and ($params = Modules.load_file($file, $path2, 'config'))


    if $path is false

      @_ci_load_class($library, $params, $object_name)
      $_alias = @_ci_classes[$class]
  
    else

      Modules.load_file($_library, $path)

      $library = ucfirst($_library)
      CI.$APP.$_alias = new (get_class($library)($params))

      @_ci_classes[$class] = $_alias

    return CI.$APP.$_alias

  
  # Load an array of libraries *
  libraries: ($libraries) ->
    for $_library in $libraries
      @library($_library)
    
  
  #  Load a module model *
  model: ($model, $object_name = null,$connect = false) ->
    

    if (is_array($model)) then return @models($model)
  
    ($_alias = $object_name) or ($_alias = end(explode('/', $model)))
    
    if in_array($_alias, @_ci_models, true)
      return CI.$APP.$_alias
    
    # check module *
    [$path, $_model] = Modules.find(strtolower($model), @_module, 'models/')
    
    if $path is false
    
      # check application & packages *
      super($model, $object_name)
    
    else
    
      class_exists('CI_Model') or load_class('Model', 'core')
    
      if $connect isnt false and not class_exists('CI_DB')
        if $connect is true then $connect = ''
        @database($connect, false, true)


      Modules.load_file($_model, $path)

      $model = ucfirst($_model)
      CI.$APP.$_alias = new $model()

      @_ci_models.push $_alias

    return CI.$APP.$_alias

  #* Load an array of models *
  models: ($models) ->
    for $_model in $models
      @model($_model)

  # Load a module controller 
  module: ($module, $params = null)	->
    

    if is_array($module) then return @modules($module)
  
    $_alias = strtolower(end(explode('/', $module)))
    CI.$APP.$_alias = Modules.load(array($module , $params))
    return CI.$APP.$_alias


    # Load an array of controllers
  modules: ($modules) ->
    for $_module in $modules
      @module($_module)

  # Load a module plugin 
  plugin: ($plugin)	->
  
    if (is_array($plugin)) then return @plugins($plugin)
  
    if @_ci_plugins[$plugin]?
      return

    [$path, $_plugin] = Modules.find($plugin+'_pi', @_module, 'plugins/')

    if ($path is false) then return

    Modules.load_file($_plugin, $path)
    @_ci_plugins[$plugin] = true

  # Load an array of plugins 
  plugins: ($plugins) ->
    for $_plugin in $plugins
      @plugin($_plugin)

  _ci_is_instance: ->
    return
  
  _ci_get_component: ($component) ->
    
    return CI.$APP.$component

  # Autoload module items
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
        if not ($db = CI.$APP.config.item('database'))
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

module.exports = MX_Loader

# load the CI class for Modular Separation
(class_exists('CI')) or require dirname(__filename)+'/Ci.coffee'