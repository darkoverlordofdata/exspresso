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

require SYSPATH+'lib/Parser.coffee'


#
#	  Theme Class
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
module.exports = class application.lib.Theme extends system.lib.Parser

  path = require('path')

  _template_cache = {}    # Static template cache

  #
  # @property [Object] html helper methods
  #
  html: null
  #
  # @property [application.lib.Theme] the theme object for the current controller
  #
  theme: null
  #
  # @property [application.lib.Breadcrumb] the breadcrumb manager for the current controller
  #
  breadcrumb: null

  _logo               : config_item('logo')
  _title              : config_item('site_name')
  _site_name          : config_item('site_name')
  _site_slogan        : config_item('site_slogan')
  _language           : config_item('language')
  _doctype            : 'html5'
  _layout             : 'html'
  _theme_name         : 'default'
  _theme_locations    : ''
  _theme_path         : ''
  _theme              : null
  _vars               : null
  _partials           : null
  _blocks             : null
  _regions            : null
  _metadata           : null
  _script             : null
  _css                : null
  _menu               : null
  _admin              : false
  _active             : ''


  #
  # Get Name
  #
  # @return [String] the theme name
  #
  getName: () ->
    @_theme_name

  #
  # Get Layout
  #
  # @return [String] the document layout template
  #
  getLayout: () ->
    @_layout

  #
  # Get Blocks
  #
  # @return [Array] list of available blocks for the theme
  #
  getBlocks: () ->
    @_blocks

  #
  # Get Regions
  #
  # @return [Array] list of available regions for the theme
  #
  getRegions: () ->
    $regions = {}
    $regions[$name] = $val for $name, $val of @_regions
    $regions['none'] = '- None -'
    $regions

  #
  # Get Partials
  #
  # @return [Array] list of available partials for the theme
  #
  getPartials: () ->
    @_partials

  #
  # constructor
  #
  # @param  [Object]  controller  
  # @param  [Object]  config  configuration array
  #
  constructor: ($controller, $config = {}) ->

    # Initialize the config preferences
    @_doctype = $config.doctype 
    @_layout = $config.layout
    @_theme_name = $config.theme
    @_theme_locations = $config.theme_locations

    log_message 'debug', "Template Class Initialized"

    @_metadata = []
    @_script = []
    @_css = []
    @_menu = {}

    @_vars = {}
    @_regions = {}
    @_partials = []
    @_blocks = []

    @html = @load.helper('html')
    @load.library 'Parser'
    @load.model 'Blocks', 'blocks'
    @load_theme @_theme_name

    # load the blocks defined for this theme
    @queue ($next) =>
      @blocks.getByTheme @_theme_name, ($err, $blocks) =>
        @_blocks =  $blocks
        $next()



  #
  # Use
  #
  # loads additional theme components
  #
  # @param  [Array]  extra theme elements
  # @return [Object]
  #
  use: ($extra...) ->

    #if @output._enable_profiler is true
    #  if $extra.indexOf('prettify') is -1
    #    $extra.push 'prettify'

    for $name in $extra
      if @_theme.css[$name]?
        @setCss @_theme.css[$name]

      else if @_theme.script[$name]?
        @setScript @_theme.script[$name]

      else if $name.substr(-4) is '.css'
        @setCss $name

      else if $name.substr(-3) is '.js'
        @setScript $name

      else if $name.substr(-7) is '.coffee'
        @setScript $name

    return

  #
  # Set data name/value pair
  #
  # @param  [String]  name  variable name to set
  # @param  [Mixed] value the value
  # @return [Object] this
  #
  set: ($name, $value) ->
    if 'string' is typeof($name)
      @_vars[$name] = $value
    else
      @_vars[$key] = $val for $key, $val of $name
    return

  #
  # Set the layout
  #
  # @param  [String]  layout  name of the layout
  # @return [Object] this
  #
  setLayout: ($layout) ->
    @_layout = $layout

  #
  # Set the title
  #
  # @param  [Array<String>] title array of title segments
  # @return [Object] this
  #
  setTitle: ($title...) ->
    @_title = $title.join(' | ')

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

  #
  # Set a named block
  #
  # @param  [String]  name  partial name
  # @param  [String]  view  view filename
  # @param  [Object]  data  hash of data vars
  # @return [Object] this
  #
  setBlock: ($name, $view, $data = {}) ->
    0

  #
  # Add breadcrumb
  #
  # @param  [String]  name  breadcrumb name
  # @param  [String]  uri uri to associate
  # @return [Object] this
  #
  setBreadcrumb: ($name, $uri, $level) ->
    if @breadcrumb is null then @load.library('Breadcrumb')
    @breadcrumb.add $name, $uri, $level

  #
  # Set doctype
  #
  # @param  [String]  doctype the html doctype to use
  # @return [Object] this
  #
  setDoctype: ($doctype = 'html5') ->
    @_doctype = $doctype

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
    return

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
    return


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
    return


  #
  # Add menu tags
  #
  # @param	[String]  menu  name of the menu to use
  # @return [Object] this
  #
  setMenu: ($menu) ->
    @_menu = $menu

  #
  # Use admin menu
  #
  # @param	[String]  active  the active menu selection
  # @return [Object] this
  #
  setAdminMenu: ($active) ->
    @_admin = true
    @_active = $active

  #
  # render a template
  #
  # @param	[String]  view  view filename
  # @param  [Object] data hash of name/value pairs
  # @param	[Function]  next  async callback
  # @return [Void] this
  #
  view: ($view = '' , $data = {}, $next) =>

    # set all standard variables needed for themes
    @set_standard_variables()

    # patch in the defaults & pre-set values
    $data.__proto__ = @_vars

    # partial layout index
    $index = 0
    #
    # Parse Partial Layout
    #
    _parse_partials = ($next) =>
      return $next(null) if @_partials.length is 0

      # load the partial at index
      $partial = @_partials[$index]

      # is there any block content for this partial?
      $content = []

      # try region: region--[region].tpl
      for $block in @_blocks
        if $block.active and $block.region is $partial.region
          # Render the block content
          $content.push @parseString($block.content, $data, true)

      $partial.data = if $content.length > 0 then $content: $content.join('') else {}
      $partial.data.__proto__ = $data

      @parse @_theme_path+'layout/'+$partial.view, $partial.data, ($err, $content) =>
        return $next($err) if $err

        # save the result
        if $data[$partial.region]? then $data[$partial.region] += $content
        else $data[$partial.region] = $content

        # get the next
        $index += 1
        return _parse_partials($next) unless $index is @_partials.length
        return $next(null)

    # Then render the partials
    _parse_partials ($err) =>
      return log_message('error', 'Template::view get_partials %s', $err) if show_error($err)

      # Next render the main content
      @parse $view, $data, ($err, $content) =>
        return log_message('error', 'Template::view load.view %s', $err) if show_error($err)

        # Lastly, render the container
        $data.$content = $content
        return @parse @_theme_path+'layout/'+@_layout, $data, $next


  #
  # Set Standard Variables
  #
  # Set standard variables for templates to use
  #
  # @access private
  # @return [Void]
  #
  set_standard_variables: () ->
    #
    # build client scripts
    #
    $script = []
    for $str in @_script
      if $str.substr(-3) is '.js'
        $script.push @html.javascript_tag($str)
      else if $str.substr(-7) is '.coffee'
        $script.push @html.javascript_tag($str, 'text/coffeescript')
      else
        $script.push @html.javascript_decl($str)

    #
    # build style sheets & css
    #
    $css = []
    for $str in @_css
      if $str.substr(-4) is '.css'
        $css.push @html.link_tag($str)
      else
        $css.push @html.stylesheet($str)

    #
    # build an admin menu?
    #
    if @_admin
      $admin_menu = Dashboard: '/admin'
      for $name, $module of @config.modules
        if $module.active
          $admin_menu[$module.name] = '/admin/'+$name

    if Array.isArray(@_site_slogan)
      random_element = @load.helper('array').random_element
      @_site_slogan = random_element(@_site_slogan)

    $info = @session.flashdata('info')
    $error = @session.flashdata('error')
    if @validation?
      if ($str = @validation.errorString()) isnt ''
        $error = if $error then $error+$str else $str
    #
    # define standard template variables
    #
    @set
      $ga_account       : config_item('ga_account')
      $ga_domain        : config_item('ga_domain')
      $doctype          : if @_doctype then @html.doctype(@_doctype) else 'html5'
      $meta             : if @_metadata then @html.meta(@_metadata) else ''
      $style            : $css.join("\n")
      $script           : $script.join("\n")
      $title            : @_title
      $logo             : @_logo
      $site_name        : @_site_name
      $site_slogan      : @_site_slogan
      $language         : @_language
      $menu             : @_menu
      $breadcrumb       : if @breadcrumb? then @breadcrumb.output() else ''
      $sidenav          : if @_admin then @html.sidenav($admin_menu, @_active) else ''
      $message          : @html.flash($error, $info)
      $sidebar_first    : ''
      $sidebar_second   : ''
      $profile          : if @output._enable_profiler then system.lib.Profiler::button else ''



  #
  # Loads a theme and template
  #
  # @access	private
  # @param	string theme name
  # @return [Object]
  #
  load_theme: ($theme) ->

    @_theme_path = rtrim(APPPATH + 'themes/' + $theme + '/')

    if file_exists(APPPATH + 'themes/' + $theme + '/theme.coffee')
      $config = require(APPPATH + 'themes/' + $theme + '/theme.coffee')

    if file_exists(APPPATH + 'themes/all/theme.coffee')
      $config.__proto__ = require(APPPATH + 'themes/all/theme.coffee')

    @_theme = Object.create($config)

    @_regions = @_theme.regions

    if @_menu?
      @setMenu @_theme.menu

    if @_meta?
      @setMeta @_theme.meta

    if @_theme.css? and @_theme.css.default?
      @setCss @_theme.css.default

    if @_theme.script? and @_theme.script.default?
      @setScript @_theme.script.default

    if @output._enable_profiler is true
      @setCss 'prettify'
      @setScript 'prettify'

    #
    # Load & parse the layout views
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

    # the main document structure
    @setLayout @get_layout('html')

    # page layout
    @setPartial 'page', @get_layout('page', @uri.segmentArray())

    # pieces parts...
    for $module, $val of @config.modules

      if ($file = @get_layout('block', $module))
        @setBlock $module, $file


    for $region, $val of @_regions

      if ($file = @get_layout('region', $region))
        @setPartial $region, $file

      if ($file = @get_layout('block', $region))
        @setBlock $region, $file

    return



  #
  # Load the layout file names for this theme
  #
  # @access private
  # @param  [String]  theme name of the theme
  # @return [Array<String>] all the templates for theme
  #
  get_layout_files: ($theme) ->

    return _template_cache[$theme] if _template_cache[$theme]?

    _files = []
    #
    # flatten a hierarchical map
    #
    flatten = ($files, $subdir = '') ->
      for $file, $dir of $files
        if 'string' is typeof $dir
          _files.push if $subdir is '' then $file else $subdir+"/"+$file
        else
          flatten $dir, $subdir+$file
      _files

    _template_cache[$theme] = flatten(directory_map(APPPATH+"themes/#{$theme}/layout"))

  #
  # Return the most specific layout template
  # part that is a match for type and slug(s)
  #
  # @access private
  # @param  [String]  type base type to generate from
  # @param  [Array<String>] slug  list of specifiers to match
  # @return [Object] struct containing all of the templates that match
  #
  get_layout: ($type, $slugs = []) ->

    if 'string' is typeof $slugs then $slugs = [$slugs]
    $files = {}
    for $file in @get_layout_files(@_theme_name)
      #$name = path.basename($file, path.extname($file))
      $name = $file.substr(0,$file.length-path.extname($file).length)
      $files[$name] = $file

    #
    # start with the least specific - just the base type
    #
    $candidates = if $files[$type]? then [$files[$type]] else []

    $pfx = $type
    for $slug in $slugs

      if $slug.length

        # If the slug is a number,
        # add the prefix plus "--%" to the list
        if 'number' is typeof($slug)
          if $files["#{$pfx}/%"]?
            $candidates.push $files["#{$pfx}/%"]

        # Regardless of whether the slug is a number or not,
        # add the prefix plus "/" plus the slug to the list
        if $files["#{$pfx}/#{$slug}"]?
          $candidates.push $files["#{$pfx}/#{$slug}"]

        # If the slug is not a number,
        # append "--" plus the slug to the prefix.
        if 'number' isnt typeof($slug)
          $pfx+="/#{$slug}"

    # If the page is the front page
    # add "page--front" to the list
    if @uri.uriString() is '/'
      if $files["#{$type}/front"]?
        $candidates.push $files["#{$type}/front"]


    # Reverse the order, so that [0] is
    # the most specific template found
    if $candidates.length is 0 then false
    else $candidates.reverse()[0]

