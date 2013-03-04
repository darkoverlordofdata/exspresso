#+--------------------------------------------------------------------+
#| Template.coffee
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
#	  Template Class
#
#
#

class application.lib.Template

  html                : null
  theme               : null

  _title              : ''
  _doctype            : 'html5'
  _layout             : 'layout'
  _theme_name         : 'default'
  _theme_locations    : null
  _menu               : null
  _data               : null
  _partials           : null
  _breadcrumbs        : null
  _metadata           : null
  _script             : null
  _css                : null


  #
  # constructor
  #
  #   @access	public
  #   @return	void
  #
  constructor: ($controller, $config = {}) ->

    # Initialize the config preferences
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    log_message('debug', "Template Class Initialized")

    @_theme_locations = [APPPATH + 'themes/'] if @_theme_locations is null
    @_menu = {}
    @_data = {}
    @_metadata = []
    @_partials = []
    @_breadcrumbs = []
    @_script = []
    @_css = []
    @html = @load.helper('html')
    @setTheme @_theme_name


  #
  # Set data name/value pair
  #
  #   @access	public
  #   @param mixed
  #   @param string
  #   @return	object
  #
  set: ($name, $value) ->
    if is_array($name)
      @_data[$key] = $val for $key, $val of $name
    else
      @_data[$name] = $value
    @


  #
  # Set the theme
  #
  #   @access	public
  #   @param string
  #   @return	object
  #
  setTheme: ($theme_name = 'default', $extra...) ->
    @_theme_name = $theme_name
    for $location in @_theme_locations
      if file_exists($location + @_theme_name)
        @_theme_path = rtrim($location + @_theme_name + '/')
        @theme = @load.library 'theme', location: $location, name: $theme_name
        @theme.init @, $extra
        break
    @


  #
  # Set the layout
  #
  #   @access	public
  #   @param string
  #   @return	object
  #
  setLayout: ($layout) ->
    @_layout = $layout
    @

  #
  # Set the title
  #
  #   @access	public
  #   @param string
  #   @return	object
  #
  setTitle: ($title...) ->
    @_title = $title.join(' | ')
    @

  #
  # Set a named partial
  #
  #   @access	public
  #   @param string
  #   @param string
  #   @param object
  #   @return	object
  #
  setPartial: ($name, $view, $data = {}) ->
    @_partials[$name] = 'view':$view, 'data':$data
    @

  #
  # Add breadcrumb
  #
  #   @access	public
  #   @param string
  #   @param string
  #   @return	object
  #
  setBreadcrumb: ($name, $uri = '') ->
    @_breadcrumbs.push 'name':$name, 'uri':$uri
    @

  #
  # Set doctype
  #
  #   @access	public
  #   @param string
  #   @return	object
  #
  setDoctype: ($doctype = 'html5') ->
    @_doctype = $doctype
    @

  #
  # Add css tag
  #
  #   @access	public
  #   @param	string
  #   @return	object
  #
  setCss:($css) ->

    if is_string($css)
      @_css.push $css
    else
      @_css.push $str for $str in $css
    @

  #
  # Add script
  #
  #   @access	public
  #   @param	object
  #   @return	object
  #
  setScript: ($script) ->

    if is_string($script)
      @_script.push $script
    else
      @_script.push $str for $str in $script
    @


  #
  # Add meta tags
  #
  #   @access	public
  #   @param	string	name
  #   @param	string	content
  #   @param	string	type
  #   @param	string	newline
  #   @return	object
  #
  setMeta: ($meta) ->

    if is_string($meta)
      @_metadata.push $meta
    else
      @_metadata.push $str for $str in $meta
    @


  setMenu: ($menu) ->
    @_menu = $menu
    @


  #
  # render a template
  #
  #   @access	public
  #   @param	string	view
  #   @param	array   data
  #   @param	function callback
  #   @return	void
  #
  view: ($view = '' , $data = {}, $next) =>

    #
    # If the $view is an Error object, show the error as content
    #
    if $view instanceof Error
      $data = {err: new system.core.ExspressoError($view)}
      $view = 'errors'

    #
    # If the $data is an Error object, show the error as content
    #
    if $data instanceof Error
      $data = {err: new system.core.ExspressoError($data)}
      $view = 'errors'

    #
    # Collect all of the template bits
    #
    $script = []
    for $str in @_script
      if $str.substr($str.length-3) is '.js'
        $script.push @html.javascript_tag($str)
      else
        $script.push @html.javascript_decl($str)

    $css = []
    for $str in @_css
      if $str.substr($str.length-4) is '.css'
        $css.push @html.link_tag($str)
      else
        $css.push @html.stylesheet($str)

    @set '$doctype',    @html.doctype(@_doctype)
    @set '$meta',       @html.meta(@_metadata)
    @set '$style',      $css.join("\n")
    @set '$script',     $script.join("\n")
    @set '$title',      @_title
    @set '$menu',       @htmlMenu(@_menu, @uri.segment(1, ''))
    @set 'site_name',   config_item('site_name')
    @set 'site_slogan', config_item('site_slogan')
    @set $data
    $index = 0

    #
    # Collect the rendering of each partial
    #
    #   @access	private
    #   @param	function callback
    #   @return	void
    #
    get_partials = ($next) =>

      return $next(null) if @_partials.length is 0
      #
      # process the partial at index
      #
      $partial = @_partials[$index]
      @load.view $partial.view, $partial.data, ($err, $html) =>

        return $next($err) if $err
        #
        # save the result and do the next
        #
        @_data[$partial.name] = $html
        $index += 1
        if $index is $partials.length then $next null
        else get_partials $next

    #
    # load all partials
    get_partials ($err) =>

      return log_message('error', 'Template::view get_partials %s', $err) if show_error($err)

      #
      # load the body view & merge with partials
      @load.view $view, @_data, ($err, $content) =>

        return log_message('error', 'Template::view load.view %s', $err) if show_error($err)

        #
        # merge the body into the theme layout
        @set '$content', $content
        @render @_theme_path+@_layout, @_data, ($err, $page) =>

          return log_message('error', 'Template::view render %s', $err) if show_error($err)

          return $next(null, $page) if $next?

          @output.setOutput $page
          #
          # ------------------------------------------------------
          #  Send the final rendered output to the browser
          # ------------------------------------------------------
          #
          #if @hooks.callHook('display_override', @) is false
          #  @output.display(@)
          @next()


  #
  # Menu
  #
  # Main menu
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  htmlMenu: ($items, $active) ->

    $k = keys($items)[0]
    $active = '/'+$active

    $menu = "<ul class=\"nav nav-#{$k}\">\n"
    for $name, $val of $items[$k]
      [$uri, $tip] = $val
      if $uri is $active
        $menu+="<li class=\"active\"><a href=\"#{$uri}\">#{$name}</a></li>\n"
      else
        $menu+="<li><a href=\"#{$uri}\" title=\"#{$tip}\">#{$name}</a></li>\n"

    $menu+"</ul>\n"


  #
  # Sidenav
  #
  # side-bar navigation menu
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  htmlSidenav: ($items, $active) ->

    $menu = "<ul class=\"nav nav-list sidenav\">\n"


    for $k, $u of $items
      if $k is $active
        $menu += "<li class=\"active\">"
      else
        $menu += "<li>"
      $menu += "<a href=\"#{$u}\"><i class=\"icon-chevron-right\"></i> #{$k}</a></li>\n"
    $menu += "</ul>\n"

  #
  # Submenu
  #
  # sub menu
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  htmlSubmenu: ($modules, $module) ->

    $active = ucfirst($module)

    $menu = "<ul class=\"nav nav-tabs\">\n"
    for $k, $u of $modules
      if $k is $active
        $menu += "<li class=\"active\">\n"
      else
        $menu += "<li>\n"
      $menu += "<a href=\"#{$u}\" title=\"#{$k}\">#{$k}</a>\n</li>\n"
    $menu += "</ul>\n"




module.exports = application.lib.Template

# End of file Template.coffee
# Location: .application/lib/Template.coffee