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

  path = require('path')

  _template_cache = {}    # Static template cache

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

    @_name = $theme

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

  #
  # Load additional theme components
  #
  # @access	public
  # @param  [Array]  extra theme elements
  # @return [Object]
  #
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


  #
  # Load the template file names for this theme
  #
  # @access private
  # @param  [String]  theme name of the theme
  # @return [Array<String>] all the templates for theme
  #
  get_template_files: ($theme) ->

    return _template_cache[$theme] if _template_cache[$theme]?
    _template_cache[$theme] = directory_map(APPPATH+"themes/#{$theme}/views", 1)


  #
  # Returns a prioritized list of candidate templates for the type
  #
  # @access private
  # @param  [String]  type base type to generate from
  # @param  [Array<String>] slug  list of specifiers to match
  # @return [Object] struct containing all of the templates that match
  #
  getTemplates: ($type, $slugs = []) ->

    $files = {}
    for $file in @get_template_files(@_name)
      $name = path.basename($file, path.extname($file))
      $files[$name] = $file

    #
    # start with the least specific - just the base type
    #
    $candidates = if $files[$type]? then [$files[$type]] else []

    $pfx = $type
    for $slug in $slugs

      continue if $slug.length is 0

      # If the slug is a number,
      # add the prefix plus "--%" to the list
      if 'number' is typeof($slug)
        if $files["#{$pfx}--%"]?
          $candidates.push $files["#{$pfx}--%"]

      # Regardless of whether the slug is a number or not,
      # add the prefix plus "--" plus the slug to the list
      if $files["#{$pfx}--#{$slug}"]?
        $candidates.push $files["#{$pfx}--#{$slug}"]

      # If the slug is not a number,
      # append "--" plus the slug to the prefix.
      if 'number' isnt typeof($slug)
        $pfx+="--#{$slug}"

    # If the page is the front page
    # add "page--front" to the list
    if @uri.uriString() is '/'
      if $files["#{$type}--front"]?
        $candidates.push $files["#{$type}--front"]

    # Reverse the order, so that [0] is
    # the most specific template found
    $candidates.reverse()
