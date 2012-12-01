#+--------------------------------------------------------------------+
#  @coffee
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
# CodeIgniter Template Class
#
# Build your CodeIgniter pages much easier with partials, breadcrumbs, layouts and themes
#
# @package			CodeIgniter
# @subpackage		Libraries
# @category		Libraries
# @author			Philip Sturgeon
# @license			http://philsturgeon.co.uk/code/dbad-license
# @link			http://philsturgeon.co.uk/code/codeigniter-template
#
class Template

  _module: ''
  _controller: ''
  _method: ''
  
  _theme: null
  _theme_path: null
  _layout: false#  By default, dont wrap the view with anything
  _layout_subdir: ''#  Layouts and partials will exist in views/layouts
  #  but can be set to views/foo/layouts with a subdirectory
  
  _title: ''
  _metadata: {}
  
  _partials: {}
  
  _breadcrumbs: []
  
  _title_separator: ' | '
  
  _parser_enabled: true
  _parser_body_enabled: true
  _minify_enabled: false
  
  _theme_locations: []
  
  _is_mobile: false
  
  #  Seconds that cache will be alive for
  cache_lifetime: 0 # 7200
  
  CI: null
  
  _data: {}
  
  #
  # Constructor - Sets Preferences
  #
  # The constructor can be passed an array of config values
  #
  constructor : ($config = {}, @CI) ->

    @_data = {}
    @_metadata = {}
    @_partials = {}
    @_breadcrumbs = []
    @_theme_locations = []

    if not empty($config)
      @initialize($config)

    log_message('debug', 'Template class Initialized')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Initialize preferences
  #
  # @access	public
  # @param	array	$config
  # @return	void
  #
  initialize : ($config = {}) ->
    for $key, $val of $config
      if $key is 'theme' and $val isnt ''
        @set_theme($val)
        continue
      @['_' + $key] = $val
      
    
    #  No locations set in config?
    if count(@_theme_locations) is 0
      #  Let's use this obvious default
      @_theme_locations = [APPPATH + 'themes/']
      
    
    #  If the parse is going to be used, best make sure it's loaded
    if @_parser_enabled is true
      @CI.load.library('parser')
      
    
    #  Modular Separation / Modular Extensions has been detected
    if method_exists(@CI.router, 'fetch_module')
      @_module = @CI.router.fetch_module()
      
    
    #  What controllers or methods are in use
    @_controller = @CI.router.fetch_class()
    @_method = @CI.router.fetch_method()
    
    #  Load user agent library if not loaded
    @CI.load.library('user_agent')
    
    #  We'll want to know this later
    #@_is_mobile = @CI.agent.is_mobile()
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set the module manually. Used when getting results from
  # another module with Modules::run('foo/bar')
  #
  # @access	public
  # @param	string	$module The module slug
  # @return	mixed
  #
  set_module: ($module) ->
    @_module = $module
    
    return @
  

  #  --------------------------------------------------------------------
  
  #
  # Set data using a chainable metod. Provide two strings or an array of data.
  #
  # @access	public
  # @param	string	$name
  # @param	mixed	$value
  # @return	object	$this
  #
  set: ($name, $value = null) ->
    #  Lots of things! Set them all
    if is_array($name) or is_object($name)
      for $item, $value of $name
        @_data[$item] = $value

    #  Just one thing, set that
    else 
      @_data[$name] = $value

    return @
  
  #  --------------------------------------------------------------------
  
  #
  # Build the entire HTML output combining partials, layouts and views.
  #
  # @access	public
  # @param	string	$view
  # @param	array	$data
  # @param	bool	$return
  # @param	bool	$IE_cache
  # @return	string
  #
  build: ($view, $data = {}, $return = false, $IE_cache = true) ->

    #  Merge in what we already have with the specific data
    @_data = array_merge(@_data, $data)
    
    #  We don't need you any more buddy
    #delete $data
    
    if empty(@_title)
      @_title = @_guess_title()

    #  Output template variables to the template
    $template['title'] = @_title
    $template['breadcrumbs'] = @_breadcrumbs
    $template['metadata'] = @get_metadata() + Asset.render('extra')
    $template['partials'] = {}
    
    #  Assign by reference, as all loaded views will need access to partials
    @_data['template'] = $template
    
    for $name, $partial of @_partials
      #  If it uses a view, load it
      if $partial['view']? 
        $template['partials'][$name] = @_find_view($partial['view'], $partial['data'])

      #  Otherwise the partial must be a string
      else 
        if @_parser_enabled is true
          $partial['string'] = @CI.parser.parse_string($partial['string'], @_data + $partial['data'], true, true)

        $template['partials'][$name] = $partial['string']

    #  Disable sodding IE7's constant cacheing!!
    #  This is in a conditional because otherwise it errors when output is returned instead of output to browser.
    if $IE_cache
      @CI.output.set_header('Expires: Sat, 01 Jan 2000 00:00:01 GMT')
      @CI.output.set_header('Cache-Control: no-store, no-cache, must-revalidate')
      @CI.output.set_header('Cache-Control: post-check=0, pre-check=0, max-age=0')
      @CI.output.set_header('Last-Modified: ' + gmdate('D, d M Y H:i:s') + ' GMT')
      @CI.output.set_header('Pragma: no-cache')

    #  Let CI do the caching instead of the browser
    @cache_lifetime > 0 and @CI.output.cache(@cache_lifetime)
    
    #  Test to see if this file
    @_body = @_find_view($view, {}, @_parser_body_enabled)
    
    #  Want this file wrapped with a layout file?
    if @_layout
      #  Added to $this->_data['template'] by refference
      $template['body'] = @_body
      
      if @_parser_enabled
        #  Persistent tags is an experiment to parse some tags after
        #  parsing of all other tags, so the tag persistent should be:
        # 
        #  a) Defined only if depends of others tags
        #  b) Plugin that is a callback, so could retrieve runtime data.
        #  c) Returned with a content parsed
        @_data['_tags']['persistent_tags'].push 'template:metadata'
        
      
      #  Find the main body and 3rd param means parse if its a theme view (only if parser is enabled)
      @_body = @_load_view('layouts/' + @_layout, @_data, true, @_find_view_folder())
      
    
    if @_minify_enabled and function_exists('process_data_jmr1')
      @_body = process_data_jmr1(@_body)
      
    
    #  Now that *all* parsing is sure to be done we inject the {{ noparse }} contents back into the output
    if class_exists('Lex_Parser')
      @_body = Lex_Parser.inject_noparse(@_body)
      
    
    #  Want it returned or output to browser?
    if not $return
      @CI.output.set_output(@_body)
      
    
    return @_body
  
  #
  # Build the entire JSON output, setting the headers for response.
  #
  # @access	public
  # @param	array	$data
  # @return	void
  #
  build_json: ($data = {}) ->

    @CI.output.set_header('Content-Type: application/json; charset=utf-8')
    @CI.output.set_output(json_encode($data))
  
  #
  # Set the title of the page
  #
  # @access	public
  # @return	object	$this
  #
  title: () ->
    #  If we have some segments passed
    if ($title_segments = arguments)
      @_title = implode(@_title_separator, $title_segments)
    @

    # Put extra javascipt, css, meta tags, etc before all other head data
    #
    # @access	public
    # @param	string	$line	The line being added to head
    # @return	object	$this
    #
      # we need to declare all new key's in _metadata as an array for the unshift function to work
  prepend_metadata: ($line, $place = 'header') ->
    if not @_metadata[$place]?
      @_metadata[$place] = {}

    array_unshift(@_metadata[$place], $line)
    return @

  
  #
  # Put extra javascipt, css, meta tags, etc after other head data
  #
  # @access	public
  # @param	string	$line	The line being added to head
  # @return	object	$this
  #
  append_metadata: ($line, $place = 'header') ->
    @_metadata[$place].push $line
    
    return @
  
  #
  # Put extra javascipt, css, meta tags, etc after other head data
  #
  # @access	public
  # @param	string	$line	The line being added to head
  # @return	object	$this
  #
  append_css: ($files, $min_file = null, $group = 'extra') ->
    
    Asset.css($files, $min_file, $group)
    
    return @
  
  append_js: ($files, $min_file = null, $group = 'extra') ->

    Asset.js($files, $min_file, $group)
    
    return @
  
  
  #
  # Set metadata for output later
  #
  # @access	public
  # @param	string	$name		keywords, description, etc
  # @param	string	$content	The content of meta data
  # @param	string	$type		Meta-data comes in a few types, links for example
  # @return	object	$this
  #
  set_metadata: ($name, $content, $type = 'meta') ->

    $name = htmlspecialchars(strip_tags($name))
    $content = htmlspecialchars(strip_tags($content))

    #  Keywords with no comments? ARG! comment them
    if $name is 'keywords' and  not strpos($content, ',')
      $content = preg_replace('/[\\s]+/', ', ', trim($content))

    switch $type
      when 'meta'
        @_metadata['header'][$name] = '<meta name="' + $name + '" content="' + $content + '" />'

      when 'link'
        @_metadata['header'][$content] = '<link rel="' + $name + '" href="' + $content + '" />'

    return @

  
  #
  # Which theme are we using here?
  #
  # @access	public
  # @param	string	$theme	Set a theme for the template library to use
  # @return	object	$this
  #
  set_theme: ($theme = null) ->

    @_theme = $theme
    for $location in @_theme_locations
      if @_theme and file_exists($location + @_theme)
        @_theme_path = rtrim($location + @_theme + '/')
        break
    return @

  #
  # Get the current theme path
  #
  # @access	public
  # @return	string The current theme path
  #
  get_theme_path: () ->

    return @_theme_path

  #
  # Get the current view path
  #
  # @access	public
  # @param	bool	Set if should be returned the view path full (with theme path) or the view relative the theme path
  # @return	string	The current view path
  #
  get_views_path: ($relative = false) ->

    return if $relative then substr(@_find_view_folder(), strlen(@get_theme_path())) else @_find_view_folder()


  #
  # Which theme layout should we using here?
  #
  # @access	public
  # @param	string	$view
  # @param	string	$layout_subdir
  # @return	object	$this
  #
  set_layout: ($view, $layout_subdir = '') ->

    @_layout = $view

    $layout_subdir and (@_layout_subdir = $layout_subdir)

    return @

  #
  # Set a view partial
  #
  # @access	public
  # @param	string	$name
  # @param	string	$view
  # @param	array	$data
  # @return	object	$this
  #
  set_partial: ($name, $view, $data = {}) ->

    @_partials[$name] = 'view':$view, 'data':$data
    return @


  #
  # Set a view partial
  #
  # @access	public
  # @param	string	$name
  # @param	string	$string
  # @param	array	$data
  # @return	object	$this
  #
  inject_partial: ($name, $string, $data = {}) ->

    @_partials[$name] = 'string':$string, 'data':$data
    return @


  
  #
  # Helps build custom breadcrumb trails
  #
  # @access	public
  # @param	string	$name	What will appear as the link text
  # @param	string	$uri	The URL segment
  # @return	object	$this
  #
  set_breadcrumb: ($name, $uri = '',$reset = false) ->
    #  perhaps they want to start over
    if $reset
      @_breadcrumbs = []


    @_breadcrumbs.push 'name':$name, 'uri':$uri
    return @

  #
  # Set a the cache lifetime
  #
  # @access	public
  # @param	int		$seconds
  # @return	object	$this
  #
  set_cache: ($seconds = 0) ->

    @cache_lifetime = $seconds
    return @

  
  #
  # enable_minify
  # Should be minify used or the output html files just delivered normally?
  #
  # @access	public
  # @param	bool	$bool
  # @return	object	$this
  #
  enable_minify: ($bool) ->

    @_minify_enabled = $bool
    return @


  
  #
  # enable_parser
  # Should be parser be used or the view files just loaded normally?
  #
  # @access	public
  # @param	bool	$bool
  # @return	object	$this
  #
  enable_parser: ($bool) ->

    @_parser_enabled = $bool
    return @

  #
  # enable_parser_body
  # Should be parser be used or the body view files just loaded normally?
  #
  # @access	public
  # @param	bool	$bool
  # @return	object	$this
  #
  enable_parser_body: ($bool) ->

    @_parser_body_enabled = $bool
    return @


  #
  # theme_locations
  # List the locations where themes may be stored
  #
  # @access	public
  # @return	array
  #
  theme_locations: () ->

    return @_theme_locations


  #
  # add_theme_location
  # Set another location for themes to be looked in
  #
  # @access	public
  # @param	string	$location
  # @return	array
  #
  add_theme_location: ($location) ->

    @_theme_locations.push $location


  #
  # theme_exists
  # Check if a theme exists
  #
  # @access	public
  # @param	string	$theme
  # @return	bool
  #
  theme_exists: ($theme = null) ->

    $theme or ($theme = @_theme)

    for $location in @_theme_locations
      if is_dir($location + $theme)
        return true

    return false

  #
  # get_layouts
  # Get all current layouts (if using a theme you'll get a list of theme layouts)
  #
  # @access	public
  # @return	array
  #
  get_layouts: () ->

    $layouts = []

    for $layout in glob(@_find_view_folder() + 'layouts/*.*')
      $layouts.push pathinfo($layout, PATHINFO_BASENAME)

    return $layouts

  get_metadata: ($place = 'header') ->

    return if @_metadata[$place]?  and is_array(@_metadata[$place]) then implode("\n\t\t", @_metadata[$place]) else null


  #
  # get_layouts
  # Get all current layouts (if using a theme you'll get a list of theme layouts)
  #
  # @access	public
  # @param	string	$theme
  # @return	array
  #
  get_theme_layouts: ($theme = null) ->

    $theme or ($theme = @_theme)

    $layouts = []

    for $location in @_theme_locations
      #  Get special web layouts
      if is_dir($location + $theme + '/views/web/layouts/')
        for $layout in glob($location + $theme + '/views/web/layouts/*.*')
          $layouts.push pathinfo($layout, PATHINFO_BASENAME)

        break

      #  So there are no web layouts, assume all layouts are web layouts
      if is_dir($location + $theme + '/views/layouts/')
        for $layout in glob($location + $theme + '/views/layouts/*.*')
          $layouts.push pathinfo($layout, PATHINFO_BASENAME)

        break

    return $layouts

  #
  # layout_exists
  # Check if a theme layout exists
  #
  # @access	public
  # @param	string	$layout
  # @return	bool
  #
  layout_exists: ($layout) ->
  #  If there is a theme, check it exists in there
    if not empty(@_theme) and in_array($layout, @get_theme_layouts())
      return true
      
    
    #  Otherwise look in the normal places
    return file_exists(@_find_view_folder() + 'layouts/' + $layout + @_ext($layout))
  
  #
  # layout_is
  # Check if the current theme layout is equal the $layout argument
  #
  # @access	public
  # @param	string	$layout
  # @return	bool
  #
  layout_is: ($layout) ->
    return $layout is @_layout

  
  #  find layout files, they could be mobile or web
  _find_view_folder: () ->

    if @CI.load._ci_cached_vars['template_views']?
      return @CI.load._ci_cached_vars['template_views']


    #  Base view folder
    $view_folder = APPPATH + 'views/'

    #  Using a theme? Put the theme path in before the view folder
    if not empty(@_theme)
      $view_folder = @_theme_path + 'views/'


    #  Would they like the mobile version?
    if @_is_mobile is true and is_dir($view_folder + 'mobile/')
      #  Use mobile as the base location for views
      $view_folder+='mobile/'


    #  Use the web version
    else if is_dir($view_folder + 'web/')
      $view_folder+='web/'


    #  Things like views/admin/web/view admin = subdir
    if @_layout_subdir
      $view_folder+=@_layout_subdir + '/'


    #  If using themes store this for later, available to all views
    return @CI.load._ci_cached_vars['template_views'] = $view_folder
  
  #  A module view file can be overriden in a theme
  _find_view: ($view, $data, $parse_view = true) ->
    #  Only bother looking in themes if there is a theme
    if not empty(@_theme)
      $location = @get_theme_path()
      $theme_views = [
        @get_views_path(true) + 'modules/' + @_module + '/' + $view
        #  This allows build('pages/page') to still overload same as build('page')
        @get_views_path(true) + 'modules/' + $view
        @get_views_path(true) + $view
      ]
      
      for $theme_view in $theme_views
        if file_exists($location + $theme_view + @_ext($theme_view))
          return @_load_view($theme_view, @_data + $data, $parse_view, $location)

    #  Not found it yet? Just load, its either in the module or root view
    return @_load_view($view, @_data + $data, $parse_view)

  _load_view: ($view, $data, $parse_view = true, $override_view_path = null) ->
    #  Sevear hackery to load views from custom places AND maintain compatibility with Modular Extensions
    if $override_view_path isnt null
      if @_parser_enabled is true and $parse_view is true
        #  Load content and pass through the parser
        $content = @CI.parser.parse_string(@CI.load._ci_load(
          '_ci_path':   $override_view_path + $view + @_ext($view),
          '_ci_vars':   $data,
          '_ci_return': true
        ),$data, true)


      else
        #  Load it directly, bypassing $this->load->view() as ME resets _ci_view
        $content = @CI.load._ci_load(
          '_ci_path':   $override_view_path + $view + @_ext($view),
          '_ci_vars':   $data,
          '_ci_return': true
        )



    #  Can just run as usual
    else
      #  Grab the content of the view (parsed or loaded)
      $content = if (@_parser_enabled is true and $parse_view is true)#  Parse that bad boy then @CI.parser.parse($view, $data, true)#  None of that fancy stuff for me! else @CI.load.view($view, $data, true)


    return $content

      
  _guess_title: () ->
    $inflector = @CI.load.helper('inflector')
  
    #  Obviously no title, lets get making one
    $title_parts = []

    #  If the method is something other than index, use that
    if @_method isnt 'index'
      $title_parts.push @_method


    #  Make sure controller name is not the same as the method name
    if not in_array(@_controller, $title_parts)
      $title_parts.push @_controller


    #  Is there a module? Make sure it is not named the same as the method or controller
    if not empty(@_module) and  not in_array(@_module, $title_parts)
      $title_parts.push @_module


    #  Glue the title pieces together using the title separator setting
    $title = $inflector.humanize(implode(@_title_separator, $title_parts))

    return $title

  _ext: ($file) ->

    path = require(path)
    return if path.extname($file) then '' else EXT


module.exports = Template

#  END Template class