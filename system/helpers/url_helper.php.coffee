#+--------------------------------------------------------------------+
#  url_helper.coffee
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

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_reverse, config, count, defined, function_exists, get_instance, header, is_array, is_string, item, ob_end_clean, ob_get_contents, ob_start, ord, parse_url, preg_match, preg_match_all, preg_replace, slash_item, str_replace, strip_tags, stripslashes, strlen, strtolower, substr, trim, uri}  = require(FCPATH + 'lib')


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
# CodeIgniter URL Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/url_helper.html
#

#  ------------------------------------------------------------------------

#
# Site URL
#
# Create a local URL based on your basepath. Segments can be passed via the
# first parameter either as a string or an array.
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('site_url')
  exports.site_url = site_url = ($uri = '') ->
    $CI = get_instance()
    return $CI.config.site_url($uri)
    
  

#  ------------------------------------------------------------------------

#
# Base URL
#
# Returns the "base_url" item from your config file
#
# @access	public
# @return	string
#
if not function_exists('base_url')
  exports.base_url = base_url =  ->
    $CI = get_instance()
    return $CI.config.slash_item('base_url')
    
  

#  ------------------------------------------------------------------------

#
# Current URL
#
# Returns the full URL (including segments) of the page where this
# function is placed
#
# @access	public
# @return	string
#
if not function_exists('current_url')
  exports.current_url = current_url =  ->
    $CI = get_instance()
    return $CI.config.site_url($CI.uri.uri_string())
    
  

#  ------------------------------------------------------------------------
#
# URL String
#
# Returns the URI segments.
#
# @access	public
# @return	string
#
if not function_exists('uri_string')
  exports.uri_string = uri_string =  ->
    $CI = get_instance()
    return $CI.uri.uri_string()
    
  

#  ------------------------------------------------------------------------

#
# Index page
#
# Returns the "index_page" from your config file
#
# @access	public
# @return	string
#
if not function_exists('index_page')
  exports.index_page = index_page =  ->
    $CI = get_instance()
    return $CI.config.item('index_page')
    
  

#  ------------------------------------------------------------------------

#
# Anchor Link
#
# Creates an anchor based on the local URL.
#
# @access	public
# @param	string	the URL
# @param	string	the link title
# @param	mixed	any attributes
# @return	string
#
if not function_exists('anchor')
  exports.anchor = anchor = ($uri = '', $title = '', $attributes = '') ->
    $title = ''+$title
    
    if not is_array($uri)
      $site_url = if ( not preg_match('!^\w+://! i', $uri)) then site_url($uri) else $uri
      
    else 
      $site_url = site_url($uri)
      
    
    if $title is ''
      $title = $site_url
      
    
    if $attributes isnt ''
      $attributes = _parse_attributes($attributes)
      
    
    return '<a href="' + $site_url + '"' + $attributes + '>' + $title + '</a>'
    
  

#  ------------------------------------------------------------------------

#
# Anchor Link - Pop-up version
#
# Creates an anchor based on the local URL. The link
# opens a new window based on the attributes specified.
#
# @access	public
# @param	string	the URL
# @param	string	the link title
# @param	mixed	any attributes
# @return	string
#
if not function_exists('anchor_popup')
  exports.anchor_popup = anchor_popup = ($uri = '', $title = '', $attributes = false) ->
    $title = ''+$title
    
    $site_url = if ( not preg_match('!^\w+://! i', $uri)) then site_url($uri) else $uri
    
    if $title is ''
      $title = $site_url
      
    
    if $attributes is false
      return "<a href='javascript:void(0);' onclick=\"window.open('" + $site_url + "', '_blank');\">" + $title + "</a>"
      
    
    if not is_array($attributes)
      $attributes = {}
      
    
    for $key, $val of 'width':'800', 'height':'600', 'scrollbars':'yes', 'status':'yes', 'resizable':'yes', 'screenx':'0', 'screeny':'0', 
      $atts[$key] = if ( not $attributes[$key]? ) then $val else $attributes[$key]
      delete $attributes[$key]
      
    
    if $attributes isnt ''
      $attributes = _parse_attributes($attributes)
      
    
    return "<a href='javascript:void(0);' onclick=\"window.open('" + $site_url + "', '_blank', '" + _parse_attributes($atts, true) + "');\"$attributes>" + $title + "</a>"
    
  

#  ------------------------------------------------------------------------

#
# Mailto Link
#
# @access	public
# @param	string	the email address
# @param	string	the link title
# @param	mixed	any attributes
# @return	string
#
if not function_exists('mailto')
  exports.mailto = mailto = ($email, $title = '', $attributes = '') ->
    $title = ''+$title
    
    if $title is ""
      $title = $email
      
    
    $attributes = _parse_attributes($attributes)
    
    return '<a href="mailto:' + $email + '"' + $attributes + '>' + $title + '</a>'
    
  

#  ------------------------------------------------------------------------

#
# Encoded Mailto Link
#
# Create a spam-protected mailto link written in Javascript
#
# @access	public
# @param	string	the email address
# @param	string	the link title
# @param	mixed	any attributes
# @return	string
#
if not function_exists('safe_mailto')
  exports.safe_mailto = safe_mailto = ($email, $title = '', $attributes = '') ->
    $title = ''+$title
    
    if $title is ""
      $title = $email
      
    
    for ($i = 0$i < 16$i++)
    {
    $x.push substr('<a href="mailto:', $i, 1)
    }
    
    for ($i = 0$i < strlen($email)$i++)
    {
    $x.push "|" + ord(substr($email, $i, 1))
    }
    
    $x.push '"'
    
    if $attributes isnt ''
      if is_array($attributes)
        for $key, $val of $attributes
          $x.push ' ' + $key + '="'
          for ($i = 0$i < strlen($val)$i++)
          {
          $x.push "|" + ord(substr($val, $i, 1))
          }
          $x.push '"'
          
        
      else 
        for ($i = 0$i < strlen($attributes)$i++)
        {
        $x.push substr($attributes, $i, 1)
        }
        
      
    
    $x.push '>'
    
    $temp = {}
    for ($i = 0$i < strlen($title)$i++)
    {
    $ordinal = ord($title[$i])
    
    if $ordinal < 128
      $x.push "|" + $ordinal
      
    else 
      if count($temp) is 0
        $count = if ($ordinal < 224) then 2 else 3
        
      
      $temp.push $ordinal
      if count($temp) is $count
        $number = if ($count is 3) then (($temp['0']16) * 4096) + (($temp['1']64) * 64) + ($temp['2']64) else (($temp['0']32) * 64) + ($temp['1']64)
        $x.push "|" + $number
        $count = 1
        $temp = {}
        
      
    }
    
    $x.push '<'$x.push '/'$x.push 'a'$x.push '>'
    
    $x = array_reverse($x)
    ob_start()
    
    $i = 0
    for $val in $x echo $i++echo $val
    $buffer = ob_get_contents()
    ob_end_clean()
    return $buffer
    
  

#  ------------------------------------------------------------------------

#
# Auto-linker
#
# Automatically links URL and Email addresses.
# Note: There's a bit of extra code here to deal with
# URLs or emails that end in a period.  We'll strip these
# off and add them after the link.
#
# @access	public
# @param	string	the string
# @param	string	the type: email, url, or both
# @param	bool	whether to create pop-up links
# @return	string
#
if not function_exists('auto_link')
  exports.auto_link = auto_link = ($str, $type = 'both', $popup = false) ->
    if $type isnt 'email'
      if preg_match_all("#(^|\s|\()((http(s?)://)|(www\.))(\w+[^\s\)\<]+)#i", $str, $matches)
        $pop = if ($popup is true) then " target=\"_blank\" " else ""
        
        for ($i = 0$i < count($matches['0'])$i++)
        {
        $period = ''
        if preg_match("|\.$|", $matches['6'][$i])
          $period = '.'
          $matches['6'][$i] = substr($matches['6'][$i], 0,  - 1)
          
        
        $str = str_replace($matches['0'][$i], $matches['1'][$i] + '<a href="http' + $matches['4'][$i] + '://' + $matches['5'][$i] + $matches['6'][$i] + '"' + $pop + '>http' + $matches['4'][$i] + '://' + $matches['5'][$i] + $matches['6'][$i] + '</a>' + $period, $str)
        }
        
      
    
    if $type isnt 'url'
      if preg_match_all("/([a-zA-Z0-9_\.\-\+]+)@([a-zA-Z0-9\-]+)\.([a-zA-Z0-9\-\.]*)/i", $str, $matches)
        for ($i = 0$i < count($matches['0'])$i++)
        {
        $period = ''
        if preg_match("|\.$|", $matches['3'][$i])
          $period = '.'
          $matches['3'][$i] = substr($matches['3'][$i], 0,  - 1)
          
        
        $str = str_replace($matches['0'][$i], safe_mailto($matches['1'][$i] + '@' + $matches['2'][$i] + '.' + $matches['3'][$i]) + $period, $str)
        }
        
      
    
    return $str
    
  

#  ------------------------------------------------------------------------

#
# Prep URL
#
# Simply adds the http:// part if no scheme is included
#
# @access	public
# @param	string	the URL
# @return	string
#
if not function_exists('prep_url')
  exports.prep_url = prep_url = ($str = '') ->
    if $str is 'http://' or $str is ''
      return ''
      
    
    $url = parse_url($str)
    
    if not $url or  not $url['scheme']? 
      $str = 'http://' + $str
      
    
    return $str
    
  

#  ------------------------------------------------------------------------

#
# Create URL Title
#
# Takes a "title" string as input and creates a
# human-friendly URL string with either a dash
# or an underscore as the word separator.
#
# @access	public
# @param	string	the string
# @param	string	the separator: dash, or underscore
# @return	string
#
if not function_exists('url_title')
  exports.url_title = url_title = ($str, $separator = 'dash', $lowercase = false) ->
    if $separator is 'dash'
      $search = '_'
      $replace = '-'
      
    else 
      $search = '-'
      $replace = '_'
      
    
    $trans = 
      '&\#\d+?;':'', 
      '&\S+?;':'', 
      '\s+':$replace, 
      '[^a-z0-9\-\._]':'', 
      $replace + '+':$replace, 
      $replace + '$':$replace, 
      '^' + $replace:$replace, 
      '\.+$':''
      
    
    $str = strip_tags($str)
    
    for $key, $val of $trans
      $str = preg_replace("#" + $key + "#i", $val, $str)
      
    
    if $lowercase is true
      $str = strtolower($str)
      
    
    return trim(stripslashes($str))
    
  

#  ------------------------------------------------------------------------

#
# Header Redirect
#
# Header redirect in two flavors
# For very fine grained control over headers, you could use the Output
# Library's set_header() function.
#
# @access	public
# @param	string	the URL
# @param	string	the method: location or redirect
# @return	string
#
if not function_exists('redirect')
  exports.redirect = redirect = ($uri = '', $method = 'location', $http_response_code = 302) ->
    if not preg_match('#^https?://#i', $uri)
      $uri = site_url($uri)
      
    
    switch $method
      when 'refresh'header("Refresh:0;url=" + $uri)
        
      elseheader("Location: " + $uri, true, $http_response_code)
        
        
    die()
    
  

#  ------------------------------------------------------------------------

#
# Parse out the attributes
#
# Some of the functions use this
#
# @access	private
# @param	array
# @param	bool
# @return	string
#
if not function_exists('_parse_attributes')
  exports._parse_attributes = _parse_attributes = ($attributes, $javascript = false) ->
    if is_string($attributes)
      return if ($attributes isnt '') then ' ' + $attributes else ''
      
    
    $att = ''
    for $key, $val of $attributes
      if $javascript is true
        $att+=$key + '=' + $val + ','
        
      else 
        $att+=' ' + $key + '="' + $val + '"'
        
      
    
    if $javascript is true and $att isnt ''
      $att = substr($att, 0,  - 1)
      
    
    return $att
    
  


#  End of file url_helper.php 
#  Location: ./system/helpers/url_helper.php 