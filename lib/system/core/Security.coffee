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

  {md5, preg_quote, uniqid} = require(SYSPATH+'core.coffee')

  _xss_hash             : ''              # Random Hash for protecting URLs
  _csrf_hash            : ''              # Random Hash for Cross Site Request Forgery Protection Cookie
  _csrf_expire          : 7200            # Expiration time for Cross Site Request Forgery Protection Cookie
  _csrf_token_name      : 'ex_csrf_token' # Token name for Cross Site Request Forgery Protection Cookie
  _csrf_cookie_name     : 'ex_csrf_token' # Cookie name for Cross Site Request Forgery Protection Cookie
  _never_allowed_str    : [                 # List of never allowed strings
    [/document.cookie/gm    , '[removed]']
    [/document.write/gm     , '[removed]']
    [/\.parentNode/gm       , '[removed]']
    [/\.innerHTML/gm        , '[removed]']
    [/window\.location/gm   , '[removed]']
    [/-moz-binding/gm       , '[removed]']
    [/<!--/gm               , '&lt;!--']
    [/-->/gm                , '--&gt;']
    [/<!\[CDATA\[/gm        , '&lt;![CDATA[']
    [/<comment>/gm          , '&lt;comment&gt;']
  ]
  
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
      req       : {writeable: false, value: $req}
      res       : {writeable: false, value: $res}

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
    if @req.method.toUpperCase() isnt 'POST'
      return @csrfSetCookie()
    
    #  Do the tokens exist in both the POST and COOKIE arrays?
    if not (@req.body[@_csrf_token_name]? and @req.cookies[@_csrf_cookie_name]?)
      @csrfShowError()
    
    #  Do the tokens match?
    if @req.body[@_csrf_token_name] isnt @req.cookies[@_csrf_cookie_name] 
      @csrfShowError()

    #  We kill this since we're done and we don't want to
    #  polute the POST array
    delete @req.body[@_csrf_token_name]
    
    #  Nothing should last forever
    delete @req.cookies[@_csrf_cookie_name]
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
    
    if $secure_cookie and (not $req.connection.encrypted)
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
    #
    if $str.indexOf('\t') isnt -1 then $str = $str.replace(/\t/mg, ' ')

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
      $str = $str.replace(/<?/mg, '&lt;?').replace(/?>/mg, '?&gt;')
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

      $wordlen = $word.length
      for $i in [0...$wordlen]
        $temp+=substr($word, $i, 1) + "\\s*"

      $str = $str.replace(RegExp('(' + substr($temp, 0,  - 3) + ')(\\W)', 'im'), @_compact_exploded_words)
    # Remove disallowed Javascript in links or img tags
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

    $str = $str.replace(RegExp('<(/*\\s*)(' + $naughty + ')([^><]*)([><]*)', 'img'), @_sanitize_naughty_html)
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
    $re = RegExp('(alert|cmd|passthru|eval|exec|expression|system|fopen|fsockopen|file|file_get_contents|readfile|unlink)(\\s*)\\((.*?)\\)', 'mig')
    $str = $str.replace($re, "$1$2&#40;$3&#41;")

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

      Math.floor(Math.random() * 1999999999)

      @_xss_hash = md5(''+time() + (Math.floor(Math.random() * 1999999999)))

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

    return $str if $str.indexOf('&') is -1

    $str = htmlspecialchars($str)
    $str = $str.replace(/&#x(0*[0-9a-f]{2,5})/ig, ($0, $1) -> String.fromCharCode(parseInt($1, 16)))
    $str = $str.replace(/&#([0-9]{2,4})/g, ($0, $1) -> String.fromCharCode(parseInt($1, 10)))

  
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
    $ruin = [
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
      $ruin.push './'
      $ruin.push '/'
      
    
    $str = remove_invisible_characters($str, false)

    for $bad in $ruin # Long Player
      $str = $str.replace($bad, '')

    return stripslashes($str)
    
  
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
  _compact_exploded_words : ($0, $1, $2) ->

    $1.replace(/\\s+/gm, '')+$2

  
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
    #
    # Adobe Photoshop puts XML metadata into JFIF images,
    # including namespacing, so we have to allow this for images.
    #
    $evil_attributes = if $is_image then ['on\\w*', 'style', 'formaction']
    else ['on\\w*', 'style', 'xmlns', 'formaction']
    

    while true
      $count = 0
      $attribs = []
      
      #  find occurrences of illegal attribute strings without quotes
      $re = RegExp('(' + $evil_attributes.join('|') + ')\\s*=\\s*([^\\s>]*)', 'img')
      while ($match = $re.exec($str)) isnt null
        $attribs.push preg_quote($match)

      #  find occurrences of illegal attribute strings with quotes (042 and 047 are octal quotes)
      $re = RegExp("(" + $evil_attributes.join('|') + ")\\s*=\\s*(\\x22|\\x27)([^\\\\2]*?)(\\\\2)", "img")
      while ($match = $re.exec($str)) isnt null
        $attribs.push preg_quote($match)

      #  replace illegal attribute strings that are inside an html tag

      if $attribs.length > 0
        #$str = preg_replace("/<(\/?[^><]+?)([^A-Za-z<>\\-])(.*?)(" + implode('|', $attribs) + ")(.*?)([\\s><])([><]*)/i", '<$1 $3$5$6$7', $str,  - 1, $count)
        $re = RegExp("<(\/?[^><]+?)([^A-Za-z<>\\-])(.*?)(" + $attribs.join('|') + ")(.*?)([\\s><])([><]*)", 'igm')
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
  _sanitize_naughty_html : ($0, $1, $2, $3, $4) =>
    #  encode opening brace
    $str = '&lt;' + $1 + $2 + $3
    
    #  encode captured opening or closing brace to prevent recursive vectors
    $str += $4(/>/gm, '&gt;').replace(/</gm, '&lt;')

  
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
  _js_link_removal : ($0, $1) =>

    $re = RegExp('href=.*?(alert\(|alert&\\#40;|javascript\\:|livescript\\:|mocha\\:|charset\\=|window\\.|document\\.|\\.cookie|<script|<xss|data\\s*:)', 'mig')

    $0.replace($1, @_filter_attributes($1.replace(/[<>]/mg, '')).replace($re, ''))

  
  #
  # JS Image Removal
  #
  # Callback function for xssClean() to sanitize image tags
  #
  # @private
  # @param  [Array]
  # @return	[String]
  #
  _js_img_removal : ($0, $1) =>

    $re = RegExp('src=.*?(alert\(|alert&\\#40;|javascript\\:|livescript\\:|mocha\\:|charset\\=|window\\.|document\\.|\\.cookie|<script|<xss|base64\\s*,)', 'mig')

    $0.replace($1, @_filter_attributes($1.replace(/[<>]/mg, '')).replace($re, ''))


  #
  # Attribute Conversion
  #
  # Used as a callback for XSS Clean
  #
  # @private
  # @param  [Array]
  # @return	[String]
  #
  _convert_attribute : ($0) =>

    $0.replace(/>/gm, '&gt;').replace(/</gm, '&lt;').replace(/\\/gm, '\\\\')

  
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


    $re = RegExp('\\s*[a-z\\-]+\\s*=\\s*(\\x22|\\x27)([^\\\\1]*?)\\\\1', 'img')
    while ($match = $re.exec($str)) isnt null
      $out+= $match.replace(/\/\\*.*?\\*\//mg, '')
    $out

  
  #
  # HTML Entity Decode Callback
  #
  # Used as a callback for XSS Clean
  #
  # @private
  # @param  [Array]
  # @return	[String]
  #
  _decode_entity : ($0) =>
    @entityDecode($0, (config_item('charset').toUpperCase()))
    
  
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

    $str = $str.replace(/\\&([a-z\\_0-9\\-]+)\\=([a-z\\_0-9\\-]+)/igm, @xss_hash() + "$1=$2")

    #
    # Validate standard character entities
    #
    # Add a semicolon if missing.  We do this to enable
    # the conversion of entities to ASCII later.
    #
    #
    $str = $str.replace(/(&\\#?[0-9a-z]{2,})([\\x00-\\x20])*;?/igm, "$1;$2")

    #
    # Validate UTF16 two byte encoding (x00)
    #
    # Just as above, adds a semicolon if missing.
    #
    #
    $str = $str.replace(/(&\\#x?)([0-9A-F]+);?/igm, "$1$2;")

    #
    # Un-Protect GET variables in URLs
    #
    $str = $str.replace(RegExp(@xss_hash(), 'igm'), '&')
    
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

    for $pair in @_never_allowed_str
      $str = $str.replace($pair[0], $paid[1])

    for $regex in @_never_allowed_regex
      $str = $str.replace($regex, '[removed]')

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
      if @req.cookies[@_csrf_cookie_name]?  and /^[0-9a-f]{32}$/im.test(@req.cookies[@_csrf_cookie_name])
        return @_csrf_hash = @req.cookies[@_csrf_cookie_name]
      
      return @_csrf_hash = md5(uniqid(Math.floor(Math.random() * 2147483647)))
    
    return @_csrf_hash


module.exports = system.core.Security

#  End of file Security.coffee
#  Location: .system/core/Security.coffee