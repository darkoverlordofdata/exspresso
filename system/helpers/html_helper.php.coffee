if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter HTML Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/html_helper.html
#

#  ------------------------------------------------------------------------

#
# Heading
#
# Generates an HTML heading tag.  First param is the data.
# Second param is the size of the heading tag.
#
# @access	public
# @param	string
# @param	integer
# @return	string
#
if not function_exists('heading')
	global.heading = ($data = '', $h = '1') ->
		return "<h" + $h + ">" + $data + "</h" + $h + ">"
		
	

#  ------------------------------------------------------------------------

#
# Unordered List
#
# Generates an HTML unordered list from an single or multi-dimensional array.
#
# @access	public
# @param	array
# @param	mixed
# @return	string
#
if not function_exists('ul')
	global.ul = ($list, $attributes = '') ->
		return _list('ul', $list, $attributes)
		
	

#  ------------------------------------------------------------------------

#
# Ordered List
#
# Generates an HTML ordered list from an single or multi-dimensional array.
#
# @access	public
# @param	array
# @param	mixed
# @return	string
#
if not function_exists('ol')
	global.ol = ($list, $attributes = '') ->
		return _list('ol', $list, $attributes)
		
	

#  ------------------------------------------------------------------------

#
# Generates the list
#
# Generates an HTML ordered list from an single or multi-dimensional array.
#
# @access	private
# @param	string
# @param	mixed
# @param	mixed
# @param	integer
# @return	string
#
if not function_exists('_list')
	global._list = ($type = 'ul', $list, $attributes = '', $depth = 0) ->
		#  If an array wasn't submitted there's nothing to do...
		if not is_array($list)
			return $list
			
		
		#  Set the indentation based on the depth
		$out = str_repeat(" ", $depth)
		
		#  Were any attributes submitted?  If so generate a string
		if is_array($attributes)
			$atts = ''
			for $val, $key in as
				$atts+=' ' + $key + '="' + $val + '"'
				
			$attributes = $atts
			
		
		#  Write the opening list tag
		$out+="<" + $type + $attributes + ">\n"
		
		#  Cycle through the list elements.  If an array is
		#  encountered we will recursively call _list()
		
		global.$_last_list_item = global.$_last_list_item ? ''
		for $val, $key in as
			$_last_list_item = $key
			
			$out+=str_repeat(" ", $depth + 2)
			$out+="<li>"
			
			if not is_array($val)
				$out+=$val
				
			else 
				$out+=$_last_list_item + "\n"
				$out+=_list($type, $val, '', $depth + 4)
				$out+=str_repeat(" ", $depth + 2)
				
			
			$out+="</li>\n"
			
		
		#  Set the indentation for the closing tag
		$out+=str_repeat(" ", $depth)
		
		#  Write the closing list tag
		$out+="</" + $type + ">\n"
		
		return $out
		
	

#  ------------------------------------------------------------------------

#
# Generates HTML BR tags based on number supplied
#
# @access	public
# @param	integer
# @return	string
#
if not function_exists('br')
	global.br = ($num = 1) ->
		return str_repeat("<br />", $num)
		
	

#  ------------------------------------------------------------------------

#
# Image
#
# Generates an <img /> element
#
# @access	public
# @param	mixed
# @return	string
#
if not function_exists('img')
	global.img = ($src = '', $index_page = FALSE) ->
		if not is_array($src)
			$src = 'src':$src
			
		
		#  If there is no alt attribute defined, set it to an empty string
		if not $src['alt']? 
			$src['alt'] = ''
			
		
		$img = '<img'
		
		for $v, $k in as
			
			if $k is 'src' and strpos($v, '://') is FALSE
				$CI = get_instance()
				
				if $index_page is TRUE
					$img+=' src="' + $CI.config.site_url($v) + '"'
					
				else 
					$img+=' src="' + $CI.config.slash_item('base_url') + $v + '"'
					
				
			else 
				$img+=$k=\"$v\"
				
			
		
		$img+='/>'
		
		return $img
		
	

#  ------------------------------------------------------------------------

#
# Doctype
#
# Generates a page document type declaration
#
# Valid options are xhtml-11, xhtml-strict, xhtml-trans, xhtml-frame,
# html4-strict, html4-trans, and html4-frame.  Values are saved in the
# doctypes config file.
#
# @access	public
# @param	string	type	The doctype to be generated
# @return	string
#
if not function_exists('doctype')
	global.doctype = ($type = 'xhtml1-strict') ->
		global.$_doctypes
		
		if not is_array($_doctypes)
			if defined('ENVIRONMENT') and is_file(APPPATH + 'config/' + ENVIRONMENT + '/doctypes' + EXT)
				eval include_all(APPPATH + 'config/' + ENVIRONMENT + '/doctypes' + EXT)
				
			else if is_file(APPPATH + 'config/doctypes' + EXT)
				eval include_all(APPPATH + 'config/doctypes' + EXT)
				
			
			if not is_array($_doctypes)
				return FALSE
				
			
		
		if $_doctypes[$type]? 
			return $_doctypes[$type]
			
		else 
			return FALSE
			
		
	

#  ------------------------------------------------------------------------

#
# Link
#
# Generates link to a CSS file
#
# @access	public
# @param	mixed	stylesheet hrefs or an array
# @param	string	rel
# @param	string	type
# @param	string	title
# @param	string	media
# @param	boolean	should index_page be added to the css path
# @return	string
#
if not function_exists('link_tag')
	global.link_tag = ($href = '', $rel = 'stylesheet', $type = 'text/css', $title = '', $media = '', $index_page = FALSE) ->
		$CI = get_instance()
		
		$link = '<link '
		
		if is_array($href)
			for $v, $k in as
				if $k is 'href' and strpos($v, '://') is FALSE
					if $index_page is TRUE
						$link+='href="' + $CI.config.site_url($v) + '" '
						
					else 
						$link+='href="' + $CI.config.slash_item('base_url') + $v + '" '
						
					
				else 
					$link+=$k=\"$v\" 
					
				
			
			$link+="/>"
			
		else 
			if strpos($href, '://') isnt FALSE
				$link+='href="' + $href + '" '
				
			else if $index_page is TRUE
				$link+='href="' + $CI.config.site_url($href) + '" '
				
			else 
				$link+='href="' + $CI.config.slash_item('base_url') + $href + '" '
				
			
			$link+='rel="' + $rel + '" type="' + $type + '" '
			
			if $media isnt ''
				$link+='media="' + $media + '" '
				
			
			if $title isnt ''
				$link+='title="' + $title + '" '
				
			
			$link+='/>'
			
		
		
		return $link
		
	

#  ------------------------------------------------------------------------

#
# Generates meta tags from an array of key/values
#
# @access	public
# @param	array
# @return	string
#
if not function_exists('meta')
	global.meta = ($name = '', $content = '', $type = 'name', $newline = "\n") ->
		#  Since we allow the data to be passes as a string, a simple array
		#  or a multidimensional one, we need to do a little prepping.
		if not is_array($name)
			$name = ['name':$name, 'content':$content, 'type':$type, 'newline':$newline]
			
		else 
			#  Turn single array into multidimensional
			if $name['name']? 
				$name = [$name]
				
			
		
		$str = ''
		for $meta in as
			$type = if ( not $meta['type']?  or $meta['type'] is 'name') then 'name' else 'http-equiv'
			$name = if ( not $meta['name']? ) then '' else $meta['name']
			$content = if ( not $meta['content']? ) then '' else $meta['content']
			$newline = if ( not $meta['newline']? ) then "\n" else $meta['newline']
			
			$str+='<meta ' + $type + '="' + $name + '" content="' + $content + '" />' + $newline
			
		
		return $str
		
	

#  ------------------------------------------------------------------------

#
# Generates non-breaking space entities based on number supplied
#
# @access	public
# @param	integer
# @return	string
#
if not function_exists('nbs')
	global.nbs = ($num = 1) ->
		return str_repeat("&nbsp;", $num)
		
	


#  End of file html_helper.php 
#  Location: ./system/helpers/html_helper.php 