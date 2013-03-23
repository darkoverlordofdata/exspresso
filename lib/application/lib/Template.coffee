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
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#
#	  Template Class
#
#
#

require SYSPATH+'lib/Parser.coffee'

class application.lib.Template extends system.lib.Parser

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
  _regions            : null
  _breadcrumbs        : null
  _metadata           : null
  _script             : null
  _css                : null


  #
  # constructor
  #
  # @param  [Object]  controller  
  # @param  [Object]  config  configuration array
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
    @_regions = {}
    @_metadata = []
    @_partials = []
    @_breadcrumbs = []
    @_script = []
    @_css = []
    @html = @load.helper('html')
    @parser = @load.library('parser')
    @setTheme @_theme_name


  #
  # Set data name/value pair
  #
  # @param  [String]  name  variable name to set 
  # @param  [Mixed] value the value
  # @return [Object] this
  #
  set: ($name, $value) ->
    if 'string' is typeof($name)
      @_data[$name] = $value
    else
      @_data[$key] = $val for $key, $val of $name
    @


  #
  # Set the theme
  #
  # @param  [String]  theme_name  the name of the theme
  # @return [Array] hash with extra parameters to initialize the theme
  # @return [Object] this
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
  # @param  [String]  layout  name of the layout
  # @return [Object] this
  #
  setLayout: ($layout) ->
    @_layout = $layout
    @

  #
  # Set the title
  #
  # @param  [Array<String>] title array of title segments
  # @return [Object] this
  #
  setTitle: ($title...) ->
    @_title = $title.join(' | ')
    @

  #
  # Set a named partial
  #
  # @param  [String]  name  partial name
  # @param  [String]  view  view filename
  # @param  [Object]  data  hash of data vars
  # @return [Object] this
  #
  setPartial: ($name, $view, $data = {}) ->
    @_partials.push name:$name, view:$view, data:$data
    @

  #
  # Add breadcrumb
  #
  # @param  [String]  name  breadcrumb name
  # @param  [String]  uri uri to associate
  # @return [Object] this
  #
  setBreadcrumb: ($name, $uri = '') ->
    @_breadcrumbs.push name:$name, uri:$uri
    @

  #
  # Set doctype
  #
  # @param  [String]  doctype the html doctype to use
  # @return [Object] this
  #
  setDoctype: ($doctype = 'html5') ->
    @_doctype = $doctype
    @

  #
  # Add css tag
  #
  # @param	[String]  css snippet of css to inject into output
  # @return [Object] this
  #
  setCss:($css) ->

    if 'string' is typeof($css)
      @_css.push $css
    else
      @_css.push $str for $str in $css
    @

  #
  # Add script
  #
  # @param	[String]  script snippet of script to inject into output
  # @return [Object] this
  #
  setScript: ($script) ->

    if 'string' is typeof($script)
      @_script.push $script
    else
      @_script.push $str for $str in $script
    @


  #
  # Add meta tags
  #
  # @param	[String]  meta  html meta tag content
  # @return [Object] this
  #
  setMeta: ($meta) ->

    if 'string' is typeof($meta)
      @_metadata.push $meta
    else
      @_metadata.push $str for $str in $meta
    @


  #
  # Add menu tags
  #
  # @param	[String]  menu  name of the menu to use
  # @return [Object] this
  #
  setMenu: ($menu) ->
    @_menu = $menu
    @


  #
  # render a template
  #
  # @param	[String]  view  view filename
  # @param  [Object] data hash of name/value pairs
  # @param	[Function]  next  async callback
  # @return [Void] this
  #
  view: ($view = '' , $data = {}, $next) =>

    #
    # Collect all of the template bits and build a page
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
    #@set $data
    @_data.__proto__ = $data
    $index = 0

    #
    # Collect the rendering of each partial
    #
    # @access	private
    # @param	function callback
    # @return [Void]  
    #
    get_partials = ($next) =>
      return $next(null) if @_partials.length is 0
      #
      # load the partial at index
      #
      $partial = @_partials[$index]
      @parse $partial.view, $partial.data, ($err, $html) =>
        return $next($err) if $err
        #
        # save the result and get the next
        #
        $region = @theme._regions[$partial.name]
        if @_data[$region]? then @_data[$region] += $html else @_data[$region] = $html
        $index += 1
        return $next(null) if $index is $partials.length
        return get_partials($next)

    #
    # load all partials
    #
    get_partials ($err) =>
      return log_message('error', 'Template::view get_partials %s', $err) if show_error($err)

      #
      # load the body view & render it with the partials
      #
      @parse $view, @_data, ($err, $content) =>
        return log_message('error', 'Template::view load.view %s', $err) if show_error($err)
        #
        # load the main layout for the final render
        #
        @set '$content', $content
        return @parse @_theme_path+@_layout, @_data, $next

  #
  # Menu
  #
  # Main menu
  #
  # @param  [String]
  # @return [Void]  
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
  # @param  [String]
  # @return [Void]  
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
  # @param  [String]
  # @return [Void]  
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