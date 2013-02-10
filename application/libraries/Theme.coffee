#+--------------------------------------------------------------------+
#| Theme.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	  Theme Class
#
#   Provision a theme
#
#
#
class global.Theme

  _location       : ''
  _path           : ''
  _id             : ''
  _name           : ''
  _author         : ''
  _website        : ''
  _version        : ''
  _description    : ''
  _location       : ''
  _favicon        : ''
  _layout         : null
  _meta           : null
  _script         : null
  _css            : null
  _menu           : null
  Exspresso       : null

  constructor: ($config = {}, @Exspresso) ->

    log_message('debug', "Theme Class Initialized")

    $theme = $config.name ? 'default'
    @load $theme

  #
  # Loads a theme manifest
  #
  #   @access	public
  #   @param	string theme name
  #   @return object
  #
  load: ($theme) ->

    if file_exists(APPPATH + 'themes/all/theme' + EXT)
      $config = require(APPPATH + 'themes/all/theme' + EXT)

    if file_exists(APPPATH + 'themes/' + $theme + '/theme' + EXT)
      $config = array_merge_recursive($config, require(APPPATH + 'themes/' + $theme + '/theme' + EXT))

    @['_'+$key] = $val for $key, $val of $config
    @_path = @_location + $theme + '/theme' + EXT
    
    if not @Exspresso.template?
      @template = @Exspresso.load.library 'template'

    @


  #
  # Initialize a template with theme resources
  #
  #   @access	public
  #   @param	string	template
  #   @param	array   extra theme elements
  #   @return	object
  #
  init: ($template, $extra = []) ->

    $template._metadata = []
    $template._script = []
    $template._css = []
    $template._menu = {}

    if @_layout?
      $template.set_layout @_layout

    if @_menu?
      $template.set_menu @_menu

    if @_meta?
      $template.set_meta @_meta

    if @_css? and @_css.default?
      $template.set_css @_css.default

    if @_script? and @_script.default?
      $template.set_script @_script.default

    if not Array.isArray($extra) then $extra = [$extra]
    if @Exspresso.output._enable_profiler is true
      if $extra.indexOf('prettify') is -1
        $extra.push 'prettify'

    for $name in $extra
      if @_css[$name]?
        $template.set_css @_css[$name]

      if @_script[$name]?
        $template.set_script @_script[$name]
    @

  more: ($extra...) ->

    if @Exspresso.output._enable_profiler is true
      if $extra.indexOf('prettify') is -1
        $extra.push 'prettify'

    for $name in $extra
      if @_css[$name]?
        @Exspresso.template.set_css @_css[$name]

      if @_script[$name]?
        @Exspresso.template.set_script @_script[$name]
    @

module.exports = Theme

# End of file Theme.coffee
# Location: .application/libraries/Theme.coffee