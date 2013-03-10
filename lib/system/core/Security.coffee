#+--------------------------------------------------------------------+
#  Security.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		  darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		MIT License
# @see 		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#  ------------------------------------------------------------------------

#
# Security Class
#
#
class system.core.Security


  _cookies              : null            # Request cookies
  _query                : null            # Request get array
  _body                 : null            # Request post body
  _server               : null            # Request server properties
  _xss_hash             : ''              # Random Hash for protecting URLs
  _csrf_hash            : ''              # Random Hash for Cross Site Request Forgery Protection Cookie
  _csrf_expire          : 7200            # Expiration time for Cross Site Request Forgery Protection Cookie
  _csrf_token_name      : 'ex_csrf_token' # Token name for Cross Site Request Forgery Protection Cookie
  _csrf_cookie_name     : 'ex_csrf_token' # Cookie name for Cross Site Request Forgery Protection Cookie
  _never_allowed_str    :                 # List of never allowed strings
    'document.cookie'   : '[removed]'
    'document.write'    : '[removed]'
    '.parentNode'       : '[removed]'
    '.innerHTML'        : '[removed]'
    'window.location'   : '[removed]'
    '-moz-binding'      : '[removed]'
    '<!--'              : '&lt;!--'
    '-->'               : '--&gt;'
    '<![CDATA['         : '&lt;![CDATA['
    '<comment>'         : '&lt;comment&gt;'
    
  
  _never_allowed_regex : [                # List of never allowed regex replacement
    'javascript\\s*:'                     #  javascript
    'expression\\s*(\\(|&\\#40;)'         #  CSS and IE
    'vbscript\\s*:'                       #  IE, surprise!
    'Redirect\\s+302'                     #  Redirects
    "([\\\"'])?data\\s*:[^\\\\1]*?base64[^\\\\1]*?,[^\\\\1]*?\\\\1?"
    ]

  #
  # Constructor
  #
  # @param  [Object]  req http request object
  # @param  [Object]  res http response object
  #
  constructor :  ($req, $res) ->

    defineProperties @,
      res       : {writeable: false, value: $res}
      _cookies  : {writeable: false, value: $req.cookies}
      _query    : {writeable: false, value: $req.query}
      _body     : {writeable: false, value: $req.body}
      _server   : {writeable: false, value: $req.server}

    #  Is CSRF protection enabled?
    if config_item('csrf_protection') is true 
      #  CSRF config
      for $key in ['csrf_expire', 'csrf_token_name', 'csrf_cookie_name']
        if false isnt ($val = config_item($key)) 
          @['_' + $key] = $val
      
      #  Append application specific cookie prefix
      if config_item('cookie_prefix') 
        @_csrf_cookie_name = config_item('cookie_prefix') + @_csrf_cookie_name
      
      #  Set the CSRF hash
      @_csrf_set_hash()
    
    log_message('debug', "Security Class Initialized")
    
  
  #
  # Verify Cross Site Request Forgery Protection
  #
  # @return [Void]
  #
  csrfVerify :  ->
    #  If it's not a POST request we will set the CSRF cookie
    if strtoupper(@_server['REQUEST_METHOD']) isnt 'POST' 
      return @csrfSetCookie()
    
    #  Do the tokens exist in both the _POST and _COOKIE arrays?
    if not (@_body[@_csrf_token_name]? and @_cookies[@_csrf_cookie_name]?)
      @csrfShowError()
    
    #  Do the tokens match?
    if @_body[@_csrf_token_name] isnt @_cookies[@_csrf_cookie_name] 
      @csrfShowError()
      
    
    #  We kill this since we're done and we don't want to
    #  polute the _POST array
    delete @_body[@_csrf_token_name]
    
    #  Nothing should last forever
    delete @_cookies[@_csrf_cookie_name]
    @_csrf_set_hash()
    @csrfSetCookie()
    
    log_message('debug', 'CSRF token verified')
    
    return @
    
  
  #
  # Set Cross Site Request Forgery Protection Cookie
  #
  # @return [Void]
  #
  csrfSetCookie :  ->
    $expire = time() + @_csrf_expire
    $secure_cookie = if (config_item('cookie_secure') is true) 1 else 0
    
    if $secure_cookie and (empty(@_server['HTTPS']) or strtolower(@_server['HTTPS']) is 'off') 
      return false

    @res.cookie @_csrf_cookie_name, @_csrf_hash,
      expires : $expire
      domain  : config_item('cookie_domain')
      path    : config_item('cookie_path')
      secure  : $secure_cookie

    log_message('debug', "CRSF cookie Set")

    return @
    
  
  #
  # Show CSRF Error
  #
  #   display's 'The action you have requested is not allowed.'
  #
  # @return [Void]
  #
  csrfShowError :  ->
    show_error('The action you have requested is not allowed.')
    
  
  #
  # Get CSRF Hash
  #
  # @return 	[String] the csrf hash value used
  #
  getCsrfHash :  ->
    return @_csrf_hash
    
  
  #
  # Get CSRF Token Name
  #
  # @return 	[String] the csrf token name used
  #
  getCsrfTokenName :  ->
    return @_csrf_token_name
    
  
  #
  # XSS Clean
  #
  # Sanitizes data so that Cross Site Scripting Hacks can be
  # prevented.  This function does a fair amount of work but
  # it is extremely thorough, designed to prevent even the
  # most obscure XSS attempts.  Nothing is ever 100% foolproof,
  # of course, but I haven't been able to get anything passed
  # the filter.
  #
  # Note: This function should only be used to deal with data
  # upon submission.  It's not something that should
  # be used for general runtime processing.
  #
  # This function was based in part on some code and ideas I
  # got from Bitflux: http://channel.bitflux.ch/wiki/XSS_Prevention
  #
  # To help develop this script I used this great list of
  # vulnerabilities along with a few other hacks I've
  # harvested from examining vulnerabilities in other programs:
  # http://ha.ckers.org/xss.html
  #
  # @param  [String]  str string to clean
  # @param 	[Boolean] is_image  is it an image?
  # @return	[String] cleaned string
  #
  xssClean : ($str, $is_image = false) ->
    #
    # Is the string an array?
    #
    #
    if is_array($str)
      for $key, $val of $str
        $str[$key] = @xssClean($val)
      return $str
    #
    # Remove Invisible Characters
    #
    $str = remove_invisible_characters($str)
    ##  Validate Entities in URLs#
    $str = @_validate_entities($str)
    # URL Decode
    #
    # Just in case stuff like this is submitted:
    #
    # <a href="http://%77%77%77%2E%67%6F%6F%67%6C%65%2E%63%6F%6D">Google</a>
    #
    # Note: Use rawurldecode() so it does not remove plus signs
    #
    $str = rawurldecode($str)
    ##
    # Convert character entities to ASCII
    #
    # This permits our tests below to work reliably.
    # We only convert entities that are within tags since
    # these are the ones that will pose security problems.
    #
    ##
    $str = $str.replace(/[a-z]+=([\'\"]).*?\\1/mig, @_convert_attribute)
    $str = $str.replace(/<\w+.*?(?=>|<|$)/mig, @_decode_entity)
    # Remove Invisible Characters Again!
    $str = remove_invisible_characters($str)
    ##
    # Convert all tabs to spaces
    #
    # This prevents strings like this: ja	vascript
    # NOTE: we deal with spaces between characters later.
    # NOTE: preg_replace was found to be amazingly slow here on
    # large blocks of data, so we use str_replace.
    ##
    if strpos($str, "\t") isnt false then $str = str_replace("\t", ' ', $str)

    # Capture converted string for later comparison
    $converted_string = $str
    ##  Remove Strings that are never allowed
    $str = @_do_never_allowed($str)
    # Makes PHP tags safe
    #
    # Note: XML tags are inadvertently replaced too:
    #
    # <?xml

    #
    # But it doesn't seem to pose a problem.
    if $is_image is true
      #  Images have a tendency to have the PHP short opening and
      #  closing tags every so often so we skip those and only
      #  do the long opening tags.
      $str = $str.replace(/<\\?(php)/i, "&lt;?$1")
    else
      $str = str_replace(['<?', '?>'], ['&lt;?', '?&gt;'], $str)
    ##
    # Compact any exploded words
    #
    # This corrects words like:  j a v a s c r i p t
    # These words are compacted back to their correct state.
    ##
    $words = [
      'javascript', 'expression', 'vbscript', 'script', 'base64',
      'applet', 'alert', 'document', 'write', 'cookie', 'window'
    ]
    for $word in $words
      $temp = ''

      $wordlen = strlen($word)
      for $i in [0...$wordlen]
        $temp+=substr($word, $i, 1) + "\\s*"
      $str = preg_replace_callback('#(' + substr($temp, 0,  - 3) + ')(\\W)#im', [@, '_compact_exploded_words'], $str)
    # Remove disallowed Javascript in links or img tags
    # We used to do some version comparisons and use of stripos for PHP5,
    # but it is dog slow compared to these simplified non-capturing
    # preg_match(), especially if the pattern exists in the string
    #
    while true
      #  We only want to do this when it is followed by a non-word character
      #  That way valid stuff like "dealer to" does not become "dealerto"
      $original = $str

      if /<a/i.test($str) then $str = $str.replace(/<a\s+([^>]*?)(>|$)/mig, @_js_link_removal)

      if /<img/i.test($str) then $str = $str.replace(/<img\s+([^>]*?)(\s?\/?>|$)/mig, @_js_img_removal)


      if /script/i.test($str) or /xss/i.test($str) then $str = $str.replace(/<(\/*)(script|xss)(.*?)\\>/mig, @removed)

      break unless $original isnt $str
    # delete $original
    #  Remove evil attributes such as style, onclick and xmlns
    $str = @_remove_evil_attributes($str, $is_image)
    
    #
    # Sanitize naughty HTML elements
    #
    # If a tag containing any of the words in the list
    # below is found, the tag gets converted to entities.
    #
    # So this: <blink>
    # Becomes: &lt;blink&gt;
    #
    $naughty = 'alert|applet|audio|basefont|base|behavior|bgsound|blink|body|embed|expression|form|frameset|frame|head|html|ilayer|iframe|input|isindex|layer|link|meta|object|plaintext|style|script|textarea|title|video|xml|xss'
    $str = preg_replace_callback('#<(/*\\s*)(' + $naughty + ')([^><]*)([><]*)#img', [@, '_sanitize_naughty_html'], $str)
    
    #
    # Sanitize naughty scripting elements
    #
    # Similar to above, only instead of looking for
    # tags it looks for PHP and JavaScript commands
    # that are disallowed.  Rather than removing the
    # code, it simply converts the parenthesis to entities
    # rendering the code un-executable.
    #
    # For example:	eval('some code')
    # Becomes:		eval&#40;'some code'&#41;
    #
    $str = preg_replace('#(alert|cmd|passthru|eval|exec|expression|system|fopen|fsockopen|file|file_get_contents|readfile|unlink)(\\s*)\\((.*?)\\)#mig', "$1$2&#40;$3&#41;", $str)

    #  Final clean up
    #  This adds a bit of extra precaution in case
    #  something got through the above filters
    $str = @_do_never_allowed($str)
    
    #
    # Images are Handled in a Special Way
    # - Essentially, we want to know that after all of the character
    # conversion is done whether any unwanted, likely XSS, code was found.
    # If not, we return TRUE, as the image is clean.
    # However, if the string post-conversion does not matched the
    # string post-removal of XSS, it fails, as there was unwanted XSS
    # code found and removed/changed during processing.
    #
    
    if $is_image is true 
      return if ($str is $converted_string) true else false

    log_message('debug', "XSS Filtering completed")
    return $str
    
  time = -> Math.floor(Date.now()/100000)

  #
  # Random Hash for protecting URLs
  #
  # @return	[String] gets the xss hash
  #
  xss_hash :  ->
    if @_xss_hash is '' 
      # mt_srand()
      @_xss_hash = md5(''+time() + mt_rand(0, 1999999999))

    return @_xss_hash

  #
  # HTML Entities Decode
  #
  # This function is a replacement for html_entity_decode()
  #
  # The reason we are not using html_entityDecode() by itself is because
  # while it is not technically correct to leave out the semicolon
  # at the end of an entity most browsers will still interpret the entity
  # correctly.  html_entityDecode() does not convert entities without
  # semicolons, so we are left with our own little solution here. Bummer.
  #
  # @param  [String]  str string to be decoded
  # @param  [String]  charset optional encoding (default UTF-8)
  # @return	[String] the decoded string value
  #
  entityDecode : ($str, $charset = 'UTF-8') ->
    if stristr($str, '&') is false 
      return $str
      
    
    #$str = html_entityDecode($str, ENT_COMPAT, $charset)
    $str = htmlspecialchars($str)
    $str = preg_replace('~&#x(0*[0-9a-f]{2,5})~i', 'chr(hexdec("$1"))', $str)
    return preg_replace('~&#([0-9]{2,4})~', 'chr($1)', $str)
    
  
  #
  # Filename Security
  #
  # Cleans a filepath string, removing invisible and invalid characters
  #
  # @param  [String]  str a file name
  # @param 	[Boolean] relative_path is a realative path (default false)
  # @return	[String] clean string
  #
  sanitizeFilename : ($str, $relative_path = false) ->
    $bad = [
      "../" 
      "<!--" 
      "-->" 
      "<" 
      ">" 
      "'" 
      '"' 
      '&' 
      '$' 
      '#' 
      '{' 
      '}' 
      '[' 
      ']' 
      '=' 
      ';' 
      '?' 
      "%20" 
      "%22" 
      "%3c"     #  <
      "%253c"   #  <
      "%3e"     #  >
      "%0e"     #  >
      "%28"     #  (
      "%29"     #  )
      "%2528"   #  (
      "%26"     #  &
      "%24"     #  $
      "%3f"     #  ?
      "%3b"     #  ;
      "%3d"     #  =
      ]
    
    if not $relative_path 
      $bad.push './'
      $bad.push '/'
      
    
    $str = remove_invisible_characters($str, false)
    return stripslashes(str_replace($bad, '', $str))
    
  
  #
  # Compact Exploded Words
  #
  # Callback function for xssClean() to remove whitespace from
  # things like j a v a s c r i p t
  #
  # @private
  # @param	type
  # @return	type
  #
  _compact_exploded_words : ($matches...) ->
    return preg_replace('/\\s+/gm', '', $matches[1]) + $matches[2]
    
  
  #
  # Remove Evil HTML Attributes (like evenhandlers and style)
  #
  # It removes the evil attribute and either:
  # 	- Everything up until a space
  #		For example, everything between the pipes:
  #		<a |style=document.write('hello');alert('world');| class=link>
  # 	- Everything inside the quotes
  #		For example, everything between the pipes:
  #		<a |style="document.write('hello'); alert('world');"| class="link">
  #
  # @private
  # @param  [String]  $str The string to check
  # @param boolean $is_image TRUE if this is an image
  # @return string The string with the evil attributes removed
  #
  _remove_evil_attributes : ($str, $is_image) ->

    #  All javascript event handlers (e.g. onload, onclick, onmouseover), style, and xmlns
    $evil_attributes = ['on\\w*', 'style', 'xmlns', 'formaction']
    
    if $is_image is true
      #
      # Adobe Photoshop puts XML metadata into JFIF images,
      # including namespacing, so we have to allow this for images.
      #
      delete $evil_attributes[array_search('xmlns', $evil_attributes)]
      
    
    while true
      $count = 0
      $attribs = []
      
      #  find occurrences of illegal attribute strings without quotes
      $matches = preg_match_all('/(' + implode('|', $evil_attributes) + ')\\s*=\\s*([^\\s>]*)/img', $str, $matches, PREG_SET_ORDER)

      if $matches?
        for $attr in $matches
          $attribs.push preg_quote($attr[0], '/')

      #  find occurrences of illegal attribute strings with quotes (042 and 047 are octal quotes)
      $matches = preg_match_all("/(" + implode('|', $evil_attributes) + ")\\s*=\\s*(\\x22|\\x27)([^\\\\2]*?)(\\\\2)/img", $str, $matches, PREG_SET_ORDER)

      if $matches?
        for $attr in $matches
          $attribs.push preg_quote($attr[0], '/')

      #  replace illegal attribute strings that are inside an html tag

      if count($attribs) > 0
        #$str = preg_replace("/<(\/?[^><]+?)([^A-Za-z<>\\-])(.*?)(" + implode('|', $attribs) + ")(.*?)([\\s><])([><]*)/i", '<$1 $3$5$6$7', $str,  - 1, $count)
        $re = new RegExp("<(\/?[^><]+?)([^A-Za-z<>\\-])(.*?)(" + implode('|', $attribs) + ")(.*?)([\\s><])([><]*)", 'i')
        $count = $re.match($str).length
        $str = $str.replace($re, '<$1 $3$5$6$7')
        counsole.log $re

      break unless $count
    
    return $str
    
  
  #
  # Sanitize Naughty HTML
  #
  # Callback function for xssClean() to remove naughty HTML elements
  #
  # @private
  # @param  [Array]
  # @return	[String]
  #
  _sanitize_naughty_html : ($matches...) =>
    #  encode opening brace
    $str = '&lt;' + $matches[1] + $matches[2] + $matches[3]
    
    #  encode captured opening or closing brace to prevent recursive vectors
    $str+=str_replace(['>', '<'], ['&gt;', '&lt;'], 
    $matches[4])
    
    return $str
    
  
  #
  # JS Link Removal
  #
  # Callback function for xssClean() to sanitize links
  # This limits the PCRE backtracks, making it more performance friendly
  # and prevents PREG_BACKTRACK_LIMIT_ERROR from being triggered in
  # PHP 5.2+ on link-heavy strings
  #
  # @private
  # @param  [Array]
  # @return	[String]
  #
  _js_link_removal : ($match...) =>
    return str_replace($match[1], preg_replace('#href=.*?(alert\(|alert&\\#40;|javascript\\:|livescript\\:|mocha\\:|charset\\=|window\\.|document\\.|\\.cookie|<script|<xss|data\\s*:)#mig', '', @_filter_attributes(str_replace(['<', '>'], '', $match[1]))
    ), 
    $match[0]
    )
    
  
  #
  # JS Image Removal
  #
  # Callback function for xssClean() to sanitize image tags
  #
  # @private
  # @param  [Array]
  # @return	[String]
  #
  _js_img_removal : ($match...) =>
    return str_replace($match[1], preg_replace('#src=.*?(alert\(|alert&\\#40;|javascript\\:|livescript\\:|mocha\\:|charset\\=|window\\.|document\\.|\\.cookie|<script|<xss|base64\\s*,)#mig', '', @_filter_attributes(str_replace(['<', '>'], '', $match[1]))
    ), 
    $match[0]
    )
    
  
  #
  # Attribute Conversion
  #
  # Used as a callback for XSS Clean
  #
  # @private
  # @param  [Array]
  # @return	[String]
  #
  _convert_attribute : ($match...) =>
    return str_replace(['>', '<', '\\'], ['&gt;', '&lt;', '\\\\'], $match[0])
    
  
  #
  # Filter Attributes
  #
  # Filters tag attributes for consistency and safety
  #
  # @private
  # @param  [String]
  # @return	[String]
  #
  _filter_attributes : ($str) ->
    $out = ''
    
    if preg_match_all('#\\s*[a-z\\-]+\\s*=\\s*(\\x22|\\x27)([^\\\\1]*?)\\\\1#img', $str, $matches)
      for $match in $matches[0]
        $out+=preg_replace("#/\\*.*?\\*/#mg", '', $match)

    return $out
    
  
  #
  # HTML Entity Decode Callback
  #
  # Used as a callback for XSS Clean
  #
  # @private
  # @param  [Array]
  # @return	[String]
  #
  _decode_entity : ($match...) =>
    return @entityDecode($match[0], strtoupper(config_item('charset')))
    
  
  #
  # Validate URL entities
  #
  # Called by xssClean()
  #
  # @private
  # @param  [String]
  # @return 	string
  #
  _validate_entities : ($str) ->
    #
    # Protect GET variables in URLs
    #
    
    #  901119URL5918AMP18930PROTECT8198
    
    $str = preg_replace('|\\&([a-z\\_0-9\\-]+)\\=([a-z\\_0-9\\-]+)|i', @xss_hash() + "$1=$2", $str)
    
    #
    # Validate standard character entities
    #
    # Add a semicolon if missing.  We do this to enable
    # the conversion of entities to ASCII later.
    #
    #
    $str = preg_replace('#(&\\#?[0-9a-z]{2,})([\\x00-\\x20])*;?#i', "$1;$2", $str)
    
    #
    # Validate UTF16 two byte encoding (x00)
    #
    # Just as above, adds a semicolon if missing.
    #
    #
    $str = preg_replace('#(&\\#x?)([0-9A-F]+);?#i', "$1$2;", $str)
    
    #
    # Un-Protect GET variables in URLs
    #
    $str = str_replace(@xss_hash(), '&', $str)
    
    return $str
    
  
  #
  # Do Never Allowed
  #
  # A utility function for xssClean()
  #
  # @private
  # @param  [String]
  # @return 	string
  #
  _do_never_allowed : ($str) ->
    $str = str_replace(array_keys(@_never_allowed_str), @_never_allowed_str, $str)
    
    for $regex in @_never_allowed_regex
      $str = preg_replace('#' + $regex + '#im', '[removed]', $str)

    return $str
    
  
  #
  # Set Cross Site Request Forgery Protection Cookie
  #
  # @private
  # @return	[String]
  #
  _csrf_set_hash :  ->
    if @_csrf_hash is '' 
      #  If the cookie exists we will use it's value.
      #  We don't necessarily want to regenerate it with
      #  each page load since a page could contain embedded
      #  sub-pages causing this feature to fail
      if @_cookies[@_csrf_cookie_name]?  and preg_match('#^[0-9a-f]{32}$#i', @_cookies[@_csrf_cookie_name])?
        return @_csrf_hash = @_cookies[@_csrf_cookie_name]
      
      return @_csrf_hash = md5(uniqid(rand(), true))
    
    return @_csrf_hash


module.exports = system.core.Security

#  End of file Security.coffee
#  Location: .system/core/Security.coffee