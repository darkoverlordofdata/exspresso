#+--------------------------------------------------------------------+
#  Trackback.coffee
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
# Trackback Class
#
# Trackback Sending/Receiving Class
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Trackbacks
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/trackback.html
#
class Exspresso_Trackback
  
  time_format: 'local'
  charset: 'UTF-8'
  data: 'url':'', 'title':'', 'excerpt':'', 'blog_name':'', 'charset':''
  convert_ascii: true
  response: ''
  error_msg: {}
  
  #
  # Constructor
  #
  # @access	public
  #
  __construct()
  {
  log_message('debug', "Trackback Class Initialized")
  }
  
  #
  # Send Trackback
  #
  # @access	public
  # @param	array
  # @return	bool
  #
  send : ($tb_data) ->
    if not is_array($tb_data)
      @set_error('The send() method must be passed an array')
      return false
      
    
    #  Pre-process the Trackback Data
    for $item in ['url', 'title', 'excerpt', 'blog_name', 'ping_url']
      if not $tb_data[$item]? 
        @set_error('Required item missing: ' + $item)
        return false
        
      
      switch $item
        when 'ping_url'$item = @extract_urls($tb_data[$item])
          
        when 'excerpt'$item = @limit_characters(@convert_xml(strip_tags(stripslashes($tb_data[$item]))))
          
        when 'url'$item = str_replace('&#45;', '-', @convert_xml(strip_tags(stripslashes($tb_data[$item]))))
          
        else$item = @convert_xml(strip_tags(stripslashes($tb_data[$item])))
          
          
      
      #  Convert High ASCII Characters
      if @convert_ascii is true
        if $item is 'excerpt'
          $item = @convert_ascii($item)
          
        else if $item is 'title'
          $item = @convert_ascii($item)
          
        else if $item is 'blog_name'
          $item = @convert_ascii($item)
          
        
      
    
    #  Build the Trackback data string
    $charset = if ( not $tb_data['charset']? ) then @charset else $tb_data['charset']
    
    $data = "url=" + rawurlencode($url) + "&title=" + rawurlencode($title) + "&blog_name=" + rawurlencode($blog_name) + "&excerpt=" + rawurlencode($excerpt) + "&charset=" + rawurlencode($charset)
    
    #  Send Trackback(s)
    $return = true
    if count($ping_url) > 0
      for $url in $ping_url
        if @process($url, $data) is false
          $return = false
          
        
      
    
    return $return
    
  
  #
  # Receive Trackback  Data
  #
  # This function simply validates the incoming TB data.
  # It returns FALSE on failure and TRUE on success.
  # If the data is valid it is set to the $this->data array
  # so that it can be inserted into a database.
  #
  # @access	public
  # @return	bool
  #
  receive :  ->
    for $val in ['url', 'title', 'blog_name', 'excerpt']
      if not @$_POST[$val]?  or @$_POST[$val] is ''
        @set_error('The following required POST variable is missing: ' + $val)
        return false
        
      
      @data['charset'] = if ( not @$_POST['charset']? ) then 'auto' else strtoupper(trim(@$_POST['charset']))
      
      if $val isnt 'url' and function_exists('mb_convert_encoding')
        @$_POST[$val] = mb_convert_encoding(@$_POST[$val], @charset, @data['charset'])
        
      
      @$_POST[$val] = if ($val isnt 'url') then @convert_xml(strip_tags(@$_POST[$val])) else strip_tags(@$_POST[$val])
      
      if $val is 'excerpt'
        @$_POST['excerpt'] = @limit_characters(@$_POST['excerpt'])
        
      
      @data[$val] = @$_POST[$val]
      
    
    return true
    
  
  #
  # Send Trackback Error Message
  #
  # Allows custom errors to be set.  By default it
  # sends the "incomplete information" error, as that's
  # the most common one.
  #
  # @access	public
  # @param	string
  # @return	void
  #
  send_error : ($message = 'Incomplete Information') ->
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?" + ">\n<response>\n<error>1</error>\n<message>" + $message + "</message>\n</response>"
    die()
    
  
  #
  # Send Trackback Success Message
  #
  # This should be called when a trackback has been
  # successfully received and inserted.
  #
  # @access	public
  # @return	void
  #
  send_success :  ->
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?" + ">\n<response>\n<error>0</error>\n</response>"
    die()
    
  
  #
  # Fetch a particular item
  #
  # @access	public
  # @param	string
  # @return	string
  #
  data : ($item) ->
    return if ( not @data[$item]? ) then '' else @data[$item]
    
  
  #
  # Process Trackback
  #
  # Opens a socket connection and passes the data to
  # the server.  Returns TRUE on success, FALSE on failure
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	bool
  #
  process : ($url, $data) ->
    $target = parse_url($url)
    
    #  Open the socket
    if not $fp = fsockopen($target['host'], 80)) then @set_error('Invalid Connection: ' + $url)
    return false
    }
    
    #  Build the path
    $ppath = if ( not $target['path']? ) then $url else $target['path']
    
    $path = if ($target['query']?  and $target['query'] isnt "") then $ppath + '?' + $target['query'] else $ppath
    
    #  Add the Trackback ID to the data string
    if $id = @get_id($url)) then $data = "tb_id=" + $id + "&" + $data}fputs($fp, "POST " + $path + " HTTP/1.0\r\n")#  Transfer the data
    fputs($fp, "Host: " + $target['host'] + "\r\n")
    fputs($fp, "Content-type: application/x-www-form-urlencoded\r\n")
    fputs($fp, "Content-length: " + strlen($data) + "\r\n")
    fputs($fp, "Connection: close\r\n\r\n")
    fputs($fp, $data)
    
    #  Was it successful?
    @response = ""
    
    while not feof($fp)
      @response+=fgets($fp, 128)
      
    fclose($fp)
    
    
    if stristr(@response, '<error>0</error>') is false
      $message = 'An unknown error was encountered'
      
      if preg_match("/<message>(.*?)<\/message>/is", @response, $match)
        $message = trim($match['1'])
        
      
      @set_error($message)
      return false
      
    
    return true
    
  
  #
  # Extract Trackback URLs
  #
  # This function lets multiple trackbacks be sent.
  # It takes a string of URLs (separated by comma or
  # space) and puts each URL into an array
  #
  # @access	public
  # @param	string
  # @return	string
  #
  extract_urls : ($urls) ->
    #  Remove the pesky white space and replace with a comma.
    $urls = preg_replace("/\s*(\S+)\s*/", "\\1,", $urls)
    
    #  If they use commas get rid of the doubles.
    $urls = str_replace(",,", ",", $urls)
    
    #  Remove any comma that might be at the end
    if substr($urls,  - 1) is ","
      $urls = substr($urls, 0,  - 1)
      
    
    #  Break into an array via commas
    $urls = preg_split('/[,]/', $urls)
    
    #  Removes duplicates
    $urls = array_unique($urls)
    
    array_walk($urls, [@, 'validate_url'])
    
    return $urls
    
  
  #
  # Validate URL
  #
  # Simply adds "http://" if missing
  #
  # @access	public
  # @param	string
  # @return	string
  #
  validate_url : ($url) ->
    $url = trim($url)
    
    if substr($url, 0, 4) isnt "http"
      $url = "http://" + $url
      
    
  
  #
  # Find the Trackback URL's ID
  #
  # @access	public
  # @param	string
  # @return	string
  #
  get_id : ($url) ->
    $tb_id = ""
    
    if strpos($url, '?') isnt false
      $tb_array = explode('/', $url)
      $tb_end = $tb_array[count($tb_array) - 1]
      
      if not is_numeric($tb_end)
        $tb_end = $tb_array[count($tb_array) - 2]
        
      
      $tb_array = explode('=', $tb_end)
      $tb_id = $tb_array[count($tb_array) - 1]
      
    else 
      $url = rtrim($url, '/')
      
      $tb_array = explode('/', $url)
      $tb_id = $tb_array[count($tb_array) - 1]
      
      if not is_numeric($tb_id)
        $tb_id = $tb_array[count($tb_array) - 2]
        
      
    
    if not preg_match("/^([0-9]+)$/", $tb_id)
      return false
      
    else 
      return $tb_id
      
    
  
  #
  # Convert Reserved XML characters to Entities
  #
  # @access	public
  # @param	string
  # @return	string
  #
  convert_xml : ($str) ->
    $temp = '__TEMP_AMPERSANDS__'
    
    $str = preg_replace("/&#(\d+);/", "$temp\\1;", $str)
    $str = preg_replace("/&(\w+);/", "$temp\\1;", $str)
    
    $str = str_replace(["&", "<", ">", "\"", "'", "-"], 
    ["&amp;", "&lt;", "&gt;", "&quot;", "&#39;", "&#45;"], 
    $str)
    
    $str = preg_replace("/$temp(\d+);/", "&#\\1;", $str)
    $str = preg_replace("/$temp(\w+);/", "&\\1;", $str)
    
    return $str
    
  
  #
  # Character limiter
  #
  # Limits the string based on the character count. Will preserve complete words.
  #
  # @access	public
  # @param	string
  # @param	integer
  # @param	string
  # @return	string
  #
  limit_characters : ($str, $n = 500, $end_char = '&#8230;') ->
    if strlen($str) < $n
      return $str
      
    
    $str = preg_replace("/\s+/", ' ', str_replace(["\r\n", "\r", "\n"], ' ', $str))
    
    if strlen($str)<=$n
      return $str
      
    
    $out = ""
    for $val in explode(' ', trim($str))
      $out+=$val + ' '
      if strlen($out)>=$n
        return trim($out) + $end_char
        
      
    
  
  #
  # High ASCII to Entities
  #
  # Converts Hight ascii text and MS Word special chars
  # to character entities
  #
  # @access	public
  # @param	string
  # @return	string
  #
  convert_ascii : ($str) ->
    $count = 1
    $out = ''
    $temp = {}
    
    for ($i = 0,$s = strlen($str)$i < $s$i++)
    {
    $ordinal = ord($str[$i])
    
    if $ordinal < 128
      $out+=$str[$i]
      
    else 
      if count($temp) is 0
        $count = if ($ordinal < 224) then 2 else 3
        
      
      $temp.push $ordinal
      
      if count($temp) is $count
        $number = if ($count is 3) then (($temp['0']16) * 4096) + (($temp['1']64) * 64) + ($temp['2']64) else (($temp['0']32) * 64) + ($temp['1']64)
        
        $out+='&#' + $number + ';'
        $count = 1
        $temp = {}
        
      
    }
    
    return $out
    
  
  #
  # Set error message
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_error : ($msg) ->
    log_message('error', $msg)
    @error_msg.push $msg
    
  
  #
  # Show error messages
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	string
  #
  display_errors : ($open = '<p>', $close = '</p>') ->
    $str = ''
    for $val in @error_msg
      $str+=$open + $val + $close
      
    
    return $str
    
  
  

register_class 'Exspresso_Trackback', Exspresso_Trackback
module.exports = Exspresso_Trackback
#  END Trackback Class

#  End of file Trackback.php 
#  Location: ./system/libraries/Trackback.php 