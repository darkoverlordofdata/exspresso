#+--------------------------------------------------------------------+
#| Output.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Input Class
#
class system.core.Input

  os = require('os')

  _headers              : null    # The list of HTTP request headers
  _ip_address           : false   # The IP address of the current user
  _user_agent           : false   # The user agent (web browser) being used by the current user
  _allow_get_array      : false   # If FALSE, then $_GET will be set to an empty array
  _standardize_newlines : false   # If TRUE, then newlines are standardized
  _enable_xss           : false   # Determines whether the XSS filter is always active
  _enable_csrf          : false   # Enables a CSRF cookie token to be set.

  #
  # Constructor
  #
  # @param  [Object]  req http request object
  # @param  [system.core.Utf8]  utf Encoding utility object
  # @param  [system.code.Security]  security  Security utility object
  # @return [Void]
  #
  constructor: ($req, $utf, $security) ->

    defineProperties @,
      req:      {writeable: false, value: $req}
      utf:      {writeable: false, value: $utf}
      security: {writeable: false, value: $security}

    log_message('debug', "Input Class Initialized")

    @_allow_get_array = if config_item('allow_get_array') then true else false
    @_enable_xss      = if config_item('global_xss_filtering') then true else false
    @_enable_csrf     = if config_item('csrf_protection') then true else false
    @_sanitize_globals()


  #
  # Fetch an item from the GET array
  #
  # @param  [String]  index key into the GET hash
  # @param	[Boolean] xss_clean scrub the return value?
  # @return	[String] the value found at index
  #
  get : ($index = null, $xss_clean = false) ->

    #  Check if a field has been provided
    if $index is null and  not empty(@req.query)
      $get = {}

      #  loop through the full _GET array
      for $key in array_keys(@req.query)
        $get[$key] = @_fetch_from_array(@req.query, $key, $xss_clean)
      return $get

    return @_fetch_from_array(@req.query, $index, $xss_clean)


  #
  # Fetch an item from the POST array
  #
  # @param  [String]  index key into the POST hash
  # @param	[Boolean] xss_clean scrub the return value?
  # @return	[String] the value found at index
  #
  post : ($index = null, $xss_clean = false) ->

    #  Check if a field has been provided
    if $index is null and Object.keys(@req.body).length>0
      $post = {}

      #  Loop through the full POST array and return it
      for $key, $val of @req.body
        $post[$key] = @_fetch_from_array(@req.body, $key, $xss_clean)
      return $post

    return @_fetch_from_array(@req.body, $index, $xss_clean)

  #
  # Fetch an item from either the GET array or the POST
  #
  # @param  [String]  index key into both GET/POST hash'
  # @param	[Boolean] xss_clean scrub the return value?
  # @return	[String] the value found at index
  #
  getPost : ($index = '', $xss_clean = false) ->

    if not @req.body[$index]?
      @get($index, $xss_clean)
    else
      @post($index, $xss_clean)

  #
  # Fetch an item from the COOKIE array
  #
  # @param  [String]  index key into the COOKIE hash
  # @param	[Boolean] xss_clean scrub the return value?
  # @return	[String] the value found at index
  #
  cookie : ($index = '', $xss_clean = false) ->
    return @_fetch_from_array(@req.cookies, $index, $xss_clean)

  #
  # Set cookie
  #
  # Accepts six parameter, or you can submit an associative
  # array in the first parameter containing all the values.
  #
  # @param  [String]  name  the cookie name
  # @param  [String]  value the value of the cookie
  # @param  [String]  expires the number of seconds until expiration
  # @param  [String]  domain  the cookie domain.  Usually:  .yourdomain.com
  # @param  [String]  path  the cookie path
  # @param  [String]  prefix  the cookie prefix
  # @param	[Boolean]	secure  true makes the cookie secure
  # @return [Void]
  #
  setCookie : ($name = '', $value = '', $expire = '', $domain = '', $path = '/', $prefix = '', $secure = false) ->

    if $prefix is '' and config_item('cookie_prefix') isnt ''
      $prefix = config_item('cookie_prefix')
    if $domain is '' and config_item('cookie_domain') isnt ''
      $domain = config_item('cookie_domain')
    if $path is '/' and config_item('cookie_path') isnt '/'
      $path = config_item('cookie_path')

    if $secure is false and config_item('cookie_secure') isnt false
      $secure = config_item('cookie_secure')

    $expire = if typeof $expire is 'number'
      if ($expire > 0) then time() + $expire else 0
    else
      time() - 86500

    @res.cookie $prefix+$name, $value,
      expires : $expire
      domain  : $domain
      path    : $path
      secure  : $secure

  #
  # Fetch the IP Address
  #
  # @return	[String]  the client IP
  #
  ipAddress :  ->
    if @_ip_address isnt false
      return @_ip_address

    $proxy_ips = config_item('proxy_ips')
    if $proxy_ips isnt ''
      $proxy_ips = $proxy_ips.replace(/\ /g,'').split(',')
      for $header in ['x-forwarded-for', 'client-ip', 'x-client-ip', 'x-cluster-client-ip']
        if ($spoof = @req.headers[$header])?
          #  Some proxies typically list the whole chain of IP
          #  addresses through which the client has reached us.
          #  e.g. client_ip, proxy_ip1, proxy_ip2, etc.
          if $spoof.indexOf(',') isnt -1
            $spoof = $spoof.split(',')[0]
          if not @valid_ip($spoof)
            $spoof = false
          else
            break
      @_ip_address = if ($spoof isnt false and $proxy_ips.indexOf(@req.connection.remoteAddress) isnt -1) then $spoof else @req.connection.remoteAddress

    else
      @_ip_address = @req.connection.remoteAddress

    if not @valid_ip(@_ip_address)
      @_ip_address = '0.0.0.0'

    return @_ip_address


  #
  # User Agent
  #
  # @return	[String] the client user agent
  #
  userAgent:  ->
    if @_user_agent isnt false
      return @_user_agent
    @_user_agent = if ( not @req.headers['user-agent']? ) then false else @req.headers['user-agent']
    return @_user_agent

  #
  # Validate IP Address
  #
  # @param  [String]  ip  the ip string
  # @param  [String]  which either ipv4 or ipv6
  # @return [Boolean] True if the ip is valid
  #
  validIp: ($ip, $which = '') ->
    $which = $which.toLowerCase()

    if $which isnt 'ipv6' and $which isnt 'ipv4'
      if $ip.indexOf(':') isnt -1
        $which = 'ipv6'

      else if $ip.indexOf('.') isnt -1
        $which = 'ipv4'

      else
        return false

    $func = '_valid_' + $which
    return @[$func]($ip)

  # Request Headers
  #
  # @param	[Boolean] xss_clean scrub the return value?
  # @return	[Object] the request header hash
  #
  requestHeaders : ($xss_clean = false) ->

    @_headers = @req.headers
    return @_headers


  # Get Request Header
  #
  # Returns the value of a single member of the headers class member
  #
  # @param  [String]  index  array key for @headers
  # @param	[Boolean] xss_clean scrub the return value?
  # @return [String]  FALSE on failure, string on success
  #
  getRequestHeader : ($index, $xss_clean = false) ->

    @requestHeaders() if Object.keys(@_headers).length is 0

    if not @_headers[$index]?
      return false

    if $xss_clean is true
      return @security.xssClean(@_headers[$index])

    return @_headers[$index]


  # Is ajax Request?
  #
  # Test to see if a request contains the HTTP_X_REQUESTED_WITH header
  #
  # @return [Boolean] True for AJAX requests
  #
  isAjaxRequest :  ->
    if @req.headers['x-requested-with'] is 'XMLHttpRequest' then true else false

  # Is cli Request?
  #
  # Test to see if a request was made from the command line
  #
  # @return [Boolean]  False
  #
  isCliRequest :  -> false

  #
  # Fetch from array
  #
  # This is a helper function to retrieve values from global arrays
  #
  # @private
  # @param  [Array] array hash to get values from
  # @param  [String]  index key into the SERVER hash
  # @param	[Boolean] xss_clean scrub the return value?
  # @return	[String] the value found at index
  #
  _fetch_from_array : ($array, $index = '', $xss_clean = false) ->
    if not $array[$index]?
      return null #false

    if $xss_clean is true
      return @security.xssClean($array[$index])

    return $array[$index]


  #
  # Validate IPv4 Address
  #
  # Updated version suggested by Geert De Deckere
  #
  # @private
  # @param  [String]  ip  the ip string to validate
  # @return	[Boolean] True if a valid ip
  #
  _valid_ipv4 : ($ip) ->
    $ip_segments = $ip.split('.')

    #  Always 4 segments needed
    return false unless Object.keys($ip_segments).length is 4

    #  IP can not start with 0
    return false if $ip_segments[0][0] is '0'

    #  Check each segment
    for $segment in $ip_segments
      #  IP segments must be digits and can not be
      #  longer than 3 digits or greater then 255
      if $segment is '' or /[^0-9]/.test($segment) or $segment > 255 or $segment.length > 3
        return false
    return true

  #
  # Validate IPv6 Address
  #
  # @private
  # @param  [String]  ip  the ip string to validate
  # @return	[Boolean] True if a valid ip
  #
  _valid_ipv6 : ($str) ->
    #  8 groups, separated by :
    #  0-ffff per group
    #  one set of consecutive 0 groups can be collapsed to ::

    $groups = 8
    $collapsed = false

    $chunks = $item for $item in $str.split(/(:{1,2})/) when $item?

    #  Rule out easy nonsense
    return false if $chunks[0] is ':' or $chunks[$chunks.length-1] is ':'

    #  PHP supports IPv4-mapped IPv6 addresses, so we'll expect those as well
    if $chunks[$chunks.length-1].indexOf('.') isnt -1
      $ipv4 = $chunks.pop()

      if not @_valid_ipv4($ipv4)
        return false

      $groups--

    while ($seg = $chunks.pop())?

      if $seg[0] is ':'
        if --$groups is 0
          return false#  too many groups

      if $seg.length > 2
        return false#  long separator

      if $seg is '::'
        if $collapsed
          return false#  multiple collapsed

        $collapsed = true

      else if /[^0-9a-f]/i.exec($seg)? or $seg.length > 4
        return false#  invalid segment
    return $collapsed or $groups is 1

  # Sanitize Globals
  #
  # This function does the following:
  #
  # Unsets $_GET data (if query strings are not enabled)
  #
  # Unsets all globals if register_globals is enabled
  #
  # Standardizes newline characters to \n
  #
  # @private
  # @return [Void]
  #
  _sanitize_globals :  ->

    #  Is GET data allowed? If not we'll set the GET to an empty array
    if @_allow_get_array is false
      delete @req.query[$key] for $key, $val of @req.query

    else
      for $key, $val of @req.query
        @req.query[@_clean_input_keys($key)] = @_clean_input_data($val)

    #  Clean POST Data
    for $key, $val of @req.body
      @req.body[@_clean_input_keys($key)] = @_clean_input_data($val)

    #  Clean $_COOKIE Data
    #  Also get rid of specially treated cookies that might be set by a server
    #  or silly application, that are of no use to a Exspressp application anyway
    #  but that when present will trip our 'Disallowed Key Characters' alarm
    #  http://www.ietf.org/rfc/rfc2109.txt
    delete @req.cookies['$Version']  if @req.cookies['$Version']?
    delete @req.cookies['$Path']     if @req.cookies['$Path']?
    delete @req.cookies['$Domain']   if @req.cookies['$Domain']?

    for $key, $val of @req.cookies
      @req.cookies[@_clean_input_keys($key)] = @_clean_input_data($val)

    #  CSRF Protection check on HTTP requests
    if @_enable_csrf is true and  not @isCliRequest()
      @security.csrfVerify()

    log_message('debug', "Global POST and COOKIE data sanitized")

  # Clean Input Data
  #
  # This is a helper function. It escapes data and
  # standardizes newline characters to \n
  #
  # @private
  # @param  [String]  str the string to clean
  # @return	[String] the clean value
  #
  _clean_input_data : ($str) ->
    if typeof $str is 'object'
      $new_array = {}
      for $key, $val of $str
        $new_array[@_clean_input_keys($key)] = @_clean_input_data($val)

      return $new_array

    #  Clean UTF-8 if supported
    if UTF8_ENABLED is true
      $str = @utf.cleanString($str)

    #  Remove control characters
    $str = remove_invisible_characters($str)

    #  Should we filter the input data?
    if @_enable_xss is true
      $str = @security.xssClean($str)

    #  Standardize newlines if needed
    if @_standardize_newlines is true
      if $str.indeoxOf('\r') isnt -1
        $str = $str.replace($re, os.EOL) for $re in [/\r\n/mg, /\r/mg, /\r\n\n/mg]

    return $str


  # Clean Keys
  #
  # This is a helper function. To prevent malicious users
  # from trying to exploit keys we make sure that keys are
  # only named with alpha-numeric text and a few other items.
  #
  # @private
  # @param  [String]  str the string to clean
  # @return	[String] the clean value
  #
  _clean_input_keys : ($str) ->
    if not /^[a-z0-9:_\/-]+$/i.test($str)
      return show_error('Disallowed Key Characters.')

    #  Clean UTF-8 if supported
    if UTF8_ENABLED is true
      $str = @utf.cleanString($str)

    return $str




# END Input class
module.exports = system.core.Input
# End of file Input.coffee
# Location: ./system/core/Input.coffee