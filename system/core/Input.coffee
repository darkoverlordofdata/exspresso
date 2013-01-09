#+--------------------------------------------------------------------+
#| Output.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	Input
#
#
#

#  ------------------------------------------------------------------------

#
# Exspresso Input Class
#
module.exports = class global.CI_Input

  constructor: ->

    log_message('debug', "Input Class Initialized")
    $SRV.input @


  #  --------------------------------------------------------------------

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


  # --------------------------------------------------------------------
  # Method Stubs
  #
  #   These methods will be overriden by the middleware
  # --------------------------------------------------------------------

  #  --------------------------------------------------------------------

  #
  # Fetch an item from the GET array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  get : ($index = null, $xss_clean = false) -> false

  #  --------------------------------------------------------------------

  #
  # Fetch an item from the POST array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  post : ($index = null, $xss_clean = false) -> false

  #  --------------------------------------------------------------------

  #
  # Fetch an item from either the GET array or the POST
  #
  # @access	public
  # @param	string	The index key
  # @param	bool	XSS cleaning
  # @return	string
  #
  get_post : ($index = '', $xss_clean = false) -> false

  #  --------------------------------------------------------------------

  #
  # Fetch an item from the COOKIE array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  cookie : ($index = '', $xss_clean = false) -> false

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


  #  --------------------------------------------------------------------

  #
  # Fetch an item from the SERVER array
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	string
  #
  server : ($index = '', $xss_clean = false) -> false


  #  --------------------------------------------------------------------

  #
  # Fetch the IP Address
  #
  # @access	public
  # @return	string
  #
  ip_address :  -> false


  #  --------------------------------------------------------------------

  #
  # User Agent
  #
  # @access	public
  # @return	string
  #
  user_agent :  -> false



  # --------------------------------------------------------------------

  #
  # Override input instance methods
  #
  #   @returns function middlware callback
  #
  middleware: ()->

    log_message 'debug',"Input middleware initialized"

    ($req, $res, $next) =>

      $server_array =
        argv:                   $req.query
        argc:                   count($req.query)
        SERVER_ADDR:            $req.ip
        SERVER_NAME:            $req.host
        SERVER_SOFTWARE:        "express/3.0.0rc4 (" + require('os').type() + ") Node.js " + process.version
        SERVER_PROTOCOL:        strtoupper($req.protocol)+"/"+$req.httpVersion
        REQUEST_METHOD:         $req.method
        REQUEST_TIME:           $req._startTime
        QUERY_STRING:           if $req.url.split('?')[1]? then $req.url.split('?')[1] else ''
        DOCUMENT_ROOT:          process.cwd()
        HTTP_ACCEPT:            $req.headers['accept']
        HTTP_ACCEPT_CHARSET:    $req.headers['accept-charset']
        HTTP_ACCEPT_ENCODING:   $req.headers['accept-encoding']
        HTTP_ACCEPT_LANGUAGE:   $req.headers['accept-language']
        HTTP_CONNECTION:        $req.headers['connection']
        HTTP_HOST:              $req.headers['host']
        HTTP_REFERER:           $req.headers['referer']
        HTTP_USER_AGENT:        $req.headers['user-agent']
        HTTPS:                  $req.secure
        REQUEST_URI:            $req.url
        PATH_INFO:              $req.path
        ORIG_PATH_INFO:         $req.path

      # --------------------------------------------------------------------
      @get = ($index = null, $xss_clean = false) ->

        if $index is null
          $req.query
        else
          if $req.query[$index]?
            $req.query[$index]
          else
            null

      # --------------------------------------------------------------------
      @post = ($index = null, $xss_clean = false) ->

        if $index is null
          $req.body
        else
          if $req.body[$index]?
            $req.body[$index]
          else
            null

      # --------------------------------------------------------------------
      @get_post = ($index, $xss_clean = false) ->

        if not $req.body[$index]?
          if $req.query[$index]?
            $req.query[$index]
          else
            null
        else
          $req.body[$index]

      # --------------------------------------------------------------------
      @cookie = ($index = null, $xss_clean = false) ->

        if $index is null
          $req.cookies
        else
          if $req.cookies[$index]?
            $req.cookies[$index]
          else
            ''

      # --------------------------------------------------------------------
      @set_cookie = ($name = '', $value = '', $expire = '', $domain = '', $path = '/', $prefix = '', $secure = false) ->
        $res.cookie $name, $value,
          expire: $expire
          domain: $domain
          path:   $path
          prefix: $prefix
          secure: $secure

      # --------------------------------------------------------------------
      @server = ($index = '', $xss_clean = false) ->

        if $index is ''
          $server_array
        else
          if $server_array[$index]?
            $server_array[$index]
          else
            ''

      # --------------------------------------------------------------------
      @ip_address = () -> $req.ip

      # --------------------------------------------------------------------
      @user_agent =  -> $req.useragent["Browser"]

      $next()

# END CI_Input class

# End of file Input.coffee
# Location: ./system/core/Input.coffee