#+--------------------------------------------------------------------+
#  Email.coffee
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


{__construct, _build_headers, _build_message, _get_alt_message, _get_content_type, _get_encoding, _get_hostname, _get_ip, _get_message_id, _get_mime_message, _get_protocol, _get_smtp_data, _mime_types, _prep_q_encoding, _prep_quoted_printable, _remove_nl_callback, _send_command, _send_data, _send_with_mail, _send_with_sendmail, _send_with_smtp, _set_boundaries, _set_date, _set_error_message, _set_header, _smtp_authenticate, _spool_email, _str_to_array, _unwrap_specials, _write_headers, abs, addcslashes, attach, base64_encode, basename, batch_bcc_send, bcc, cc, chunk_split, clean_email, clear, count, date, dechex, defined, end, explode, fclose, fgets, file_exists, filesize, floor, fopen, fputs, fread, from, fsockopen, fwrite, get_instance, htmlspecialchars, implode, in_array, ini_get, initialize, is_array, is_numeric, is_resource, lang, line, load, mail, message, method_exists, next, ord, pclose, popen, preg_match, preg_match_all, preg_replace, preg_replace_callback, preg_split, print_debugger, reply_to, reset, rtrim, send, set_alt_message, set_crlf, set_mailtype, set_newline, set_priority, set_protocol, set_wordwrap, settype, sprintf, str_replace, strip_tags, stripslashes, strlen, strncmp, strpos, strstr, strtolower, strtoupper, subject, substr, to, trim, uniqid, valid_email, validate_email, version_compare, word_wrap}  = require(FCPATH + 'lib')


if not defined('BASEPATH') then die 'No direct script access allowed'
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
# CodeIgniter Email Class
#
# Permits email to be sent using Mail, Sendmail, or SMTP.
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Libraries
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/email.html
#
class CI_Email
  
  useragent: "CodeIgniter"
  mailpath: "/usr/sbin/sendmail"#  Sendmail path
  protocol: "mail"#  mail/sendmail/smtp
  smtp_host: ""#  SMTP Server.  Example: mail.earthlink.net
  smtp_user: ""#  SMTP Username
  smtp_pass: ""#  SMTP Password
  smtp_port: "25"#  SMTP Port
  smtp_timeout: 5#  SMTP Timeout in seconds
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
  bcc_batch_size: 200#  If bcc_batch_mode = TRUE, sets max number of Bccs in each batch
  _safe_mode: false
  _subject: ""
  _body: ""
  _finalbody: ""
  _alt_boundary: ""
  _atc_boundary: ""
  _header_str: ""
  _smtp_connect: ""
  _encoding: "8bit"
  _IP: false
  _smtp_auth: false
  _replyto_flag: false
  _debug_msg: {}
  _recipients: {}
  _cc_array: {}
  _bcc_array: {}
  _headers: {}
  _attach_name: {}
  _attach_type: {}
  _attach_disp: {}
  _protocols: ['mail', 'sendmail', 'smtp']
  _base_charsets: ['us-ascii', 'iso-2022-']#  7-bit charsets (excluding language suffix)
  _bit_depths: ['7bit', '8bit']
  _priorities: ['1 (Highest)', '2 (High)', '3 (Normal)', '4 (Low)', '5 (Lowest)']
  
  
  #
  # Constructor - Sets Email Preferences
  #
  # The constructor can be passed an array of config values
  #
  __construct($config = {})
  {
  if count($config) > 0
    @initialize($config)
    
  else 
    @_smtp_auth = if (@smtp_user is '' and @smtp_pass is '') then false else true
    @_safe_mode = if (ini_get("safe_mode") is false) then false else true
    
  
  log_message('debug', "Email Class Initialized")
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Initialize preferences
  #
  # @access	public
  # @param	array
  # @return	void
  #
  initialize($config = {})
  {
  for $key, $val of $config
    if @$key? 
      $method = 'set_' + $key
      
      if method_exists(@, $method)
        @$method($val)
        
      else 
        @$key = $val
        
      
    
  @clear()
  
  @_smtp_auth = if (@smtp_user is '' and @smtp_pass is '') then false else true
  @_safe_mode = if (ini_get("safe_mode") is false) then false else true
  
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Initialize the Email Data
  #
  # @access	public
  # @return	void
  #
  clear($clear_attachments = false)
  {
  @_subject = ""
  @_body = ""
  @_finalbody = ""
  @_header_str = ""
  @_replyto_flag = false
  @_recipients = {}
  @_cc_array = {}
  @_bcc_array = {}
  @_headers = {}
  @_debug_msg = {}
  
  @_set_header('User-Agent', @useragent)
  @_set_header('Date', @_set_date())
  
  if $clear_attachments isnt false
    @_attach_name = {}
    @_attach_type = {}
    @_attach_disp = {}
    
  
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set FROM
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	void
  #
  from($from, $name = '')
  {
  if preg_match('/\<(.*)\>/', $from, $match)
    $from = $match['1']
    
  
  if @validate
    @validate_email(@_str_to_array($from))
    
  
  #  prepare the display name
  if $name isnt ''
    #  only use Q encoding if there are characters that would require it
    if not preg_match('/[\200-\377]/', $name)
      #  add slashes for non-printing characters, slashes, and double quotes, and surround it in double quotes
      $name = '"' + addcslashes($name, "\0..\37\177'\"\\") + '"'
      
    else 
      $name = @_prep_q_encoding($name, true)
      
    
  
  @_set_header('From', $name + ' <' + $from + '>')
  @_set_header('Return-Path', '<' + $from + '>')
  
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Reply-to
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	void
  #
  reply_to($replyto, $name = '')
  {
  if preg_match('/\<(.*)\>/', $replyto, $match)
    $replyto = $match['1']
    
  
  if @validate
    @validate_email(@_str_to_array($replyto))
    
  
  if $name is ''
    $name = $replyto
    
  
  if strncmp($name, '"', 1) isnt 0
    $name = '"' + $name + '"'
    
  
  @_set_header('Reply-To', $name + ' <' + $replyto + '>')
  @_replyto_flag = true
  
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Recipients
  #
  # @access	public
  # @param	string
  # @return	void
  #
  to($to)
  {
  $to = @_str_to_array($to)
  $to = @clean_email($to)
  
  if @validate
    @validate_email($to)
    
  
  if @_get_protocol() isnt 'mail'
    @_set_header('To', implode(", ", $to))
    
  
  switch @_get_protocol()
    when 'smtp'
      @_recipients = $to
      
    when 'sendmail','mail'
      @_recipients = implode(", ", $to)
      
      
  
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set CC
  #
  # @access	public
  # @param	string
  # @return	void
  #
  cc($cc)
  {
  $cc = @_str_to_array($cc)
  $cc = @clean_email($cc)
  
  if @validate
    @validate_email($cc)
    
  
  @_set_header('Cc', implode(", ", $cc))
  
  if @_get_protocol() is "smtp"
    @_cc_array = $cc
    
  
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set BCC
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	void
  #
  bcc($bcc, $limit = '')
  {
  if $limit isnt '' and is_numeric($limit)
    @bcc_batch_mode = true
    @bcc_batch_size = $limit
    
  
  $bcc = @_str_to_array($bcc)
  $bcc = @clean_email($bcc)
  
  if @validate
    @validate_email($bcc)
    
  
  if (@_get_protocol() is "smtp") or (@bcc_batch_mode and count($bcc) > @bcc_batch_size)
    @_bcc_array = $bcc
    
  else 
    @_set_header('Bcc', implode(", ", $bcc))
    
  
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Email Subject
  #
  # @access	public
  # @param	string
  # @return	void
  #
  subject($subject)
  {
  $subject = @_prep_q_encoding($subject)
  @_set_header('Subject', $subject)
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Body
  #
  # @access	public
  # @param	string
  # @return	void
  #
  message($body)
  {
  @_body = stripslashes(rtrim(str_replace("\r", "", $body)))
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Assign file attachments
  #
  # @access	public
  # @param	string
  # @return	void
  #
  attach($filename, $disposition = 'attachment')
  {
  @_attach_name.push $filename
  @_attach_type.push @_mime_types(next(explode('.', basename($filename))))
  @_attach_disp.push $disposition#  Can also be 'inline'  Not sure if it matters
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Add a Header Item
  #
  # @access	private
  # @param	string
  # @param	string
  # @return	void
  #
  _set_header($header, $value)
  {
  @_headers[$header] = $value
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Convert a String to an Array
  #
  # @access	private
  # @param	string
  # @return	array
  #
  _str_to_array($email)
  {
  if not is_array($email)
    if strpos($email, ',') isnt false
      $email = preg_split('/[\s,]/', $email,  - 1, PREG_SPLIT_NO_EMPTY)
      
    else 
      $email = trim($email)
      settype($email, "array")
      
    
  return $email
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Multipart Value
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_alt_message($str = '')
  {
  @alt_message = if ($str is '') then '' else $str
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Mailtype
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_mailtype($type = 'text')
  {
  @mailtype = if ($type is 'html') then 'html' else 'text'
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Wordwrap
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_wordwrap($wordwrap = true)
  {
  @wordwrap = if ($wordwrap is false) then false else true
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Protocol
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_protocol($protocol = 'mail')
  {
  @protocol = if ( not in_array($protocol, @_protocols, true)) then 'mail' else strtolower($protocol)
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Priority
  #
  # @access	public
  # @param	integer
  # @return	void
  #
  set_priority($n = 3)
  {
  if not is_numeric($n)
    @priority = 3
    return 
    
  
  if $n < 1 or $n > 5
    @priority = 3
    return 
    
  
  @priority = $n
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Newline Character
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_newline($newline = "\n")
  {
  if $newline isnt "\n" and $newline isnt "\r\n" and $newline isnt "\r"
    @newline = "\n"
    return 
    
  
  @newline = $newline
  
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set CRLF
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_crlf($crlf = "\n")
  {
  if $crlf isnt "\n" and $crlf isnt "\r\n" and $crlf isnt "\r"
    @crlf = "\n"
    return 
    
  
  @crlf = $crlf
  
  return @
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set Message Boundary
  #
  # @access	private
  # @return	void
  #
  _set_boundaries()
  {
  @_alt_boundary = "B_ALT_" + uniqid('')#  multipart/alternative
  @_atc_boundary = "B_ATC_" + uniqid('')#  attachment boundary
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Get the Message ID
  #
  # @access	private
  # @return	string
  #
  _get_message_id()
  {
  $from = @_headers['Return-Path']
  $from = str_replace(">", "", $from)
  $from = str_replace("<", "", $from)
  
  return "<" + uniqid('') + strstr($from, '@') + ">"
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Get Mail Protocol
  #
  # @access	private
  # @param	bool
  # @return	string
  #
  _get_protocol($return = true)
  {
  @protocol = strtolower(@protocol)
  @protocol = if ( not in_array(@protocol, @_protocols, true)) then 'mail' else @protocol
  
  if $return is true
    return @protocol
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Get Mail Encoding
  #
  # @access	private
  # @param	bool
  # @return	string
  #
  _get_encoding($return = true)
  {
  @_encoding = if ( not in_array(@_encoding, @_bit_depths)) then '8bit' else @_encoding
  
  for $charset in @_base_charsets
    if strncmp($charset, @charset, strlen($charset)) is 0
      @_encoding = '7bit'
      
    
  
  if $return is true
    return @_encoding
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Get content type (text/html/attachment)
  #
  # @access	private
  # @return	string
  #
  _get_content_type()
  {
  if @mailtype is 'html' and count(@_attach_name) is 0
    return 'html'
    
  else if @mailtype is 'html' and count(@_attach_name) > 0
    return 'html-attach'
    
  else if @mailtype is 'text' and count(@_attach_name) > 0
    return 'plain-attach'
    
  else 
    return 'plain'
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Set RFC 822 Date
  #
  # @access	private
  # @return	string
  #
  _set_date()
  {
  $timezone = date("Z")
  $operator = if (strncmp($timezone, '-', 1) is 0) then '-' else '+'
  $timezone = abs($timezone)
  $timezone = floor($timezone / 3600) * 100 + ($timezone3600) / 60
  
  return sprintf("%s %s%04d", date("D, j M Y H:i:s"), $operator, $timezone)
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Mime message
  #
  # @access	private
  # @return	string
  #
  _get_mime_message()
  {
  return "This is a multi-part message in MIME format." + @newline + "Your email application may not support this format."
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Validate Email Address
  #
  # @access	public
  # @param	string
  # @return	bool
  #
  validate_email($email)
  {
  if not is_array($email)
    @_set_error_message('email_must_be_array')
    return false
    
  
  for $val in $email
    if not @valid_email($val)
      @_set_error_message('email_invalid_address', $val)
      return false
      
    
  
  return true
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Email Validation
  #
  # @access	public
  # @param	string
  # @return	bool
  #
  valid_email($address)
  {
  return if ( not preg_match("/^([a-z0-9\+_\-]+)(\.[a-z0-9\+_\-]+)*@([a-z0-9\-]+\.)+[a-z]{2,6}$/ix", $address)) then false else true
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Clean Extended Email Address: Joe Smith <joe@smith.com>
  #
  # @access	public
  # @param	string
  # @return	string
  #
  clean_email($email)
  {
  if not is_array($email)
    if preg_match('/\<(.*)\>/', $email, $match)
      return $match['1']
      
    else 
      return $email
      
    
  
  $clean_email = {}
  
  for $addy in $email
    if preg_match('/\<(.*)\>/', $addy, $match)
      $clean_email.push $match['1']
      
    else 
      $clean_email.push $addy
      
    
  
  return $clean_email
  }
  
  #  --------------------------------------------------------------------
  
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
  _get_alt_message()
  {
  if @alt_message isnt ""
    return @word_wrap(@alt_message, '76')
    
  
  if preg_match('/\<body.*?\>(.*)\<\/body\>/si', @_body, $match)
    $body = $match['1']
    
  else 
    $body = @_body
    
  
  $body = trim(strip_tags($body))
  $body = preg_replace('#<!--(.*)--\>#', "", $body)
  $body = str_replace("\t", "", $body)
  
  for ($i = 20$i>=3$i--)
  {
  $n = ""
  
  for ($x = 1$x<=$i$x++)
  {
  $n+="\n"
  }
  
  $body = str_replace($n, "\n\n", $body)
  }
  
  return @word_wrap($body, '76')
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Word Wrap
  #
  # @access	public
  # @param	string
  # @param	integer
  # @return	string
  #
  word_wrap($str, $charlim = '')
  {
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
    for ($i = 0$i < count($matches['0'])$i++)
    {
    $unwrap.push $matches['1'][$i]
    $str = str_replace($matches['1'][$i], "{{unwrapped" + $i + "}}", $str)
    }
    
  
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
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Build final headers
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _build_headers()
  {
  @_set_header('X-Sender', @clean_email(@_headers['From']))
  @_set_header('X-Mailer', @useragent)
  @_set_header('X-Priority', @_priorities[@priority - 1])
  @_set_header('Message-ID', @_get_message_id())
  @_set_header('Mime-Version', '1.0')
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Write Headers as a string
  #
  # @access	private
  # @return	void
  #
  _write_headers()
  {
  if @protocol is 'mail'
    @_subject = @_headers['Subject']
    delete @_headers['Subject']
    
  
  reset(@_headers)
  @_header_str = ""
  
  for $key, $val of @_headers
    $val = trim($val)
    
    if $val isnt ""
      @_header_str+=$key + ": " + $val + @newline
      
    
  
  if @_get_protocol() is 'mail'
    @_header_str = rtrim(@_header_str)
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Build Final Body and attachments
  #
  # @access	private
  # @return	void
  #
  _build_message()
  {
  if @wordwrap is true and @mailtype isnt 'html'
    @_body = @word_wrap(@_body)
    
  
  @_set_boundaries()
  @_write_headers()
  
  $hdr = if (@_get_protocol() is 'mail') then @newline else ''
  $body = ''
  
  switch @_get_content_type()
    when 'plain'
      
      $hdr+="Content-Type: text/plain; charset=" + @charset + @newline
      $hdr+="Content-Transfer-Encoding: " + @_get_encoding()
      
      if @_get_protocol() is 'mail'
        @_header_str+=$hdr
        @_finalbody = @_body
        
      else 
        @_finalbody = $hdr + @newline + @newline + @_body
        
      
      return 
      
      
    when 'html'
      
      if @send_multipart is false
        $hdr+="Content-Type: text/html; charset=" + @charset + @newline
        $hdr+="Content-Transfer-Encoding: quoted-printable"
        
      else 
        $hdr+="Content-Type: multipart/alternative; boundary=\"" + @_alt_boundary + "\"" + @newline + @newline
        
        $body+=@_get_mime_message() + @newline + @newline
        $body+="--" + @_alt_boundary + @newline
        
        $body+="Content-Type: text/plain; charset=" + @charset + @newline
        $body+="Content-Transfer-Encoding: " + @_get_encoding() + @newline + @newline
        $body+=@_get_alt_message() + @newline + @newline + "--" + @_alt_boundary + @newline
        
        $body+="Content-Type: text/html; charset=" + @charset + @newline
        $body+="Content-Transfer-Encoding: quoted-printable" + @newline + @newline
        
      
      @_finalbody = $body + @_prep_quoted_printable(@_body) + @newline + @newline
      
      
      if @_get_protocol() is 'mail'
        @_header_str+=$hdr
        
      else 
        @_finalbody = $hdr + @_finalbody
        
      
      
      if @send_multipart isnt false
        @_finalbody+="--" + @_alt_boundary + "--"
        
      
      return 
      
      
    when 'plain-attach'
      
      $hdr+="Content-Type: multipart/" + @multipart + "; boundary=\"" + @_atc_boundary + "\"" + @newline + @newline
      
      if @_get_protocol() is 'mail'
        @_header_str+=$hdr
        
      
      $body+=@_get_mime_message() + @newline + @newline
      $body+="--" + @_atc_boundary + @newline
      
      $body+="Content-Type: text/plain; charset=" + @charset + @newline
      $body+="Content-Transfer-Encoding: " + @_get_encoding() + @newline + @newline
      
      $body+=@_body + @newline + @newline
      
      
    when 'html-attach'
      
      $hdr+="Content-Type: multipart/" + @multipart + "; boundary=\"" + @_atc_boundary + "\"" + @newline + @newline
      
      if @_get_protocol() is 'mail'
        @_header_str+=$hdr
        
      
      $body+=@_get_mime_message() + @newline + @newline
      $body+="--" + @_atc_boundary + @newline
      
      $body+="Content-Type: multipart/alternative; boundary=\"" + @_alt_boundary + "\"" + @newline + @newline
      $body+="--" + @_alt_boundary + @newline
      
      $body+="Content-Type: text/plain; charset=" + @charset + @newline
      $body+="Content-Transfer-Encoding: " + @_get_encoding() + @newline + @newline
      $body+=@_get_alt_message() + @newline + @newline + "--" + @_alt_boundary + @newline
      
      $body+="Content-Type: text/html; charset=" + @charset + @newline
      $body+="Content-Transfer-Encoding: quoted-printable" + @newline + @newline
      
      $body+=@_prep_quoted_printable(@_body) + @newline + @newline
      $body+="--" + @_alt_boundary + "--" + @newline + @newline
      
      
      
  
  $attachment = {}
  
  $z = 0
  
  for ($i = 0$i < count(@_attach_name)$i++)
  {
  $filename = @_attach_name[$i]
  $basename = basename($filename)
  $ctype = @_attach_type[$i]
  
  if not file_exists($filename)
    @_set_error_message('email_attachment_missing', $filename)
    return false
    
  
  $h = "--" + @_atc_boundary + @newline
  $h+="Content-type: " + $ctype + "; "
  $h+="name=\"" + $basename + "\"" + @newline
  $h+="Content-Disposition: " + @_attach_disp[$i] + ";" + @newline
  $h+="Content-Transfer-Encoding: base64" + @newline
  
  $attachment[$z++] = $h
  $file = filesize($filename) + 1
  
  if not $fp = fopen($filename, FOPEN_READ)) then @_set_error_message('email_attachment_unreadable', $filename)
  return false
  }
  
  $attachment[$z++] = chunk_split(base64_encode(fread($fp, $file)))
  fclose($fp)
  }
  
  $body+=implode(@newline, $attachment) + @newline + "--" + @_atc_boundary + "--"
  
  
  if @_get_protocol() is 'mail'
    @_finalbody = $body
    
  else 
    @_finalbody = $hdr + $body
    
  
  return 
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Prep Quoted Printable
  #
  # Prepares string for Quoted-Printable Content-Transfer-Encoding
  # Refer to RFC 2045 http://www.ietf.org/rfc/rfc2045.txt
  #
  # @access	private
  # @param	string
  # @param	integer
  # @return	string
  #
  _prep_quoted_printable($str, $charlim = '')
  {
  #  Set the character limit
  #  Don't allow over 76, as that will make servers and MUAs barf
  #  all over quoted-printable data
  if $charlim is '' or $charlim > '76'
    $charlim = '76'
    
  
  #  Reduce multiple spaces
  $str = preg_replace("| +|", " ", $str)
  
  #  kill nulls
  $str = preg_replace('/\x00+/', '', $str)
  
  #  Standardize newlines
  if strpos($str, "\r") isnt false
    $str = str_replace(["\r\n", "\r"], "\n", $str)
    
  
  #  We are intentionally wrapping so mail servers will encode characters
  #  properly and MUAs will behave, so {unwrap} must go!
  $str = str_replace(['{unwrap}', '{/unwrap}'], '', $str)
  
  #  Break into an array of lines
  $lines = explode("\n", $str)
  
  $escape = '='
  $output = ''
  
  for $line in $lines
    $length = strlen($line)
    $temp = ''
    
    #  Loop through each character in the line to add soft-wrap
    #  characters at the end of a line " =\r\n" and add the newly
    #  processed line(s) to the output (see comment on $crlf class property)
    for ($i = 0$i < $length$i++)
    {
    #  Grab the next character
    $char = substr($line, $i, 1)
    $ascii = ord($char)
    
    #  Convert spaces and tabs but only if it's the end of the line
    if $i is ($length - 1)
      $char = if ($ascii is '32' or $ascii is '9') then $escape + sprintf('%02s', dechex($ascii)) else $char
      
    
    #  encode = signs
    if $ascii is '61'
      $char = $escape + strtoupper(sprintf('%02s', dechex($ascii)))#  =3D
      
    
    #  If we're at the character limit, add the line to the output,
    #  reset our temp variable, and keep on chuggin'
    if (strlen($temp) + strlen($char))>=$charlim
      $output+=$temp + $escape + @crlf
      $temp = ''
      
    
    #  Add the character to our temporary line
    $temp+=$char
    }
    
    #  Add our completed line to the output
    $output+=$temp + @crlf
    
  
  #  get rid of extra CRLF tacked onto the end
  $output = substr($output, 0, strlen(@crlf) *  - 1)
  
  return $output
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Prep Q Encoding
  #
  # Performs "Q Encoding" on a string for use in email headers.  It's related
  # but not identical to quoted-printable, so it has its own method
  #
  # @access	public
  # @param	str
  # @param	bool	// set to TRUE for processing From: headers
  # @return	str
  #
  _prep_q_encoding($str, $from = false)
  {
  $str = str_replace(["\r", "\n"], ['', ''], $str)
  
  #  Line length must not exceed 76 characters, so we adjust for
  #  a space, 7 extra characters =??Q??=, and the charset that we will add to each line
  $limit = 75 - 7 - strlen(@charset)
  
  #  these special characters must be converted too
  $convert = ['_', '=', '?']
  
  if $from is true
    $convert.push ','
    $convert.push ';'
    
  
  $output = ''
  $temp = ''
  
  for ($i = 0,$length = strlen($str)$i < $length$i++)
  {
  #  Grab the next character
  $char = substr($str, $i, 1)
  $ascii = ord($char)
  
  #  convert ALL non-printable ASCII characters and our specials
  if $ascii < 32 or $ascii > 126 or in_array($char, $convert)
    $char = '=' + dechex($ascii)
    
  
  #  handle regular spaces a bit more compactly than =20
  if $ascii is 32
    $char = '_'
    
  
  #  If we're at the character limit, add the line to the output,
  #  reset our temp variable, and keep on chuggin'
  if (strlen($temp) + strlen($char))>=$limit
    $output+=$temp + @crlf
    $temp = ''
    
  
  #  Add the character to our temporary line
  $temp+=$char
  }
  
  $str = $output + $temp
  
  #  wrap each line with the shebang, charset, and transfer encoding
  #  the preceding space on successive lines is required for header "folding"
  $str = trim(preg_replace('/^(.*)$/m', ' =?' + @charset + '?Q?$1?=', $str))
  
  return $str
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Send Email
  #
  # @access	public
  # @return	bool
  #
  send()
  {
  if @_replyto_flag is false
    @reply_to(@_headers['From'])
    
  
  if ( not @_recipients?  and  not @_headers['To']? ) and ( not @_bcc_array?  and  not @_headers['Bcc']? ) and ( not @_headers['Cc']? )
    @_set_error_message('email_no_recipients')
    return false
    
  
  @_build_headers()
  
  if @bcc_batch_mode and count(@_bcc_array) > 0
    if count(@_bcc_array) > @bcc_batch_size then return @batch_bcc_send()}@_build_message()
  if not @_spool_email()
    return false
    
  else 
    return true
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Batch Bcc Send.  Sends groups of BCCs in batches
  #
  # @access	public
  # @return	bool
  #
  batch_bcc_send()
  {
  $float = @bcc_batch_size - 1
  
  $set = ""
  
  $chunk = {}
  
  for ($i = 0$i < count(@_bcc_array)$i++)
  {
  if @_bcc_array[$i]? 
    $set+=", " + @_bcc_array[$i]
    
  
  if $i is $float
    $chunk.push substr($set, 1)
    $float = $float + @bcc_batch_size
    $set = ""
    
  
  if $i is count(@_bcc_array) - 1
    $chunk.push substr($set, 1)
    
  }
  
  for ($i = 0$i < count($chunk)$i++)
  {
  delete @_headers['Bcc']
  delete $bcc
  
  $bcc = @_str_to_array($chunk[$i])
  $bcc = @clean_email($bcc)
  
  if @protocol isnt 'smtp'
    @_set_header('Bcc', implode(", ", $bcc))
    
  else 
    @_bcc_array = $bcc
    
  
  @_build_message()
  @_spool_email()
  }
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Unwrap special elements
  #
  # @access	private
  # @return	void
  #
  _unwrap_specials()
  {
  @_finalbody = preg_replace_callback("/\{unwrap\}(.*?)\{\/unwrap\}/si", [@, '_remove_nl_callback'], @_finalbody)
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Strip line-breaks via callback
  #
  # @access	private
  # @return	string
  #
  _remove_nl_callback($matches)
  {
  if strpos($matches[1], "\r") isnt false or strpos($matches[1], "\n") isnt false
    $matches[1] = str_replace(["\r\n", "\r", "\n"], '', $matches[1])
    
  
  return $matches[1]
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Spool mail to the mail server
  #
  # @access	private
  # @return	bool
  #
  _spool_email()
  {
  @_unwrap_specials()
  
  switch @_get_protocol()
    when 'mail'
      
      if not @_send_with_mail()
        @_set_error_message('email_send_failure_phpmail')
        return false
        
      
    when 'sendmail'
      
      if not @_send_with_sendmail()
        @_set_error_message('email_send_failure_sendmail')
        return false
        
      
    when 'smtp'
      
      if not @_send_with_smtp()
        @_set_error_message('email_send_failure_smtp')
        return false
        
      
      
      
  
  @_set_error_message('email_sent', @_get_protocol())
  return true
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Send using mail()
  #
  # @access	private
  # @return	bool
  #
  _send_with_mail()
  {
  if @_safe_mode is true
    if not mail(@_recipients, @_subject, @_finalbody, @_header_str)
      return false
      
    else 
      return true
      
    
  else 
    #  most documentation of sendmail using the "-f" flag lacks a space after it, however
    #  we've encountered servers that seem to require it to be in place.
    
    if not mail(@_recipients, @_subject, @_finalbody, @_header_str, "-f " + @clean_email(@_headers['From']))
      return false
      
    else 
      return true
      
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Send using Sendmail
  #
  # @access	private
  # @return	bool
  #
  _send_with_sendmail()
  {
  $fp = popen(@mailpath + " -oi -f " + @clean_email(@_headers['From']) + " -t", 'w')
  
  if $fp is false or $fp is null
    #  server probably has popen disabled, so nothing we can do to get a verbose error.
    return false
    
  
  fputs($fp, @_header_str)
  fputs($fp, @_finalbody)
  
  $status = pclose($fp)
  
  if version_compare(PHP_VERSION, '4.2.3') is  - 1
    $status = $status>>8 and 0o0xFF
    
  
  if $status isnt 0
    @_set_error_message('email_exit_status', $status)
    @_set_error_message('email_no_socket')
    return false
    
  
  return true
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Send using SMTP
  #
  # @access	private
  # @return	bool
  #
  _send_with_smtp()
  {
  if @smtp_host is ''
    @_set_error_message('email_no_hostname')
    return false
    
  
  @_smtp_connect()
  @_smtp_authenticate()
  
  @_send_command('from', @clean_email(@_headers['From']))
  
  for $val in @_recipients
    @_send_command('to', $val)
    
  
  if count(@_cc_array) > 0
    for $val in @_cc_array
      if $val isnt ""
        @_send_command('to', $val)
        
      
    
  
  if count(@_bcc_array) > 0
    for $val in @_bcc_array
      if $val isnt ""
        @_send_command('to', $val)
        
      
    
  
  @_send_command('data')
  
  #  perform dot transformation on any lines that begin with a dot
  @_send_data(@_header_str + preg_replace('/^\./m', '..$1', @_finalbody))
  
  @_send_data('.')
  
  $reply = @_get_smtp_data()
  
  @_set_error_message($reply)
  
  if strncmp($reply, '250', 3) isnt 0
    @_set_error_message('email_smtp_error', $reply)
    return false
    
  
  @_send_command('quit')
  return true
  }
  
  #  --------------------------------------------------------------------
  
  #
  # SMTP Connect
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _smtp_connect()
  {
  @_smtp_connect = fsockopen(@smtp_host, @smtp_port, $errno, $errstr, @smtp_timeout)
  
  if not is_resource(@_smtp_connect)
    @_set_error_message('email_smtp_error', $errno + " " + $errstr)
    return false
    
  
  @_set_error_message(@_get_smtp_data())
  return @_send_command('hello')
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Send SMTP command
  #
  # @access	private
  # @param	string
  # @param	string
  # @return	string
  #
  _send_command($cmd, $data = '')
  {
  switch $cmd
    when 'hello'
      
      if @_smtp_auth or @_get_encoding() is '8bit' then @_send_data('EHLO ' + @_get_hostname())
      else @_send_data('HELO ' + @_get_hostname())
      
      $resp = 250
      
    when 'from'
      
      @_send_data('MAIL FROM:<' + $data + '>')
      
      $resp = 250
      
    when 'to'
      
      @_send_data('RCPT TO:<' + $data + '>')
      
      $resp = 250
      
    when 'data'
      
      @_send_data('DATA')
      
      $resp = 354
      
    when 'quit'
      
      @_send_data('QUIT')
      
      $resp = 221
      
      
  
  $reply = @_get_smtp_data()
  
  @_debug_msg.push "<pre>" + $cmd + ": " + $reply + "</pre>"
  
  if substr($reply, 0, 3) isnt $resp
    @_set_error_message('email_smtp_error', $reply)
    return false
    
  
  if $cmd is 'quit'
    fclose(@_smtp_connect)
    
  
  return true
  }
  
  #  --------------------------------------------------------------------
  
  #
  #  SMTP Authenticate
  #
  # @access	private
  # @return	bool
  #
  _smtp_authenticate()
  {
  if not @_smtp_auth
    return true
    
  
  if @smtp_user is "" and @smtp_pass is ""
    @_set_error_message('email_no_smtp_unpw')
    return false
    
  
  @_send_data('AUTH LOGIN')
  
  $reply = @_get_smtp_data()
  
  if strncmp($reply, '334', 3) isnt 0
    @_set_error_message('email_failed_smtp_login', $reply)
    return false
    
  
  @_send_data(base64_encode(@smtp_user))
  
  $reply = @_get_smtp_data()
  
  if strncmp($reply, '334', 3) isnt 0
    @_set_error_message('email_smtp_auth_un', $reply)
    return false
    
  
  @_send_data(base64_encode(@smtp_pass))
  
  $reply = @_get_smtp_data()
  
  if strncmp($reply, '235', 3) isnt 0
    @_set_error_message('email_smtp_auth_pw', $reply)
    return false
    
  
  return true
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Send SMTP data
  #
  # @access	private
  # @return	bool
  #
  _send_data($data)
  {
  if not fwrite(@_smtp_connect, $data + @newline)
    @_set_error_message('email_smtp_data_failure', $data)
    return false
    
  else 
    return true
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Get SMTP data
  #
  # @access	private
  # @return	string
  #
  _get_smtp_data()
  {
  $data = ""
  
  while $str = fgets(@_smtp_connect, 512))$data+=$str
  
  if substr($str, 3, 1) is " "
    break
    
  }
  
  return $data
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Get Hostname
  #
  # @access	private
  # @return	string
  #
  _get_hostname()
  {
  return if ($_SERVER['SERVER_NAME']? ) then $_SERVER['SERVER_NAME'] else 'localhost.localdomain'
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Get IP
  #
  # @access	private
  # @return	string
  #
  _get_ip()
  {
  if @_IP isnt false
    return @_IP
    
  
  $cip = if ($_SERVER['HTTP_CLIENT_IP']?  and $_SERVER['HTTP_CLIENT_IP'] isnt "") then $_SERVER['HTTP_CLIENT_IP'] else false
  $rip = if ($_SERVER['REMOTE_ADDR']?  and $_SERVER['REMOTE_ADDR'] isnt "") then $_SERVER['REMOTE_ADDR'] else false
  $fip = if ($_SERVER['HTTP_X_FORWARDED_FOR']?  and $_SERVER['HTTP_X_FORWARDED_FOR'] isnt "") then $_SERVER['HTTP_X_FORWARDED_FOR'] else false
  
  if $cip and $rip#  --------------------------------------------------------------------#
  # Get Debug Message
  #
  # @access	public
  # @return	string
  #
    $msg = ''
    
    if count(@_debug_msg) > 0
      for $val in @_debug_msg
        $msg+=$val
        
      
    
    $msg+="<pre>" + @_header_str + "\n" + htmlspecialchars(@_subject) + "\n" + htmlspecialchars(@_finalbody) + '</pre>'
    return $msg
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set Message
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _set_error_message($msg, $val = '')
  {
  $CI = get_instance()
  $CI.lang.load('email')
  
  if false is ($line = $CI.lang.line($msg))
    @_debug_msg.push str_replace('%s', $val, $msg) + "<br />"
    
  else 
    @_debug_msg.push str_replace('%s', $val, $line) + "<br />"
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Mime Types
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _mime_types($ext = "")
  {
  $mimes = 'hqx':'application/mac-binhex40', 
    'cpt':'application/mac-compactpro', 
    'doc':'application/msword', 
    'bin':'application/macbinary', 
    'dms':'application/octet-stream', 
    'lha':'application/octet-stream', 
    'lzh':'application/octet-stream', 
    'exe':'application/octet-stream', 
    'class':'application/octet-stream', 
    'psd':'application/octet-stream', 
    'so':'application/octet-stream', 
    'sea':'application/octet-stream', 
    'dll':'application/octet-stream', 
    'oda':'application/oda', 
    'pdf':'application/pdf', 
    'ai':'application/postscript', 
    'eps':'application/postscript', 
    'ps':'application/postscript', 
    'smi':'application/smil', 
    'smil':'application/smil', 
    'mif':'application/vnd.mif', 
    'xls':'application/vnd.ms-excel', 
    'ppt':'application/vnd.ms-powerpoint', 
    'wbxml':'application/vnd.wap.wbxml', 
    'wmlc':'application/vnd.wap.wmlc', 
    'dcr':'application/x-director', 
    'dir':'application/x-director', 
    'dxr':'application/x-director', 
    'dvi':'application/x-dvi', 
    'gtar':'application/x-gtar', 
    'php':'application/x-httpd-php', 
    'php4':'application/x-httpd-php', 
    'php3':'application/x-httpd-php', 
    'phtml':'application/x-httpd-php', 
    'phps':'application/x-httpd-php-source', 
    'js':'application/x-javascript', 
    'swf':'application/x-shockwave-flash', 
    'sit':'application/x-stuffit', 
    'tar':'application/x-tar', 
    'tgz':'application/x-tar', 
    'xhtml':'application/xhtml+xml', 
    'xht':'application/xhtml+xml', 
    'zip':'application/zip', 
    'mid':'audio/midi', 
    'midi':'audio/midi', 
    'mpga':'audio/mpeg', 
    'mp2':'audio/mpeg', 
    'mp3':'audio/mpeg', 
    'aif':'audio/x-aiff', 
    'aiff':'audio/x-aiff', 
    'aifc':'audio/x-aiff', 
    'ram':'audio/x-pn-realaudio', 
    'rm':'audio/x-pn-realaudio', 
    'rpm':'audio/x-pn-realaudio-plugin', 
    'ra':'audio/x-realaudio', 
    'rv':'video/vnd.rn-realvideo', 
    'wav':'audio/x-wav', 
    'bmp':'image/bmp', 
    'gif':'image/gif', 
    'jpeg':'image/jpeg', 
    'jpg':'image/jpeg', 
    'jpe':'image/jpeg', 
    'png':'image/png', 
    'tiff':'image/tiff', 
    'tif':'image/tiff', 
    'css':'text/css', 
    'html':'text/html', 
    'htm':'text/html', 
    'shtml':'text/html', 
    'txt':'text/plain', 
    'text':'text/plain', 
    'log':'text/plain', 
    'rtx':'text/richtext', 
    'rtf':'text/rtf', 
    'xml':'text/xml', 
    'xsl':'text/xml', 
    'mpeg':'video/mpeg', 
    'mpg':'video/mpeg', 
    'mpe':'video/mpeg', 
    'qt':'video/quicktime', 
    'mov':'video/quicktime', 
    'avi':'video/x-msvideo', 
    'movie':'video/x-sgi-movie', 
    'doc':'application/msword', 
    'word':'application/msword', 
    'xl':'application/excel', 
    'eml':'message/rfc822'
    
  
  return ( not $mimes[strtolower($ext? ])) then "application/x-unknown-content-type" else $mimes[strtolower($ext)]
  }
  
  

register_class 'CI_Email', CI_Email
module.exports = CI_Email
#  END CI_Email class

#  End of file Email.php 
#  Location: ./system/libraries/Email.php 