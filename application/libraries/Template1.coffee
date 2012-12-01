#+--------------------------------------------------------------------+
#| Template.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	Template
#
#
#
class Template

  CI: null
  script: []
  style: []
  meta: []
  data: {}
  layout: "layout"
  html: null

  ## --------------------------------------------------------------------

  #
  # constructor
  #
  #   @access	public
  #   @return	void
  #
  constructor: ($config = {}, @CI) ->

    @['_'+$key] = $val for $key, $val of $config

    @script = []
    @style = []
    @meta = []
    @data = {}
    @html = @CI.load.helper('html')

  ## --------------------------------------------------------------------

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
      @data[$key] = $val for $key, $val of $name
    else
      @data[$name] = $value
    @

  ## --------------------------------------------------------------------

  #
  # Add link tag
  #
  #   @access	public
  #   @param	mixed	stylesheet hrefs or an array
  #   @param	string	rel
  #   @param	string	type
  #   @param	string	title
  #   @param	string	media
  #   @param	boolean	should index_page be added to the css path
  #   @return	object
  #
  add_link: ($href = '', $rel = 'stylesheet', $type = 'text/css', $title = '', $media = '', $index_page = false) ->
    @style.push @html.link_tag($href, $rel, $type, $title, $media, $index_page)
    @

  ## --------------------------------------------------------------------

  #
  # Add style tag
  #
  #   @access	public
  #   @param	string	rel
  #   @return	object
  #
  add_style: ($content, $type = 'text/css') ->
    @style.push @html.stylesheet($content, $type)
    @

  ## --------------------------------------------------------------------

  #
  # Add script link
  #
  #   @access	public
  #   @param	string	src
  #   @param	string	type
  #   @return	object
  #
  add_script_link: ($src, $type = 'text/javascript') ->
    @script.push @html.javascript_decl($src, $type)
    @

  ## --------------------------------------------------------------------

  #
  # Add script
  #
  #   @access	public
  #   @param	string	content
  #   @param	string	type
  #   @return	object
  #
  add_script: ($content, $type = 'text/javascript') ->
    @script.push @html.javascript_decl($content, $type)
    @

  ## --------------------------------------------------------------------

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
  add_meta: ($name = '', $content = '', $type = 'name', $newline = "\n") ->
    @meta.push @html.meta($name, $content, $type, $newline)
    @


  ## --------------------------------------------------------------------

  #
  # loads a template
  #
  #   @access	public
  #   @param	string	template
  #   @param	string	view
  #   @param	array   data
  #   @param	function callback
  #   @return	object
  #
  load: ($template = '', $view = '' , $data = {}, $callback) ->

    @set $data
    @set 'layout', $template

    @CI.load.view $view, $data, ($err, $html) =>

      @set 'meta', @meta.join("\n")
      @set 'style', @style.join("\n")
      @set 'script', @script.join("\n")
      @set 'contents', $html
      @CI.load.view $template, @data, $callback


# End of file Template.coffee
# Location: .application/libraries/Template.coffee