#+--------------------------------------------------------------------+
#  Input.coffee
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
# This file was ported from php to coffee-script using php2coffee
#
#

<% if not defined('BASEPATH') then die ('No direct script access allowed')
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
# Input Class
#
# Pre-processes global input data for security
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Input
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/input.html
#
class CI_Input
  
  #
  # IP address of the current user
  #
  # @var string
  #
  ip_address: false
  #
  # user agent (web browser) being used by the current user
  #
  # @var string
  #
  user_agent: false
  #
  # If FALSE, then $_GET will be set to an empty array
  #
  # @var bool
  #
  _allow_get_array: true
  #
  # If TRUE, then newlines are standardized
  #
  # @var bool
  #
  _standardize_newlines: true
  #
  # Determines whether the XSS filter is always active when GET, POST or COOKIE data is encountered
  # Set automatically based on config setting
  #
  # @var bool
  #
  _enable_xss: false
  #
  # Enables a CSRF cookie token to be set.
  # Set automatically based on config setting
  #
  # @var bool
  #
  _enable_csrf: false
  #
  # List of all HTTP request headers
  #
  # @var array
  #
  $headers = {}
  
  #
  # Constructor
  #
  # Sets whether to globally enable the XSS processing
  # and whether to allow the $_GET array
  #
  # @return	void
  #
  constructor :  ->
    log_message('debug', "Input Class Initialized")
    
    @_allow_get_array = (config_item('allow_get_array') is true)
    @_enable_xss = (config_item('global_xss_filtering') is true)
    @_enable_csrf = (config_item('csrf_protection') is true)
    
    exports.$SEC
    @security = $SEC
    
    #  Do we need the UTF-8 class?
    if UTF8_ENABLED is true then 
      exports.$UNI
      @uni = $UNI
      
    
    #  Sanitize global arrays
    @_sanitize_globals()
    
  
  #  --------------------------------------------------------------------
  
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
  _fetch_from_array : ( and $array, $index = '', $xss_clean = false) ->
    if not $array[$index]?  then 
      return false
      
    
    if $xss_clean is true then 
      return @security.xss_clean($array[$index])
      
    
    return $array[$index]
    
  
  #  --------------------------------------------------------------------
  
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
    if $index is null and  not empty($_GET) then 
      $get = {}
      
      #  loop through the full _GET array
      for $key in array_keys($_GET)
        $get[$key] = @_fetch_from_array($_GET, $key, $xss_clean)
        
      return $get
      
    
    return @_fetch_from_array($_GET, $index, $xss_clean)
    
  
  #  --------------------------------------------------------------------
  
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
    if $index is null and  not empty($_POST) then 
      $post = {}
      
      #  Loop through the full _POST array and return it
      for $key in array_keys($_POST)
        $post[$key] = @_fetch_from_array($_POST, $key, $xss_clean)
        
      return $post
      
    
    return @_fetch_from_array($_POST, $index, $xss_clean)
    
  
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch an item from either the GET array or the POST
  #
  # @access	public
  # @param	string	The index key
  # @param	bool	XSS cleaning
  # @return	string
  #
  get_post : ($index = '', $xss_clean = false) ->
    if not $_POST[$index]?  then 
      return @get($index, $xss_clean)
      
    else 
      return @post($index, $xss_clean)
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch an item from the COOKIE array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  cookie : ($index = '', $xss_clean = false) ->
    return @_fetch_from_array($_COOKIE, $index, $xss_clean)
    
  
  #  ------------------------------------------------------------------------
  
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
    if is_array($name) then 
      #  always leave 'name' in last place, as the loop will break otherwise, due to $$item
      for $item in ['value', 'expire', 'domain', 'path', 'prefix', 'secure', 'name']
        if $name[$item]?  then 
          $item = $name[$item]
          
        
      
    
    if $prefix is '' and config_item('cookie_prefix') isnt '' then 
      $prefix = config_item('cookie_prefix')
      
    if $domain is '' and config_item('cookie_domain') isnt '' then 
      $domain = config_item('cookie_domain')
      
    if $path is '/' and config_item('cookie_path') isnt '/' then 
      $path = config_item('cookie_path')
      
    if $secure is false and config_item('cookie_secure') isnt false then 
      $secure = config_item('cookie_secure')
      
    
    if not is_numeric($expire) then 
      $expire = time() - 86500
      
    else 
      $expire = if ($expire > 0) then time() + $expire else 0
      
    
    setcookie($prefix + $name, $value, $expire, $path, $domain, $secure)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch an item from the SERVER array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  server : ($index = '', $xss_clean = false) ->
    return @_fetch_from_array($_SERVER, $index, $xss_clean)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch the IP Address
  #
  # @return	string
  #
  ip_address :  ->
    if @ip_address isnt false then 
      return @ip_address
      
    
    $proxy_ips = config_item('proxy_ips')
    if not empty($proxy_ips) then 
      $proxy_ips = explode(',', str_replace(' ', '', $proxy_ips))
      for $header in ['HTTP_X_FORWARDED_FOR', 'HTTP_CLIENT_IP', 'HTTP_X_CLIENT_IP', 'HTTP_X_CLUSTER_CLIENT_IP']
        if ($spoof = @server($header)) isnt false then 
          #  Some proxies typically list the whole chain of IP
          #  addresses through which the client has reached us.
          #  e.g. client_ip, proxy_ip1, proxy_ip2, etc.
          if strpos($spoof, ',') isnt false then 
            $spoof = explode(',', $spoof, 2)
            $spoof = $spoof[0]
            
          
          if not @valid_ip($spoof) then 
            $spoof = false
            
          else 
            break
            
          
        
      
      @ip_address = if ($spoof isnt false and in_array($_SERVER['REMOTE_ADDR'], $proxy_ips, true)) then $spoof else $_SERVER['REMOTE_ADDR']
      
    else 
      @ip_address = $_SERVER['REMOTE_ADDR']
      
    
    if not @valid_ip(@ip_address) then 
      @ip_address = '0.0.0.0'
      
    
    return @ip_address
    
  
  #  --------------------------------------------------------------------
  
  #
  # Validate IP Address
  #
  # @access	public
  # @param	string
  # @param	string	ipv4 or ipv6
  # @return	bool
  #
  valid_ip : ($ip, $which = '') ->
    $which = strtolower($which)
    
    #  First check if filter_var is available
    if is_callable('filter_var') then 
      switch $which
        when 'ipv4'
          $flag = FILTER_FLAG_IPV4
          
        when 'ipv6'
          $flag = FILTER_FLAG_IPV6
          
        else
          $flag = ''
          
          
      
      return filter_var($ip, FILTER_VALIDATE_IP, $flag)
      
    
    if $which isnt 'ipv6' and $which isnt 'ipv4' then 
      if strpos($ip, ':') isnt false then 
        $which = 'ipv6'
        
      else if strpos($ip, '.') isnt false then 
        $which = 'ipv4'
        
      else 
        return false
        
      
    
    $func = '_valid_' + $which
    return @$func($ip)
    
  
  #  --------------------------------------------------------------------
  
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
    if count($ip_segments) isnt 4 then 
      return false
      
    #  IP can not start with 0
    if $ip_segments[0][0] is '0' then 
      return false
      
    
    #  Check each segment
    for $segment in $ip_segments
      #  IP segments must be digits and can not be
      #  longer than 3 digits or greater then 255
      if $segment is '' or preg_match("/[^0-9]/", $segment) or $segment > 255 or strlen($segment) > 3 then 
        return false
        
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
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
    if current($chunks) is ':' or end($chunks) is ':' then 
      return false
      
    
    #  PHP supports IPv4-mapped IPv6 addresses, so we'll expect those as well
    if strpos(end($chunks), '.') isnt false then 
      $ipv4 = array_pop($chunks)
      
      if not @_valid_ipv4($ipv4) then 
        return false
        
      
      $groups--
      
    
    while $seg = array_pop($chunks))#  --------------------------------------------------------------------#
    # User Agent
    #
    # @access	public
    # @return	string
    ##  --------------------------------------------------------------------#
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
    ##  --------------------------------------------------------------------#
    # Clean Input Data
    #
    # This is a helper function. It escapes data and
    # standardizes newline characters to \n
    #
    # @access	private
    # @param	string
    # @return	string
    ##  --------------------------------------------------------------------#
    # Clean Keys
    #
    # This is a helper function. To prevent malicious users
    # from trying to exploit keys we make sure that keys are
    # only named with alpha-numeric text and a few other items.
    #
    # @access	private
    # @param	string
    # @return	string
    ##  --------------------------------------------------------------------#
    # Request Headers
    #
    # In Apache, you can simply call apache_request_headers(), however for
    # people running other webservers the function is undefined.
    #
    # @param	bool XSS cleaning
    #
    # @return array
    ##  --------------------------------------------------------------------#
    # Get Request Header
    #
    # Returns the value of a single member of the headers class member
    #
    # @param 	string		array key for $this->headers
    # @param	boolean		XSS Clean or not
    # @return 	mixed		FALSE on failure, string on success
    ##  --------------------------------------------------------------------#
    # Is ajax Request?
    #
    # Test to see if a request contains the HTTP_X_REQUESTED_WITH header
    #
    # @return 	boolean
    ##  --------------------------------------------------------------------#
    # Is cli Request?
    #
    # Test to see if a request was made from the command line
    #
    # @return 	bool
    ##  End of file Input.php #  Location: ./system/core/Input.php if $seg[0] is ':' then 
      if --$groups is 0 then 
        return false#  too many groups
        
      
      if strlen($seg) > 2 then 
        return false#  long separator
        
      
      if $seg is '::' then 
        if $collapsed then 
          return false#  multiple collapsed
          
        
        $collapsed = true
        
      else if preg_match("/[^0-9a-f]/i", $seg) or strlen($seg) > 4 then 
      return false#  invalid segment
      }return $collapsed or $groups is 1}user_agent :  ->
      if @user_agent isnt false then 
        return @user_agent
        
      
      @user_agent = if ( not $_SERVER['HTTP_USER_AGENT']? ) then false else $_SERVER['HTTP_USER_AGENT']
      
      return @user_agent
      _sanitize_globals :  ->
      #  It would be "wrong" to unset any of these GLOBALS.
      $protected = ['_SERVER', '_GET', '_POST', '_FILES', '_REQUEST', 
        '_SESSION', '_ENV', 'GLOBALS', 'HTTP_RAW_POST_DATA', 
        'system_folder', 'application_folder', 'BM', 'EXT', 
        'CFG', 'URI', 'RTR', 'OUT', 'IN']
      
      #  Unset globals for securiy.
      #  This is effectively the same as register_globals = off
      for $global in [$_GET, $_POST, $_COOKIE]
        if not is_array($global) then 
          if not in_array($global, $protected) then 
            exports.$global
            $global = null
            
          
        else 
          for $key, $val of $global
            if not in_array($key, $protected) then 
              exports.$key
              $key = null
              
            
          
        
      
      #  Is $_GET data allowed? If not we'll set the $_GET to an empty array
      if @_allow_get_array is false then 
        $_GET = {}
        
      else 
        if is_array($_GET) and count($_GET) > 0 then 
          for $key, $val of $_GET
            $_GET[@_clean_input_keys($key)] = @_clean_input_data($val)
            
          
        
      
      #  Clean $_POST Data
      if is_array($_POST) and count($_POST) > 0 then 
        for $key, $val of $_POST
          $_POST[@_clean_input_keys($key)] = @_clean_input_data($val)
          
        
      
      #  Clean $_COOKIE Data
      if is_array($_COOKIE) and count($_COOKIE) > 0 then 
        #  Also get rid of specially treated cookies that might be set by a server
        #  or silly application, that are of no use to a CI application anyway
        #  but that when present will trip our 'Disallowed Key Characters' alarm
        #  http://www.ietf.org/rfc/rfc2109.txt
        #  note that the key names below are single quoted strings, and are not PHP variables
        delete $_COOKIE['$Version']
        delete $_COOKIE['$Path']
        delete $_COOKIE['$Domain']
        
        for $key, $val of $_COOKIE
          $_COOKIE[@_clean_input_keys($key)] = @_clean_input_data($val)
          
        
      
      #  Sanitize PHP_SELF
      $_SERVER['PHP_SELF'] = strip_tags($_SERVER['PHP_SELF'])
      
      
      #  CSRF Protection check on HTTP requests
      if @_enable_csrf is true and  not @is_cli_request() then 
        @security.csrf_verify()
        
      
      log_message('debug', "Global POST and COOKIE data sanitized")
      _clean_input_data : ($str) ->
      if is_array($str) then 
        $new_array = {}
        for $key, $val of $str
          $new_array[@_clean_input_keys($key)] = @_clean_input_data($val)
          
        return $new_array
        
      
      #/* We strip slashes if magic quotes is on to keep things consistent
      #
      #NOTE: In PHP 5.4 get_magic_quotes_gpc() will always return 0 and
      #it will probably not exist in future versions at all.
      #
      if not is_php('5.4') and get_magic_quotes_gpc() then 
        $str = stripslashes($str)
        
      
      #  Clean UTF-8 if supported
      if UTF8_ENABLED is true then 
        $str = @uni.clean_string($str)
        
      
      #  Remove control characters
      $str = remove_invisible_characters($str)
      
      #  Should we filter the input data?
      if @_enable_xss is true then 
        $str = @security.xss_clean($str)
        
      
      #  Standardize newlines if needed
      if @_standardize_newlines is true then 
        if strpos($str, "\r") isnt false then 
          $str = str_replace(["\r\n", "\r", "\r\n\n"], PHP_EOL, $str)
          
        
      
      return $str
      _clean_input_keys : ($str) ->
      if not preg_match("/^[a-z0-9:_\/-]+$/i", $str) then 
        die ('Disallowed Key Characters.')
        
      
      #  Clean UTF-8 if supported
      if UTF8_ENABLED is true then 
        $str = @uni.clean_string($str)
        
      
      return $str
      request_headers : ($xss_clean = false) ->
      #  Look at Apache go!
      if function_exists('apache_request_headers') then 
        $headers = apache_request_headers()
        
      else 
        $headers['Content-Type'] = if ($_SERVER['CONTENT_TYPE']? ) then $_SERVER['CONTENT_TYPE'] else getenv('CONTENT_TYPE')
        
        for $key, $val of $_SERVER
          if strncmp($key, 'HTTP_', 5) is 0 then 
            $headers[substr($key, 5)] = @_fetch_from_array($_SERVER, $key, $xss_clean)
            
          
        
      
      #  take SOME_HEADER and turn it into Some-Header
      for $key, $val of $headers
        $key = str_replace('_', ' ', strtolower($key))
        $key = str_replace(' ', '-', ucwords($key))
        
        @headers[$key] = $val
        
      
      return @headers
      get_request_header : ($index, $xss_clean = false) ->
      if empty(@headers) then 
        @request_headers()
        
      
      if not @headers[$index]?  then 
        return false
        
      
      if $xss_clean is true then 
        return @security.xss_clean(@headers[$index])
        
      
      return @headers[$index]
      is_ajax_request :  ->
      return (@server('HTTP_X_REQUESTED_WITH') is 'XMLHttpRequest')
      is_cli_request :  ->
      return (php_sapi_name() is 'cli' or defined('STDIN'))
      }
module.exports = CI_Input