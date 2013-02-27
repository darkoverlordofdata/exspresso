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

#
# Exspresso Output Class
#
class global.Exspresso_Output

  fs = require('fs')  # file system

  _parse_exec_vars    : true  # parse profiler vars {elapsed_time} and {memory_usage}
  _enable_profiler    : false # create profiler outout?
  _zlib_oc            : false # output compression?
  _headers            : null  # array of http headers
  _mime_types         : null  # array of valid mime types
  _profiler_sections  : null  # array of profiler sections to process
  _final_output       : ''    # resultant html output
  _cache_expiration   : 0     # cache flag

  constructor: (@req, @res, @EXP, @BM, @CFG, @URI) ->

    log_message('debug', "Output Class Initialized")

    @_final_output = ''
    @_cache_expiration = 0
    @_headers = {}
    @_mime_types = {}
    @_profiler_sections = {}

    #  Get mime types for later
    if file_exists(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
      $mimes = require(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)

    else
      $mimes = require(APPPATH + 'config/mimes' + EXT)

    @_mime_types = $mimes

  #
  # Get Output
  #
  # Returns the current output string
  #
  # @access	public
  # @return	string
  #
  get_output :  ->
    @_final_output


  #
  # Set Output
  #
  # Sets the output string
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_output : ($output) ->
    @_final_output = $output
    @


  #
  # Append Output
  #
  # Appends data onto the output string
  #
  # @access	public
  # @param	string
  # @return	void
  #
  append_output : ($output) ->
    if @_final_output is ''
      @_final_output = $output
    else
      @_final_output+=$output
    @


  #
  # Set Header
  #
  # Lets you set a server header which will be outputted with the final display.
  #
  # Note:  If a file is cached, headers will not be sent.  We need to figure out
  # how to permit header data to be saved with the cache data...
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_header : ($header, $replace = true) ->
    #  If zlib.output_compression is enabled it will compress the output,
    #  but it will not modify the content-length header to compensate for
    #  the reduction, causing the browser to hang waiting for more data.
    #  We'll just skip content-length in those cases.

    if @_zlib_oc and strncasecmp($header, 'content-length', 14) is 0
      return

    @_headers.push [$header, $replace]
    @


  #
  # Set Content Type Header
  #
  # @access	public
  # @param	string	extension of the file we're outputting
  # @return	void
  #
  set_content_type : ($mime_type) ->
    if strpos($mime_type, '/') is false
      $extension = ltrim($mime_type, '.')

      #  Is this extension supported?
      if @_mime_types[$extension]?
        $mime_type = @_mime_types[$extension]

        if is_array($mime_type)
          $mime_type = current($mime_type)

    $header = 'Content-Type: ' + $mime_type
    @_headers.push [$header, true]
    @


  #
  # Set HTTP Status Header
  #
  # @access	public
  # @param	int		the status code
  # @param	string
  # @return	void
  #
  set_status_header : ($code = 200, $text = '') ->
    @res.status($code)
    @

  #
  # Enable/disable Profiler
  #
  # @access	public
  # @param	bool
  # @return	void
  #
  enable_profiler : ($val = true) ->
    @_enable_profiler = if (is_bool($val)) then $val else true
    @


  #
  # Set Profiler Sections
  #
  # Allows override of default / config settings for Profiler section display
  #
  # @access	public
  # @param	array
  # @return	void
  #
  set_profiler_sections : ($sections) ->
    for $section, $enable of $sections
      @_profiler_sections[$section] = if ($enable isnt false) then true else false
    @


  #
  # Set Cache
  #
  # @access	public
  # @param	integer
  # @return	void
  #
  cache : ($time) ->
    @_cache_expiration = if ( not is_numeric($time)) then 0 else $time
    @


  #
  # Display Output
  #
  # All "view" data is automatically put into this variable by the controller class:
  #
  # @final_output
  #
  # This function sends the finalized output data to the browser along
  # with any server headers and profile data.  It also stops the
  # benchmark timer so the page rendering speed and memory usage can be shown.
  #
  # @access	public
  # @return	mixed
  #
  _display: ($controller = null, $output = '') ->
    #
    # ------------------------------------------------------
    #  Is there a "post_controller" hook?
    # ------------------------------------------------------
    #
    @EXP._call_hook 'post_controller', @

    #  Set the output data
    if $output is ''
      $output = @_final_output

    #  Do we need to write a cache file?  Only if the controller does not have its
    #  own _output() method and we are not dealing with a cache file, which we
    #  can determine by the existence of the $controller object above
    if @_cache_expiration > 0 and $controller? is true and not method_exists(@, '_output')
      @_write_cache($output)

    #  Parse out the elapsed time and memory usage,
    #  then swap the pseudo-variables with the data

    $elapsed = @BM.elapsed_time('total_execution_time_start', 'total_execution_time_end')

    if @_parse_exec_vars is true
      $memory = if ( not function_exists('memory_get_usage')) then '0' else round(memory_get_usage() / 1024 / 1024, 2) + 'MB'
      $output = str_replace('{elapsed_time}', $elapsed, $output)
      $output = str_replace('{elapsed_time}', $elapsed, $output)
      $output = str_replace('{memory_usage}', $memory, $output)
      $output = str_replace('{memory_usage}', $memory, $output)

    #  Is compression requested?
    #if @config.item('compress_output') is true and @_zlib_oc is false
    #  if extension_loaded('zlib')
    #    if @$_SERVER['HTTP_ACCEPT_ENCODING']?  and strpos(@$_SERVER['HTTP_ACCEPT_ENCODING'], 'gzip') isnt false
    #      ob_start('ob_gzhandler')

    #  Are there any server headers to send?
    if count(@_headers) > 0
      for $header in @_headers
        @res.header($header[0], $header[1])

    # Does the $controller object exist?
    # If not we know we are dealing with a cache file so we'll
    # simply echo out the data and exit.
    if not $controller?
      @res.send $output
      log_message('debug', "Final output sent to browser")
      log_message('debug', "Total execution time: " + $elapsed)
      return true


    #  Do we need to generate profile data?
    #  If so, load the Profile class and run it.
    if @_enable_profiler is true
      $controller.load.library('profiler')

      if not empty(@_profiler_sections)
        $controller.profiler.set_sections(@_profiler_sections)

      #  If the output data contains closing </body> and </html> tags
      #  we will remove them and add them back after we insert the profile data
      if ($match = preg_match("|<footer[^]*?</html>|igm", $output))?
        $output = preg_replace("|<footer[^]*?</html>|igm", '', $output)
        $output+=$controller.profiler.run()
        $output+='</body></html>'

      else
        $output+=$controller.profiler.run()

    #  Does the controller contain a function named _output()?
    #  If so send the output there.  Otherwise, echo it.
    if method_exists($controller, '_output')
      $controller._output($output)

    else
      @res.send $output #  Send it to the browser!

    @_final_output = ''
    log_message('debug', "Final output sent to browser")
    log_message('debug', "Total execution time: " + $elapsed)


  #
  # Write a Cache File
  #
  # @access	public
  # @return	void
  #
  _write_cache: ($output) ->

    time = -> Math.floor(Date.now()/100000)

    $path = @CFG.item('cache_path')

    $cache_path = if ($path is '') then APPPATH + 'cache/' else $path

    if not is_dir($cache_path) or  not is_really_writable($cache_path)
      log_message('error', "Unable to write cache file: " + $cache_path)
      return

    $uri = @CFG.item('base_url') + @CFG.item('index_page') + @URI.uri_string()

    $cache_path+=md5($uri)

    #if not ($fp = fs.openSync($cache_path, FOPEN_WRITE_CREATE_DESTRUCTIVE))
    #  log_message('error', "Unable to write cache file: " + $cache_path)
    #  return

    $expire = time() + (@_cache_expiration * 60)

    $buffer = $expire + 'TS--->' + $output
    #fs.writeSync($fp, $buffer, 0, $buffer.length, null)


    #fs.closeSync($fp)
    #fs.chmodSync($cache_path, FILE_WRITE_MODE)

    fs.writeFileSync($cache_path, $buffer)
    log_message('debug', "Cache file written: " + $cache_path)


  #
  # Update/serve a cached file
  #
  # @access	public
  # @return	void
  #
  _display_cache: ($CFG, $URI) ->

    time = -> Math.floor(Date.now()/100000)

    $cache_path = if ($CFG.item('cache_path') is '') then APPPATH + 'cache/' else $CFG.item('cache_path')

    #  Build the file path.  The file name is an MD5 hash of the full URI
    $uri = $CFG.item('base_url') + $CFG.item('index_page') + $URI.uri_string()

    $filepath = $cache_path + md5($uri)

    if not file_exists($filepath)
      return false

    #if not ($fp = fs.openSync($filepath, FOPEN_READ)) then return false

    #$cache = ''
    #if filesize($filepath) > 0
    #  fs.readSync($fp, $cache, 0, filesize($filepath), null)

    #fs.closeSync($fp)

    $cache = String(fs.readFileSync($filepath))
    #  Strip out the embedded timestamp
    if not ($match = preg_match("/(\\d+TS--->)/", $cache))?
      return false

    #  Has the file expired? If so we'll delete it.
    if time()>=trim(str_replace('TS--->', '', $match['1']))
      if is_really_writable($cache_path)
        fs.unlinkSync($filepath)
        log_message('debug', "Cache file has expired. File deleted")
        return false

    #  Display the cache
    log_message('debug', "Cache file is current. Sending it to browser.")
    @enable_profiler true
    @_display(null, str_replace($match['0'], '', $cache))
    return true


# END Exspresso_Output class
module.exports = Exspresso_Output

# End of file Output.coffee
# Location: ./system/core/Output.coffee