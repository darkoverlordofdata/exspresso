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

require SYSPATH+'lib/Parser.coffee'


#
#	  Template Class
#
#   Renders the custom data in a standard template layout.
#
#   Standard template variables/regions:
#   -------------------------------------------
#   $doctype      html doctype (default: html5)<br />
#   $meta         meta tags<br />
#   $style        css tags<br />
#   $script       javascript tags<br />
#   $title        html title tag<br />
#   $site_name    displayed in banner<br />
#   $site_slogan  displayed in banner<br />
#   $menu         main menu<br />
#   $sidenav      optional sub menu<br />
#   $content      the floor show<br />
#   $flash        session flashdata messages<br />
#
#
module.exports = class application.lib.Template extends system.lib.Parser

  path = require('path')

  _template_cache     = {}    # Static template cache


  html                : null
  theme               : null
  breadcrumb          : null

  _logo               : config_item('logo')
  _title              : config_item('site_name')
  _site_name          : config_item('site_name')
  _site_slogan        : config_item('site_slogan')
  _doctype            : 'html5'
  _layout             : 'html'
  _theme_name         : 'default'
  _theme_locations    : null
  _menu               : null
  _data               : null
  _partials           : null
  _regions            : null
  _metadata           : null
  _script             : null
  _css                : null
  _admin              : false
  _active             : ''
  _index              : 0


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
    @_script = []
    @_css = []
    @html = @load.helper('html')
    @parser = @load.library('parser')
    @blockmodel = @load.model('BlockModel')
    @setTheme @_theme_name
    for $reg, $val of @theme._regions
      @_regions[$reg] = $val


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
    $ = if $name.charAt(0) is '$' then '' else '$'
    @_partials.push region:$+$name, view:$view, data:$data
    @

  #
  # Add breadcrumb
  #
  # @param  [String]  name  breadcrumb name
  # @param  [String]  uri uri to associate
  # @return [Object] this
  #
  setBreadcrumb: ($name, $uri, $level) ->
    if @breadcrumb is null then @load.library('breadcrumb')
    @breadcrumb.add $name, $uri, $level
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
  # Use admin menu
  #
  # @param	[String]  active  the active menu selection
  # @return [Object] this
  #
  setAdminMenu: ($active) ->
    @_admin = true
    @_active = $active
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
    # get the template layout & partials
    #
    $tmp = @load_templates(@_theme_name)
    @_layout = $tmp.html
    @_partials = $tmp.regions

    #
    # Client scripts
    #
    $script = []
    for $str in @_script
      if $str.substr(-3) is '.js'
        $script.push @html.javascript_tag($str)
      else
        $script.push @html.javascript_decl($str)

    #
    # Style sheets & css
    #
    $css = []
    for $str in @_css
      if $str.substr(-4) is '.css'
        $css.push @html.link_tag($str)
      else
        $css.push @html.stylesheet($str)

    #
    # Admin menu?
    #
    if @_admin
      $admin_menu = Dashboard: '/admin'
      for $name, $module of @config.modules
        if $module.active
          $admin_menu[$module.name] = '/admin/'+$name

    #
    # define standard template variables
    #
    @set
      $doctype          : if @_doctype then @html.doctype(@_doctype) else 'html5'
      $meta             : if @_metadata then @html.meta(@_metadata) else ''
      $style            : $css.join("\n")
      $script           : $script.join("\n")
      $title            : @_title
      $logo             : @_logo
      $site_name        : @_site_name
      $site_slogan      : @_site_slogan
      $menu             : if keys(@_menu).length>0 then @htmlMenu(@_menu, @uri.segment(1, '')) else ''
      $breadcrumb       : if @breadcrumb? then @breadcrumb.output() else ''
      $sidenav          : if @_admin then @htmlSidenav($admin_menu, @_active) else ''
      $flash            : @htmlFlash()
      $sidebar_first    : ''
      $sidebar_second   : ''
      $profile          : if @output._enable_profiler then system.lib.Profiler::button else ''

    @_data.__proto__ = $data

    @blockmodel.getByTheme @_theme_name, ($err, $blocks) =>
      $blocks =  if $err? then [] else $blocks

      #
      # First render the blocks
      #
      for $block in $blocks

        $html = @parseString($block.content, @_data, true)
        #
        # TODO: Is there a block template? Then apply it here.
        #
        if @_data[$block.region]? then @_data[$block.region] += $html else @_data[$block.region] = $html

      #
      # Then render the partials
      #
      @_index = 0
      @_parse_partials ($err) =>
        return log_message('error', 'Template::view get_partials %s', $err) if show_error($err)

        #
        # Next render the main content
        #
        @parse $view, @_data, ($err, $content) =>
          return log_message('error', 'Template::view load.view %s', $err) if show_error($err)
          #
          # Lastly, render the container
          #
          @set '$content', $content
          return @parse @_theme_path+'views/'+@_layout, @_data, $next


  #
  # Collect the rendering of each partial -
  # header, footer, etc.
  #
  # @access	private
  # @param	[Function]  next  async callback
  # @return [Void]
  #
  _parse_partials: ($next) =>
    return $next(null) if @_partials.length is 0
    #
    # load the partial at index
    #
    $partial = @_partials[@_index]
    @parse $partial.view, @_data, ($err, $html) =>
      return $next($err) if $err
      #
      # save the result and get the next
      #
      if @_data[$partial.region]? then @_data[$partial.region] += $html else @_data[$partial.region] = $html
      @_index += 1
      return $next(null) if @_index is @_partials.length
      return @_parse_partials($next)

  #
  # Menu
  #
  # Main menu
  #
  # @param  [Object]  items hash of menu items
  # @param  [String]  active  the active menu item
  # @return [String]  the html
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
  # @param  [Object]  items hash of menu items
  # @param  [String]  active  the active menu item
  # @return [String]  the html
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
  # @param  [Object]  items hash of menu items
  # @param  [String]  active  the active menu item
  # @return [String]  the html
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


  #
  # Flash
  #
  # Create the html for flash messages
  #
  # @return [String]  the html
  #
  htmlFlash: () ->

    $flash = []
    $msg = @session.flashdata('error')
    if $msg isnt false
      $flash.push "<div class='alert alert-error'>"
      $flash.push "<p><b>Error:</b> #{$msg}</p>"
      $flash.push "</div>"

    $msg = @session.flashdata('info')
    if $msg isnt false
      $flash.push "<div class='alert alert-info'>"
      $flash.push "<p><b>Info:</b> #{$msg}</p>"
      $flash.push "</div>"

    $flash.join('')


  #
  # parse filename
  #
  #   file  full file name
  #   name  base name
  #   type  first part of base name (html|page|region|block)
  #   slug  remainder of base name
  #
  _parse_filename: ($file) ->
    $ext = path.extname($file)
    $name = path.basename($file, $ext)
    [$type, $slug] = $name.split('--')
    return {
      file: $file
      name: $name
      type: $type
      slug: $slug ? ''
    }


  #
  # Load & parse the template suggestions
  # Sort of like Drupal, the most specific
  # template that is found will be used.
  #
  #   html.tpl
  #
  #   block--[region|[module|--slug]].tpl
  #
  #     1. block--module--slug.tpl
  #     2. block--module.tpl
  #     3. block--region.tpl
  #
  #   page--[front|internal/path].tpl
  #
  #     for 'http://www.example.com/blog/1/edit'
  #
  #     1. page--front.tpl
  #     2. page--blog--edit.tpl
  #     3. page--blog--1.tpl
  #     4. page--blog--%.tpl
  #     5. page--blog.tpl
  #     6. page.tpl
  #
  #   region--[region].tpl
  #
  #
  load_templates: ($theme) ->

    #
    #   html.tpl
    #
    $html = @_parse_filename(@theme.getTemplates('html'))

    #
    #   page--[front|internal/path].tpl
    #
    $page = @_parse_filename(@theme.getTemplates('page', @uri.segmentArray()))
    $regions = [region: '$page', view: $page.file[0]]
    $blocks = []

    for $module, $val of @config.modules

      #
      #   block[--module].tpl
      #
      for $file in @theme.getTemplates('block', [$module])
        $mod = @_parse_filename($file)
        $blocks.push module: '$'+$module, view: $mod.file
        break


    for $region, $val of @_regions

      #
      #   region--region.tpl
      #
      for $file in @theme.getTemplates('region', [$region])
        $reg = @_parse_filename($file)
        $regions.push region: '$'+$reg.slug, view: $reg.file
        break

      #
      #   block[--region].tpl
      #
      for $file in @theme.getTemplates('block', [$region])
        $reg = @_parse_filename($file)
        $blocks.push region: '$'+$region, view: $reg.file
        break

    _template_cache[$theme] =
      html      : $html.file[0]   # html document template
      blocks    : $blocks         # block container templates
      regions   : $regions        # region container templates



