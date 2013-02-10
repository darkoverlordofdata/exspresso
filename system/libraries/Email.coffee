#+--------------------------------------------------------------------+
#  Email.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
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
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Email Class
#
# Permits email to be sent using Mail, Sendmail, or SMTP.
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Libraries
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/email.html
#
class global.Exspresso_Email
  
  useragent: "Exspresso"
  mailpath: "/usr/sbin/sendmail"#  Sendmail path
  protocol: "mail"#  mail/sendmail/smtp
  smtp_host: ""#  SMTP Server.  Example: mail.earthlink.net
  smtp_user: ""#  SMTP Username
  smtp_pass: ""#  SMTP Password
  smtp_port: "25"#  SMTP Port
  smtp_timeout: 5 #  SMTP Timeout in seconds
  wordwrap: true#  TRUE/FALSE  Turns word-wrap on/off
  wrapchars: "76"#  Number of characters to wrap at.
  mailtype: "text"#  text/html  Defines email formatting
  charset: "utf-8"#  Default char set: iso-8859-1 or us-ascii
  multipart: "mixed"#  "mixed" (in the body) or "related" (separate)
  alt_message: ''#  Alternative message for HTML emails
  validate: false#  TRUE/FALSE.  Enables email validation
  priority: "3"#  Default priority (1 - 5)
  newline: "\n"#  Default newline. "\r\n" or "\n" (Use "\r\n" to comply with RFC 822)
  crlf: "\n"#  The RFC 2045 compliant CRLF for quoted-printable is "\r\n".  Apparently some servers,
  #  even on the receiving end think they need to muck with CRLFs, so using "\n", while
  #  distasteful, is the only thing that seems to work for all environments.
  send_multipart: true#  TRUE/FALSE - Yahoo does not like multipart alternative, so this is an override.  Set to FALSE for Yahoo.
  bcc_batch_mode: false#  TRUE/FALSE  Turns on/off Bcc batch feature
  bcc_batch_size: 200 #  If bcc_batch_mode = TRUE, sets max number of Bccs in each batch
  _safe_mode: false
  _subject: ""
  _body: ""
  _from: ''
  _name: ''
  _reply_to: ''
  _reply_name: ''
  _finalbody: ""
  _alt_boundary: ""
  _atc_boundary: ""
  _header_str: ""
  _smtp_connect: ""
  _encoding: "8bit"
  _IP: false
  _smtp_auth: false
  _replyto_flag: false
  _debug_msg: null
  _recipients: null
  _cc_array: null
  _bcc_array: null
  _headers: null
  _attach_name: null
  _attach_type: null
  _attach_disp: null
  _protocols: ['mail', 'sendmail', 'smtp']
  _base_charsets: ['us-ascii', 'iso-2022-']#  7-bit charsets (excluding language suffix)
  _bit_depths: ['7bit', '8bit']
  _priorities: ['1 (Highest)', '2 (High)', '3 (Normal)', '4 (Low)', '5 (Lowest)']
  
  #
  # Constructor - Sets Email Preferences
  #
  # The constructor can be passed an array of config values
  #
  constructor: ($config = {}, @Exspresso) ->


    @_debug_msg = {}
    @_recipients = {}
    @_cc_array = {}
    @_bcc_array = {}
    @_headers = {}
    @_attach_name = []
    @_attach_type = []
    @_attach_disp = []
    
    if count($config) > 0
      @initialize($config)
      
    else 
      @_smtp_auth = if (@smtp_user is '' and @smtp_pass is '') then false else true
      #@_safe_mode = if (ini_get("safe_mode") is false) then false else true
    
    log_message('debug', "Email Class Initialized")

    
  #
  # Initialize preferences
  #
  # @access	public
  # @param	array
  # @return	void
  #
  initialize: ($config = {}) ->

    for $key, $val of $config
      if @[$key]?
        $method = 'set_' + $key
        
        if method_exists(@, $method)
          @[$method]($val)
          
        else 
          @[$key] = $val

    @clear()
    
    @_smtp_auth = if (@smtp_user is '' and @smtp_pass is '') then false else true
    #@_safe_mode = if (ini_get("safe_mode") is false) then false else true
    
    return @

    
  #
  # Initialize the Email Data
  #
  # @access	public
  # @return	void
  #
  clear: ($clear_attachments = false) ->

    @_from = ""
    @_name = ""
    @_subject = ""
    @_body = ""
    @_finalbody = ""
    @_header_str = ""
    @_reply_to = ""
    @_reply_name = ""
    @_replyto_flag = false
    @_recipients = {}
    @_cc_array = {}
    @_bcc_array = {}
    @_headers = {}
    @_debug_msg = {}

    if $clear_attachments isnt false
      @_attach_name = []
      @_attach_type = []
      @_attach_disp = []

    return @

  #
  # Set FROM
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	void
  #
  from: ($from, $name = '') ->

    if preg_match('/\<(.*)\>/', $from, $match)
      $from = $match['1']

    if @validate
      @validate_email(@_str_to_array($from))

    if $name is '' then $name = $from
    @_from = $from
    @_name = $name

    return @

  #
  # Set Reply-to
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	void
  #
  reply_to: ($replyto, $name = '') ->

    if preg_match('/\<(.*)\>/', $replyto, $match)
      $replyto = $match['1']

    if @validate
      @validate_email(@_str_to_array($replyto))

    if $name is ''
      $name = $replyto

    @_reply_to = $replyto
    @_reply_name = $name
    @_replyto_flag = true

    return @

  #
  # Set Recipients
  #
  # @access	public
  # @param	string
  # @return	void
  #
  to: ($to) ->

    $to = @_str_to_array($to)
    $to = @clean_email($to)

    if @validate
      @validate_email($to)

    @_recipients = $to

    return @

  #
  # Set CC
  #
  # @access	public
  # @param	string
  # @return	void
  #
  cc: ($cc) ->

    $cc = @_str_to_array($cc)
    $cc = @clean_email($cc)

    if @validate
      @validate_email($cc)

    if @_get_protocol() is "smtp"
      @_cc_array = $cc

    return @

  #
  # Set BCC
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	void
  #
  bcc: ($bcc, $limit = '') ->

    if $limit isnt '' and is_numeric($limit)
      @bcc_batch_mode = true
      @bcc_batch_size = $limit

    $bcc = @_str_to_array($bcc)
    $bcc = @clean_email($bcc)

    if @validate
      @validate_email($bcc)

    @_bcc_array = $bcc
    return @


  #
  # Set Email Subject
  #
  # @access	public
  # @param	string
  # @return	void
  #
  subject: ($subject) ->

    @_subject = $subject
    return @

  #
  # Set Body
  #
  # @access	public
  # @param	string
  # @return	void
  #
  message: ($body) ->

    @_body = $body
    return @

  #
  # Assign file attachments
  #
  # @access	public
  # @param	string
  # @return	void
  #
  attach: ($filename, $disposition = 'attachment') ->

    @_attach_name.push $filename
    @_attach_type.push @_mime_types(next(explode('.', basename($filename))))
    @_attach_disp.push $disposition #  Can also be 'inline'  Not sure if it matters
    return @

  #
  # Convert a String to an Array
  #
  # @access	private
  # @param	string
  # @return	array
  #
  _str_to_array: ($email) ->

    if not is_array($email)
      if strpos($email, ',') isnt false
        $email = preg_split('/[\s,]/', $email,  - 1, PREG_SPLIT_NO_EMPTY)

      else
        $email = [trim($email)]

    return $email

  #
  # Set Multipart Value
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_alt_message: ($str = '') ->

    @alt_message = if ($str is '') then '' else $str
    return @

  #
  # Set Mailtype
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_mailtype: ($type = 'text') ->

    @mailtype = if ($type is 'html') then 'html' else 'text'
    return @

  #
  # Set Wordwrap
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_wordwrap: ($wordwrap = true) ->

    @wordwrap = if ($wordwrap is false) then false else true
    return @

  #
  # Set Protocol
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_protocol: ($protocol = 'mail') ->

    @protocol = if ( not in_array($protocol, @_protocols, true)) then 'mail' else strtolower($protocol)
    return @

  #
  # Set Priority
  #
  # @access	public
  # @param	integer
  # @return	void
  #
  set_priority: ($n = 3) ->

    if not is_numeric($n)
      @priority = 3
      return

    if $n < 1 or $n > 5
      @priority = 3
      return

    @priority = $n
    return @

  #
  # Set Newline Character
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_newline: ($newline = "\n") ->

    if $newline isnt "\n" and $newline isnt "\r\n" and $newline isnt "\r"
      @newline = "\n"
      return

    @newline = $newline

    return @

  #
  # Set CRLF
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_crlf: ($crlf = "\n") ->

    if $crlf isnt "\n" and $crlf isnt "\r\n" and $crlf isnt "\r"
      @crlf = "\n"
      return

    @crlf = $crlf

    return @

  #
  # Get Mail Protocol
  #
  # @access	private
  # @param	bool
  # @return	string
  #
  _get_protocol: ($return = true) ->

    @protocol = strtolower(@protocol)
    @protocol = if ( not in_array(@protocol, @_protocols, true)) then 'mail' else @protocol

    if $return is true
      return @protocol
    


  #
  # Get content type (text/html/attachment)
  #
  # @access	private
  # @return	string
  #
  _get_content_type: () ->

    if @mailtype is 'html' and count(@_attach_name) is 0
      return 'html'

    else if @mailtype is 'html' and count(@_attach_name) > 0
      return 'html-attach'

    else if @mailtype is 'text' and count(@_attach_name) > 0
      return 'plain-attach'

    else
      return 'plain'



  #
  # Mime message
  #
  # @access	private
  # @return	string
  #
  _get_mime_message: () ->

    return "This is a multi-part message in MIME format." + @newline + "Your email application may not support this format."

  #
  # Validate Email Address
  #
  # @access	public
  # @param	string
  # @return	bool
  #
  validate_email: ($email) ->

    if not is_array($email)
      @_set_error_message('email_must_be_array')
      return false

    for $val in $email
      if not @valid_email($val)
        @_set_error_message('email_invalid_address', $val)
        return false

    return true

  #
  # Email Validation
  #
  # @access	public
  # @param	string
  # @return	bool
  #
  valid_email: ($address) ->

    return if ( not preg_match("/^([a-z0-9\+_\-]+)(\.[a-z0-9\+_\-]+)*@([a-z0-9\-]+\.)+[a-z]{2,6}$/ix", $address)) then false else true

  #
  # Clean Extended Email Address: Joe Smith <joe@smith.com>
  #
  # @access	public
  # @param	string
  # @return	string
  #
  clean_email: ($email) ->

    if not is_array($email)
      if preg_match('/\<(.*)\>/', $email, $match)
        return $match['1']

      else
        return $email

    $clean_email = []

    for $addy in $email
      if preg_match('/\<(.*)\>/', $addy, $match)
        $clean_email.push $match['1']

      else
        $clean_email.push $addy

    return $clean_email

  #
  # Build alternative plain text message
  #
  # This public function provides the raw message for use
  # in plain-text headers of HTML-formatted emails.
  # If the user hasn't specified his own alternative message
  # it creates one by stripping the HTML
  #
  # @access	private
  # @return	string
  #
  _get_alt_message: () ->

    if @alt_message isnt ""
      return @word_wrap(@alt_message, '76')


    if preg_match('/\<body.*?\>(.*)\<\/body\>/si', @_body, $match)
      $body = $match['1']

    else
      $body = @_body

    $body = trim(strip_tags($body))
    $body = preg_replace('#<!--(.*)--\>#', "", $body)
    $body = str_replace("\t", "", $body)

    for $i in [20..3]
      $n = ""

      for $x in [1..$i]
        $n+="\n"

    $body = str_replace($n, "\n\n", $body)

    return @word_wrap($body, '76')

  #
  # Word Wrap
  #
  # @access	public
  # @param	string
  # @param	integer
  # @return	string
  #
  word_wrap: ($str, $charlim = '') ->
    #  Se the character limit
    if $charlim is ''
      $charlim = if (@wrapchars is "") then "76" else @wrapchars

    #  Reduce multiple spaces
    $str = preg_replace("| +|", " ", $str)

    #  Standardize newlines
    if strpos($str, "\r") isnt false
      $str = str_replace(["\r\n", "\r"], "\n", $str)

    #  If the current word is surrounded by {unwrap} tags we'll
    #  strip the entire chunk and replace it with a marker.
    $unwrap = {}
    if preg_match_all("|(\{unwrap\}.+?\{/unwrap\})|s", $str, $matches)
      for $i in [0...count($matches['0'])]
        $unwrap.push $matches['1'][$i]
        $str = str_replace($matches['1'][$i], "{{unwrapped" + $i + "}}", $str)


    #  Use PHP's native public function to do the initial wordwrap.
    #  We set the cut flag to FALSE so that any individual words that are
    #  too long get left alone.  In the next step we'll deal with them.
    $str = wordwrap($str, $charlim, "\n", false)

    #  Split the string into individual lines of text and cycle through them
    $output = ""
    for $line in explode("\n", $str)
      #  Is the line within the allowed character count?
      #  If so we'll join it to the output and continue
      if strlen($line)<=$charlim
        $output+=$line + @newline
        continue

      $temp = ''
      while (strlen($line)) > $charlim
        #  If the over-length word is a URL we won't wrap it
        if preg_match("!\[url.+\]|://|wwww.!", $line)
          break

        #  Trim the word down
        $temp+=substr($line, 0, $charlim - 1)
        $line = substr($line, $charlim - 1)

      #  If $temp contains data it means we had to split up an over-length
      #  word into smaller chunks so we'll add it back to our current line
      if $temp isnt ''
        $output+=$temp + @newline + $line

      else
        $output+=$line

      $output+=@newline

    #  Put our markers back
    if count($unwrap) > 0
      for $key, $val of $unwrap
        $output = str_replace("{{unwrapped" + $key + "}}", $val, $output)

    return $output


  #
  # Send Email
  #
  # @access	public
  # @return	bool
  #
  send: ($next) ->

    $msg =
      from: @_get_from()
      to: @_get_to()
      cc: @_get_cc()
      subject: @_subject
      text: @_get_alt_message()
      attachment: [ data: @_body, alternative:true].concat(@_get_attachments())

    @server.send $msg, $next




#  END Exspresso_Email class

module.exports = Exspresso_Email

#  End of file Email.coffee
#  Location: ./system/libraries/Email.coffee