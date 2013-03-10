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

  _cookies              : null    # The request cookies
  _query                : null    # The request get array
  _body                 : null    # The request post body
  _server               : null    # The request server properties
  _headers              : null    # The list of HTTP request headers
  _ip_address           : false   # The IP address of the current user
  _user_agent           : false   # The user agent (web browser) being used by the current user
  _server               : null    # A fabricated table to mimic php's $_SERVER
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
      _cookies: {writeable: false, value: $req.cookies}
      _query:   {writeable: false, value: $req.query}
      _body:    {writeable: false, value: $req.body}
      _server:  {writeable: false, value: $req.server}
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
    if $index is null and  not empty(@_query)
      $get = {}

      #  loop through the full _GET array
      for $key in array_keys(@_query)
        $get[$key] = @_fetch_from_array(@_query, $key, $xss_clean)
      return $get

    return @_fetch_from_array(@_query, $index, $xss_clean)


  #
  # Fetch an item from the POST array
  #
  # @param  [String]  index key into the POST hash
  # @param	[Boolean] xss_clean scrub the return value?
  # @return	[String] the value found at index
  #
  post : ($index = null, $xss_clean = false) ->

    #  Check if a field has been provided
    if $index is null and  not empty(@_body)
      $post = {}

      #  Loop through the full _POST array and return it
      for $key in array_keys(@_body)
        $post[$key] = @_fetch_from_array(@_body, $key, $xss_clean)
      return $post

    return @_fetch_from_array(@_body, $index, $xss_clean)

  #
  # Fetch an item from either the GET array or the POST
  #
  # @param  [String]  index key into both GET/POST hash'
  # @param	[Boolean] xss_clean scrub the return value?
  # @return	[String] the value found at index
  #
  getPost : ($index = '', $xss_clean = false) ->

    if not @_body[$index]?
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
    return @_fetch_from_array(@_cookies, $index, $xss_clean)

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

    if not is_numeric($expire)
      $expire = time() - 86500

    else
      $expire = if ($expire > 0) then time() + $expire else 0

    @res.cookie $prefix+$name, $value,
      expires : $expire
      domain  : $domain
      path    : $path
      secure  : $secure

  #
  # Fetch an item from the SERVER array
  #
  # @param  [String]  index key into the SERVER hash
  # @param	[Boolean] xss_clean scrub the return value?
  # @return	[String] the value found at index
  #
  server : ($index = '', $xss_clean = false) ->
    return @_fetch_from_array(@_server, $index, $xss_clean)

  #
  # Fetch the IP Address
  #
  # @return	[String]  the client IP
  #
  ipAddress :  ->
    if @_ip_address isnt false
      return @_ip_address

    $proxy_ips = config_item('proxy_ips')
    if not empty($proxy_ips)
      $proxy_ips = explode(',', str_replace(' ', '', $proxy_ips))
      for $header in ['HTTP_X_FORWARDED_FOR', 'HTTP_CLIENT_IP', 'HTTP_X_CLIENT_IP', 'HTTP_X_CLUSTER_CLIENT_IP']
        if ($spoof = @server($header)) isnt false
          #  Some proxies typically list the whole chain of IP
          #  addresses through which the client has reached us.
          #  e.g. client_ip, proxy_ip1, proxy_ip2, etc.
          if strpos($spoof, ',') isnt false
            $spoof = explode(',', $spoof, 2)
            $spoof = $spoof[0]
          if not @valid_ip($spoof)
            $spoof = false

          else
            break
      @_ip_address = if ($spoof isnt false and in_array($_SERVER['REMOTE_ADDR'], $proxy_ips, true)) then $spoof else $_SERVER['REMOTE_ADDR']

    else
      @_ip_address = $_SERVER['REMOTE_ADDR']

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
    @_user_agent = if ( not $_SERVER['HTTP_USER_AGENT']? ) then false else $_SERVER['HTTP_USER_AGENT']
    return @_user_agent

  #
  # Validate IP Address
  #
  # @param  [String]  ip  the ip string
  # @param  [String]  which either ipv4 or ipv6
  # @return [Boolean] True if the ip is valid
  #
  validIp: ($ip, $which = '') ->
    $which = strtolower($which)

    if $which isnt 'ipv6' and $which isnt 'ipv4'
      if strpos($ip, ':') isnt false
        $which = 'ipv6'

      else if strpos($ip, '.') isnt false
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
    if empty(@_headers)
      @requestHeaders()

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
    if @server('HTTP_X_REQUESTED_WITH') is 'XMLHttpRequest' then true else false

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
    $ip_segments = explode('.', $ip)

    #  Always 4 segments needed
    if count($ip_segments) isnt 4
      return false

    #  IP can not start with 0
    if $ip_segments[0][0] is '0'
      return false

    #  Check each segment
    for $segment in $ip_segments
      #  IP segments must be digits and can not be
      #  longer than 3 digits or greater then 255
      #if $segment is '' or preg_match("/[^0-9]/", $segment)? or $segment > 255 or strlen($segment) > 3
      if $segment is '' or /[^0-9]/.test($segment) or $segment > 255 or strlen($segment) > 3
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

    $chunks = array_filter(preg_split('/(:{1,2})/', $str, null, PREG_SPLIT_DELIM_CAPTURE))

    #  Rule out easy nonsense
    if current($chunks) is ':' or end($chunks) is ':'
      return false

    #  PHP supports IPv4-mapped IPv6 addresses, so we'll expect those as well
    if strpos(end($chunks), '.') isnt false
      $ipv4 = array_pop($chunks)

      if not @_valid_ipv4($ipv4)
        return false

      $groups--

    while $seg = array_pop($chunks)

      if $seg[0] is ':'
        if --$groups is 0
          return false#  too many groups

      if strlen($seg) > 2
        return false#  long separator

      if $seg is '::'
        if $collapsed
          return false#  multiple collapsed

        $collapsed = true

      else if /[^0-9a-f]/i.exec($seg)? or strlen($seg) > 4
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

    #  Is $_GET data allowed? If not we'll set the $_GET to an empty array
    if @_allow_get_array is false
      delete @_query[$key] for $key, $val of @_query

    else
      for $key, $val of @_query
        @_query[@_clean_input_keys($key)] = @_clean_input_data($val)

    #  Clean $_POST Data
    for $key, $val of @_body
      @_body[@_clean_input_keys($key)] = @_clean_input_data($val)

    #  Clean $_COOKIE Data
    #  Also get rid of specially treated cookies that might be set by a server
    #  or silly application, that are of no use to a Exspressp application anyway
    #  but that when present will trip our 'Disallowed Key Characters' alarm
    #  http://www.ietf.org/rfc/rfc2109.txt
    delete @_cookies['$Version']  if @_cookies['$Version']?
    delete @_cookies['$Path']     if @_cookies['$Path']?
    delete @_cookies['$Domain']   if @_cookies['$Domain']?

    for $key, $val of @_cookies
      @_cookies[@_clean_input_keys($key)] = @_clean_input_data($val)

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
    if is_array($str)
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
      if strpos($str, "\r") isnt false
        $str = str_replace(["\r\n", "\r", "\r\n\n"], os.EOL, $str)

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
    #if not preg_match("/^[a-z0-9:_\/-]+$/i", $str)?
    if not /^[a-z0-9:_\/-]+$/i.test($str)
      die ('Disallowed Key Characters.')

    #  Clean UTF-8 if supported
    if UTF8_ENABLED is true
      $str = @utf.cleanString($str)

    return $str




# END Input class
module.exports = system.core.Input
# End of file Input.coffee
# Location: ./system/core/Input.coffee