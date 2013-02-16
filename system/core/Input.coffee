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
module.exports = class global.Exspresso_Input

  __defineProperties  = Object.defineProperties
  __freeze            = Object.freeze

  constructor: ($controller) ->

    log_message('debug', "Input Class Initialized")

    os = require('os')
    $req = $controller.req
    $res = $controller.res
    $server_array =
      argv                  : $req.query
      argc                  : count($req.query)
      SERVER_ADDR           : $req.ip
      SERVER_NAME           : $req.host
      SERVER_SOFTWARE       : Exspresso.server.get_version()+" (" + os.type() + '/' + os.release() + ") Node.js " + process.version
      SERVER_PROTOCOL       : strtoupper($req.protocol)+"/"+$req.httpVersion
      REQUEST_METHOD        : $req.method
      REQUEST_TIME          : $req._startTime
      QUERY_STRING          : if $req.url.split('?')[1]? then $req.url.split('?')[1] else ''
      DOCUMENT_ROOT         : process.cwd()
      HTTP_ACCEPT           : $req.headers['accept']
      HTTP_ACCEPT_CHARSET   : $req.headers['accept-charset']
      HTTP_ACCEPT_ENCODING  : $req.headers['accept-encoding']
      HTTP_ACCEPT_LANGUAGE  : $req.headers['accept-language']
      HTTP_CONNECTION       : $req.headers['connection']
      HTTP_HOST             : $req.headers['host']
      HTTP_REFERER          : $req.headers['referer']
      HTTP_USER_AGENT       : $req.headers['user-agent']
      HTTPS                 : $req.secure
      REMOTE_ADDR           : ($req.headers['x-forwarded-for'] || '').split(',')[0] || $req.connection.remoteAddress
      REQUEST_URI           : $req.url
      PATH_INFO             : $req.path
      ORIG_PATH_INFO        : $req.path

    __defineProperties @,
      _server_array : {enumerable: false, writeable: false, value: __freeze($server_array)}
      req           : {enumerable: true, writeable: false, value: $req}
      res           : {enumerable: true, writeable: false, value: $res}


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

    if $index is null
      @req.query
    else
      if @req.query[$index]?
        @req.query[$index]
      else
        null

  #
  # Fetch an item from the POST array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  post : ($index = null, $xss_clean = false) ->

    if $index is null
      @req.body
    else
      if @req.body[$index]?
        @req.body[$index]
      else
        null

  #
  # Fetch an item from either the GET array or the POST
  #
  # @access	public
  # @param	string	The index key
  # @param	bool	XSS cleaning
  # @return	string
  #
  get_post : ($index = '', $xss_clean = false) ->

    if not @req.body[$index]?
      if @req.query[$index]?
        @req.query[$index]
      else
        null
    else
      @req.body[$index]

  #
  # Fetch an item from the COOKIE array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  cookie : ($index = '', $xss_clean = false) ->
    if $index is null
      @req.cookies
    else
      if @req.cookies[$index]?
        @req.cookies[$index]
      else
        ''

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
    if $index is ''
      @_server_array
    else
      if @_server_array[$index]?
        @_server_array[$index]
      else
        ''
  #
  # Fetch the IP Address
  #
  # @access	public
  # @return	string
  #
  ip_address :  -> @req.ip

  #
  # User Agent
  #
  # @access	public
  # @return	string
  #
  user_agent :  -> @req.useragent["Browser"]

# END Exspresso_Input class

# End of file Input.coffee
# Location: ./system/core/Input.coffee