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
#	  Theme Class
#
#   Provision a theme
#
#
#

module.exports = class application.lib.Theme

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
  _regions        : null
  _meta           : null
  _script         : null
  _css            : null
  _menu           : null

  constructor: ($controller, $config = {}) ->

    # Initialize the config preferences
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    log_message('debug', "Theme Class Initialized")

    $theme = @_name ? 'default'
    @loadTheme $theme

  #
  # Loads a theme manifest
  #
  # @access	public
  # @param	string theme name
  # @return [Object]
  #
  loadTheme: ($theme) ->

    if file_exists(APPPATH + 'themes/' + $theme + '/theme.coffee')
      $config = require(APPPATH + 'themes/' + $theme + '/theme.coffee')

    if file_exists(APPPATH + 'themes/all/theme.coffee')
      $config.__proto__ = require(APPPATH + 'themes/all/theme.coffee')

    @['_'+$key] = $val for $key, $val of $config
    @_path = @_location + $theme + '/theme.coffee'
    
    @


  #
  # Initialize a template with theme resources
  #
  # @access	public
  # @param	string	template
  # @param  [Array]  extra theme elements
  # @return [Object]
  #
  init: ($template, $extra = []) ->

    @template = $template
    $template._metadata = []
    $template._script = []
    $template._css = []
    $template._menu = {}

    if @_layout?
      $template.setLayout @_layout

    if @_menu?
      $template.setMenu @_menu

    if @_meta?
      $template.setMeta @_meta

    if @_css? and @_css.default?
      $template.setCss @_css.default

    if @_script? and @_script.default?
      $template.setScript @_script.default

    if not Array.isArray($extra) then $extra = [$extra]
    if @output._enable_profiler is true
      if $extra.indexOf('prettify') is -1
        $extra.push 'prettify'

    for $name in $extra
      if @_css[$name]?
        $template.setCss @_css[$name]

      if @_script[$name]?
        $template.setScript @_script[$name]
    @

  more: ($extra...) ->

    if @output._enable_profiler is true
      if $extra.indexOf('prettify') is -1
        $extra.push 'prettify'

    for $name in $extra
      if @_css[$name]?
        @template.setCss @_css[$name]

      if @_script[$name]?
        @template.setScript @_script[$name]
    @


