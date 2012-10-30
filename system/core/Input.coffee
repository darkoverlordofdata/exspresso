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

    $SRV.input @
    log_message('debug', "Input Class Initialized")


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

      # --------------------------------------------------------------------
      @ip_address = () -> $req.ip

      # --------------------------------------------------------------------
      @user_agent =  ->

      $next()



      # END CI_Input class

# End of file Input.coffee
# Location: ./system/core/Input.coffee