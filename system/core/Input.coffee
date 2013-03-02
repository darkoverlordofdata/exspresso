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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Input Class
#
class global.Exspresso_Input

  os = require('os')

  _headers                : null  # List of all HTTP request headers
  _ip_address             : false # IP address of the current user
  _user_agent             : false # user agent (web browser) being used by the current user
  _server                 : null  # fabricated table to mimic PHP
  _allow_get_array        : false # If FALSE, then $_GET will be set to an empty array
  _standardize_newlines   : false # If TRUE, then newlines are standardized
  _enable_xss             : false # Determines whether the XSS filter is always active
                                  # when GET, POST or COOKIE data is encountered
  _enable_csrf            : false # Enables a CSRF cookie token to be set.

  #
  # Constructor
  #
  # @access	public
  # @param object   Exspresso_Utf8
  # @param object   Exspresso_Security
  # @param object   http request cookies object
  # @param object   http request query object
  # @param object   http request body object
  # @param object   http request server object
  # @return	void
  #
  constructor: (@$UNI, @$SEC, @$_COOKIE, @$_GET, @$_POST, @$_SERVER) ->

    log_message('debug', "Input Class Initialized")

    @_allow_get_array = if config_item('allow_get_array') then true else false
    @_enable_xss      = if config_item('global_xss_filtering') then true else false
    @_enable_csrf     = if config_item('csrf_protection') then true else false
    @_sanitize_globals()


  #
  # Fetch an item from the GET array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  get : ($index = null, $xssClean = false) ->

    #  Check if a field has been provided
    if $index is null and  not empty(@$_GET)
      $get = {}

      #  loop through the full _GET array
      for $key in array_keys(@$_GET)
        $get[$key] = @_fetch_from_array(@$_GET, $key, $xssClean)
      return $get

    return @_fetch_from_array(@$_GET, $index, $xssClean)


  #
  # Fetch an item from the POST array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  post : ($index = null, $xssClean = false) ->

    #  Check if a field has been provided
    if $index is null and  not empty(@$_POST)
      $post = {}

      #  Loop through the full _POST array and return it
      for $key in array_keys(@$_POST)
        $post[$key] = @_fetch_from_array(@$_POST, $key, $xssClean)
      return $post

    return @_fetch_from_array(@$_POST, $index, $xssClean)

  #
  # Fetch an item from either the GET array or the POST
  #
  # @access	public
  # @param	string	The index key
  # @param	bool	XSS cleaning
  # @return	string
  #
  getPost : ($index = '', $xssClean = false) ->

    if not @$_POST[$index]?
      @get($index, $xssClean)
    else
      @post($index, $xssClean)

  #
  # Fetch an item from the COOKIE array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  cookie : ($index = '', $xssClean = false) ->
    return @_fetch_from_array(@$_COOKIE, $index, $xssClean)

  #
  # Set cookie
  #
  # Accepts six parameter, or you can submit an associative
  # array in the first parameter containing all the values.
  #
  # @access	public
  # @param	mixed
  # @param	string	the value of the cookie
  # @param	string	the number of seconds until expiration
  # @param	string	the cookie domain.  Usually:  .yourdomain.com
  # @param	string	the cookie path
  # @param	string	the cookie prefix
  # @param	bool	true makes the cookie secure
  # @return	void
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
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  server : ($index = '', $xssClean = false) ->
    return @_fetch_from_array(@$_SERVER, $index, $xssClean)

  #
  # Fetch the IP Address
  #
  # @access	public
  # @return	string
  #
  ipAddress :  ->
    #return @req.ip
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
  # @access	public
  # @return	string
  #
  userAgent:  ->
    if @_user_agent isnt false
      return @_user_agent
    @_user_agent = if ( not $_SERVER['HTTP_USER_AGENT']? ) then false else $_SERVER['HTTP_USER_AGENT']
    return @_user_agent

  #
  # Validate IP Address
  #
  # @access	public
  # @param	string
  # @param	string	ipv4 or ipv6
  # @return	bool
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
  # @param	bool XSS cleaning
  #
  # @return array
  requestHeaders : ($xssClean = false) ->

    @_headers = @req.headers
    return @_headers


  # Get Request Header
  #
  # Returns the value of a single member of the headers class member
  #
  # @param 	string		array key for $this->headers
  # @param	boolean		XSS Clean or not
  # @return 	mixed		FALSE on failure, string on success
  getRequestHeader : ($index, $xssClean = false) ->
    if empty(@_headers)
      @requestHeaders()

    if not @_headers[$index]?
      return false

    if $xssClean is true
      return @$SEC.xssClean(@_headers[$index])

    return @_headers[$index]


  # Is ajax Request?
  #
  # Test to see if a request contains the HTTP_X_REQUESTED_WITH header
  #
  # @return 	boolean
  isAjaxRequest :  ->
    if @server('HTTP_X_REQUESTED_WITH') is 'XMLHttpRequest' then true else false

  # Is cli Request?
  #
  # Test to see if a request was made from the command line
  #
  # @return 	bool
  isCliRequest :  -> false




  #
  # Fetch from array
  #
  # This is a helper function to retrieve values from global arrays
  #
  # @access	private
  # @param	array
  # @param	string
  # @param	bool
  # @return	string
  #
  _fetch_from_array : ($array, $index = '', $xssClean = false) ->
    if not $array[$index]?
      return null #false

    if $xssClean is true
      return @$SEC.xssClean($array[$index])

    return $array[$index]


  #
  # Validate IPv4 Address
  #
  # Updated version suggested by Geert De Deckere
  #
  # @access	protected
  # @param	string
  # @return	bool
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
      if $segment is '' or preg_match("/[^0-9]/", $segment)? or $segment > 255 or strlen($segment) > 3
        return false

    return true

  #
  # Validate IPv6 Address
  #
  # @access	protected
  # @param	string
  # @return	bool
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

      else if preg_match("/[^0-9a-f]/i", $seg)? or strlen($seg) > 4
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
  # @access	private
  # @return	void
  _sanitize_globals :  ->

    #  Is $_GET data allowed? If not we'll set the $_GET to an empty array
    if @_allow_get_array is false
      delete @$_GET[$key] for $key, $val of @$_GET

    else
      for $key, $val of @$_GET
        @$_GET[@_clean_input_keys($key)] = @_clean_input_data($val)

    #  Clean $_POST Data
    for $key, $val of @$_POST
      @$_POST[@_clean_input_keys($key)] = @_clean_input_data($val)

    #  Clean $_COOKIE Data
    #  Also get rid of specially treated cookies that might be set by a server
    #  or silly application, that are of no use to a Exspressp application anyway
    #  but that when present will trip our 'Disallowed Key Characters' alarm
    #  http://www.ietf.org/rfc/rfc2109.txt
    delete @$_COOKIE['$Version']  if @$_COOKIE['$Version']?
    delete @$_COOKIE['$Path']     if @$_COOKIE['$Path']?
    delete @$_COOKIE['$Domain']   if @$_COOKIE['$Domain']?

    for $key, $val of @$_COOKIE
      @$_COOKIE[@_clean_input_keys($key)] = @_clean_input_data($val)

    #  CSRF Protection check on HTTP requests
    if @_enable_csrf is true and  not @isCliRequest()
      @$SEC.csrfVerify()

    log_message('debug', "Global POST and COOKIE data sanitized")

  # Clean Input Data
  #
  # This is a helper function. It escapes data and
  # standardizes newline characters to \n
  #
  # @access	private
  # @param	string
  # @return	string
  _clean_input_data : ($str) ->
    if is_array($str)
      $new_array = {}
      for $key, $val of $str
        $new_array[@_clean_input_keys($key)] = @_clean_input_data($val)

      return $new_array

    #  Clean UTF-8 if supported
    if UTF8_ENABLED is true
      $str = @$UNI.cleanString($str)

    #  Remove control characters
    $str = remove_invisible_characters($str)

    #  Should we filter the input data?
    if @_enable_xss is true
      $str = @$SEC.xssClean($str)

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
  # @access	private
  # @param	string
  # @return	string
  _clean_input_keys : ($str) ->
    if not preg_match("/^[a-z0-9:_\/-]+$/i", $str)?
      die ('Disallowed Key Characters.')

    #  Clean UTF-8 if supported
    if UTF8_ENABLED is true
      $str = @$UNI.cleanString($str)

    return $str




# END Exspresso_Input class
module.exports = Exspresso_Input
# End of file Input.coffee
# Location: ./system/core/Input.coffee