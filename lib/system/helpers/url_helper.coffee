#+--------------------------------------------------------------------+
#  url_helper.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso URL Helpers
#
#

#  ------------------------------------------------------------------------

#
# Site URL
#
# Create a local URL based on your basepath. Segments can be passed via the
# first parameter either as a string or an array.
#
# @param  [String]  # @return	[String]
#
if not function_exists('site_url')
  exports.site_url = site_url = ($uri = '') ->
    return @config.siteUrl($uri)
    
  

#  ------------------------------------------------------------------------

#
# Base URL
#
# Returns the "base_url" item from your config file
#
# @return	[String]
#
if not function_exists('base_url')
  exports.base_url = base_url =  ->
    return @config.slashItem('base_url')
    
  

#  ------------------------------------------------------------------------

#
# Current URL
#
# Returns the full URL (including segments) of the page where this
# function is placed
#
# @return	[String]
#
if not function_exists('current_url')
  exports.current_url = current_url =  ->
    
    return @config.siteUrl(@uri.uriString())
    
  

#  ------------------------------------------------------------------------
#
# URL String
#
# Returns the URI segments.
#
# @return	[String]
#
if not function_exists('uri_string')
  exports.uriString = uri_string =  ->
    
    return @uri.uriString()
    
  

#  ------------------------------------------------------------------------

#
# Index page
#
# Returns the "index_page" from your config file
#
# @return	[String]
#
if not function_exists('index_page')
  exports.index_page = index_page =  ->
    
    return @config.item('index_page')
    
  

#  ------------------------------------------------------------------------

#
# Anchor Link
#
# Creates an anchor based on the local URL.
#
# @param  [String]  the URL
# @param  [String]  the link title
# @param  [Mixed]  any attributes
# @return	[String]
#
if not function_exists('anchor')
  exports.anchor = anchor = ($uri = '', $title = '', $attributes = '') ->
    $title = ''+$title
    
    if not is_array($uri)
      $site_url = if ( not preg_match('!^\\w+://!i', $uri)?) then @site_url($uri) else $uri
      #$site_url = $uri
      
    else 
      #$site_url = site_url($uri)
      $site_url = $uri.join('/')

    
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
# @param  [String]  the URL
# @param  [String]  the link title
# @param  [Mixed]  any attributes
# @return	[String]
#
if not function_exists('anchor_popup')
  exports.anchor_popup = anchor_popup = ($uri = '', $title = '', $attributes = false) ->
    $title = ''+$title
    
    $site_url = if ( not preg_match('!^\\w+://! i', $uri)? ) then site_url($uri) else $uri
    
    if $title is ''
      $title = $site_url
      
    
    if $attributes is false
      return "<a href='javascript:void(0);' onclick=\"window.open('" + $site_url + "', '_blank');\">" + $title + "</a>"
      
    
    if not is_array($attributes)
      $attributes = {}
      
    
    for $key, $val of {width:'800', height:'600', scrollbars:'yes', status:'yes', resizable:'yes', screenx:'0', screeny:'0'}
      $atts[$key] = if ( not $attributes[$key]? ) then $val else $attributes[$key]
      delete $attributes[$key]
      
    
    if $attributes isnt ''
      $attributes = _parse_attributes($attributes)
      
    
    return "<a href='javascript:void(0);' onclick=\"window.open('" + $site_url + "', '_blank', '" + _parse_attributes($atts, true) + "');\"$attributes>" + $title + "</a>"
    
  

#  ------------------------------------------------------------------------

#
# Mailto Link
#
# @param  [String]  the email address
# @param  [String]  the link title
# @param  [Mixed]  any attributes
# @return	[String]
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
# @param  [String]  the email address
# @param  [String]  the link title
# @param  [Mixed]  any attributes
# @return	[String]
#
if not function_exists('safe_mailto')
  exports.safe_mailto = safe_mailto = ($email, $title = '', $attributes = '') ->
    $title = ''+$title
    
    if $title is ""
      $title = $email
      
    $x = []
    $x.push $c for $c in '<a href="mailto:'
    $x.push "|" + $c.charCodeAt(0) for $c in $email
    $x.push '"'
    
    if $attributes isnt ''
      if is_array($attributes)
        for $key, $val of $attributes
          $x.push ' ' + $key + '="'
          $x.push "|" + $c.charCodeAt(0) for $c in $val
          $x.push '"'
          
        
      else
        $x.push $c for $c in $attributes

    
    $x.push '>'
    
    $temp = []
    for $c in $title
      $ordinal = $c.charCodeAt(0)

      if $ordinal < 128
        $x.push "|" + $ordinal

      else
        if count($temp) is 0
          $count = if ($ordinal < 224) then 2 else 3


        $temp.push $ordinal
        if count($temp) is $count
          $number = if ($count is 3) then (($temp['0'] % 16) * 4096) + (($temp['1'] % 64) * 64) + ($temp['2'] % 64) else (($temp['0'] % 32) * 64) + ($temp['1'] % 64)
          $x.push "|" + $number
          $count = 1
          $temp = []

      

    $x.push '<'
    $x.push '/'
    $x.push 'a'
    $x.push '>'
    
    $x = array_reverse($x)

    return $x.join('')

  

#  ------------------------------------------------------------------------

#
# Auto-linker
#
# Automatically links URL and Email addresses.
# Note: There's a bit of extra code here to deal with
# URLs or emails that end in a period.  We'll strip these
# off and add them after the link.
#
# @param  [String]  the string
# @param  [String]  the type: email, url, or both
# @return	[Boolean]	whether to create pop-up links
# @return	[String]
#
if not function_exists('auto_link')
  exports.auto_link = auto_link = ($str, $type = 'both', $popup = false) ->
    if $type isnt 'email'
      $matches = preg_match_all("#(^|\s|\()((http(s?)://)|(www\.))(\w+[^\s\)\<]+)#i", $str)
      if $matches.length
        $pop = if ($popup is true) then " target=\"_blank\" " else ""
        
        for $i in [0..count($matches['0'])-1]
          $period = ''
          if preg_match("|\\.$|", $matches['6'][$i])?
            $period = '.'
            $matches['6'][$i] = substr($matches['6'][$i], 0,  - 1)


          $str = str_replace($matches['0'][$i], $matches['1'][$i] + '<a href="http' + $matches['4'][$i] + '://' + $matches['5'][$i] + $matches['6'][$i] + '"' + $pop + '>http' + $matches['4'][$i] + '://' + $matches['5'][$i] + $matches['6'][$i] + '</a>' + $period, $str)

      
    
    if $type isnt 'url'
      if preg_match_all("/([a-zA-Z0-9_\\.\\-\\+]+)@([a-zA-Z0-9\\-]+)\\.([a-zA-Z0-9\\-\\.]*)/i", $str, $matches)
        for $i in [0..count($matches['0'])-1]
          $period = ''
          if preg_match("|\\.$|", $matches['3'][$i])
            $period = '.'
            $matches['3'][$i] = substr($matches['3'][$i], 0,  - 1)


          $str = str_replace($matches['0'][$i], safe_mailto($matches['1'][$i] + '@' + $matches['2'][$i] + '.' + $matches['3'][$i]) + $period, $str)

      
    
    return $str
    
  

#  ------------------------------------------------------------------------

#
# Prep URL
#
# Simply adds the http:// part if no scheme is included
#
# @param  [String]  the URL
# @return	[String]
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
# @param  [String]  the string
# @param  [String]  the separator: dash, or underscore
# @return	[String]
#
if not function_exists('url_title')
  exports.url_title = url_title = ($str, $separator = 'dash', $lowercase = false) ->
    if $separator is 'dash'
      $separator = '-'
    else if $separator is 'underscore'
      $separator = '_'

    $q_separator = preg_quote($separator)

    $trans =
      '&.+?;': ''
      '[^a-z0-9 _-]': ''
      '\\s+': $separator

    $trans['('+$q_separator+')+'] = $separator

    
    $str = strip_tags($str)
    
    for $key, $val of $trans
      $str = preg_replace("#" + $key + "#i", $val, $str)
      
    
    if $lowercase is true
      $str = strtolower($str)


    return trim($str, $separator)
    
  

#  ------------------------------------------------------------------------

#
# Parse out the attributes
#
# Some of the functions use this
#
# @private
# @param  [Array]  # @return	[Boolean]
# @return	[String]
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