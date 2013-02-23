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

  req                     : null  # http request object
  res                     : null  # http response object
  headers                 : null  # List of all HTTP request headers
  ip_address              : false # IP address of the current user
  user_agent              : false # user agent (web browser) being used by the current user
  _server                 : null  # fabricated table to mimic PHP
  _allow_get_array        : false # If FALSE, then $_GET will be set to an empty array
  _standardize_newlines   : false # If TRUE, then newlines are standardized
  _enable_xss             : false # Determines whether the XSS filter is always active
                                  # when GET, POST or COOKIE data is encountered
  _enable_csrf            : false # Enables a CSRF cookie token to be set.



  constructor: ($controller) ->

    log_message('debug', "Input Class Initialized")

    @_allow_get_array = if config_item('allow_get_array') then true else false
    @_enable_xss      = if config_item('global_xss_filtering') then true else false
    @_enable_csrf     = if config_item('csrf_protection') then true else false
    #@_sanitize_globals()

    defineProperties @,
      req           : {enumerable: true, writeable: false, value: $controller.req}
      res           : {enumerable: true, writeable: false, value: $controller.res}


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
  _fetch_from_array : ($array, $index = '', $xss_clean = false) ->
    if not $array[$index]?
      return false

    if $xss_clean is true
      return @security.xss_clean($array[$index])

    return $array[$index]
  #
  # Validate IP Address
  #
  # Updated version suggested by Geert De Deckere
  #
  # @access	public
  # @param	string
  # @return	string
  #
  valid_ip : ($ip) ->
    $ip_segments = $ip.split('.')

    #  Always 4 segments needed
    if $ip_segments.length isnt 4
      return false

    #  IP can not start with 0
    if $ip_segments[0][0] is '0'
      return false

    #  Check each segment
    for $segment in $ip_segments
      #  IP segments must be digits and can not be
      #  longer than 3 digits or greater then 255
      if $segment is '' or typeof $segment isnt 'number' or $segment > 255 or $segment.length > 3
        return false

    return true

  #
  # Fetch an item from the GET array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  get : ($index = null, $xss_clean = false) ->

    #  Check if a field has been provided
    if $index is null and  not empty(@$_GET)
      $get = {}

      #  loop through the full _GET array
      for $key in array_keys(@$_GET)
        $get[$key] = @_fetch_from_array(@$_GET, $key, $xss_clean)
      return $get

    return @_fetch_from_array(@$_GET, $index, $xss_clean)


  #
  # Fetch an item from the POST array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  post : ($index = null, $xss_clean = false) ->

    #  Check if a field has been provided
    if $index is null and  not empty(@$_POST)
      $post = {}

      #  Loop through the full _POST array and return it
      for $key in array_keys(@$_POST)
        $post[$key] = @_fetch_from_array(@$_POST, $key, $xss_clean)
      return $post

    return @_fetch_from_array(@$_POST, $index, $xss_clean)

  #
  # Fetch an item from either the GET array or the POST
  #
  # @access	public
  # @param	string	The index key
  # @param	bool	XSS cleaning
  # @return	string
  #
  get_post : ($index = '', $xss_clean = false) ->

    if not @$_POST[$index]?
      @get($index, $xss_clean)
    else
      @post($index, $xss_clean)

  #
  # Fetch an item from the COOKIE array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  cookie : ($index = '', $xss_clean = false) ->
    return @_fetch_from_array(@$_COOKIE, $index, $xss_clean)

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
  set_cookie : ($name = '', $value = '', $expire = '', $domain = '', $path = '/', $prefix = '', $secure = false) ->

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
  server : ($index = '', $xss_clean = false) ->
    return @_fetch_from_array(@$_SERVER, $index, $xss_clean)

  #
  # Fetch the IP Address
  #
  # @access	public
  # @return	string
  #
  ip_address :  ->
    return @req.ip
    if @ip_address isnt false
      return @ip_address

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
      @ip_address = if ($spoof isnt false and in_array($_SERVER['REMOTE_ADDR'], $proxy_ips, true)) then $spoof else $_SERVER['REMOTE_ADDR']

    else
      @ip_address = $_SERVER['REMOTE_ADDR']


    if not @valid_ip(@ip_address)
      @ip_address = '0.0.0.0'


    return @ip_address


  #
  # User Agent
  #
  # @access	public
  # @return	string
  #
  user_agent :  -> @req.useragent["Browser"]

# END Exspresso_Input class
module.exports = Exspresso_Input
# End of file Input.coffee
# Location: ./system/core/Input.coffee