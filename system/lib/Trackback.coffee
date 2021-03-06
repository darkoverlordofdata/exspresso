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
# Trackback Class
#
# Trackback Sending/Receiving Class
#
#
module.exports = class system.lib.Trackback
  
  time_format: 'local'
  charset: 'UTF-8'
  data: 'url':'', 'title':'', 'excerpt':'', 'blog_name':'', 'charset':''
  convert_ascii: true
  response: ''
  error_msg: {}
  
  #
  # Constructor
  #
    #
  constructor: ($controller, $config = {}) ->
    log_message('debug', "Trackback Class Initialized")

  #
  # Send Trackback
  #
    # @param  [Array]  # @return	bool
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
    # @return	bool
  #
  receive :  ->
    for $val in ['url', 'title', 'blog_name', 'excerpt']
      if not @req.body[$val]?  or @req.body[$val] is ''
        @set_error('The following required POST variable is missing: ' + $val)
        return false
        
      
      @data['charset'] = if ( not @req.body['charset']? ) then 'auto' else strtoupper(trim(@req.body['charset']))
      
      if $val isnt 'url' and function_exists('mb_convert_encoding')
        @req.body[$val] = mb_convert_encoding(@req.body[$val], @charset, @data['charset'])
        
      
      @req.body[$val] = if ($val isnt 'url') then @convert_xml(strip_tags(@req.body[$val])) else strip_tags(@req.body[$val])
      
      if $val is 'excerpt'
        @req.body['excerpt'] = @limit_characters(@req.body['excerpt'])
        
      
      @data[$val] = @req.body[$val]
      
    
    return true
    
  
  #
  # Send Trackback Error Message
  #
  # Allows custom errors to be set.  By default it
  # sends the "incomplete information" error, as that's
  # the most common one.
  #
    # @param  [String]    # @return [Void]  #
  send_error : ($message = 'Incomplete Information') ->
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?" + ">\n<response>\n<error>1</error>\n<message>" + $message + "</message>\n</response>"
    die()
    
  
  #
  # Send Trackback Success Message
  #
  # This should be called when a trackback has been
  # successfully received and inserted.
  #
    # @return [Void]  #
  send_success :  ->
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?" + ">\n<response>\n<error>0</error>\n</response>"
    die()
    
  
  #
  # Fetch a particular item
  #
    # @param  [String]    # @return	[String]
  #
  data : ($item) ->
    return if ( not @data[$item]? ) then '' else @data[$item]
    
  
  #
  # Process Trackback
  #
  # Opens a socket connection and passes the data to
  # the server.  Returns TRUE on success, FALSE on failure
  #
    # @param  [String]    # @param  [String]    # @return	bool
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
    # @param  [String]    # @return	[String]
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
    # @param  [String]    # @return	[String]
  #
  validate_url : ($url) ->
    $url = trim($url)
    
    if substr($url, 0, 4) isnt "http"
      $url = "http://" + $url
      
    
  
  #
  # Find the Trackback URL's ID
  #
    # @param  [String]    # @return	[String]
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
    # @param  [String]    # @return	[String]
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
    # @param  [String]    # @param  [Integer]  # @param  [String]    # @return	[String]
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
    # @param  [String]    # @return	[String]
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
    # @param  [String]    # @return [Void]  #
  set_error : ($msg) ->
    log_message('error', $msg)
    @error_msg.push $msg
    
  
  #
  # Show error messages
  #
    # @param  [String]    # @param  [String]    # @return	[String]
  #
  display_errors : ($open = '<p>', $close = '</p>') ->
    $str = ''
    for $val in @error_msg
      $str+=$open + $val + $close
      
    
    return $str
    
