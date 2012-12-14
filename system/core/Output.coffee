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
#	Output - Main application
#
#
#

#  ------------------------------------------------------------------------

#
# Exspresso Output Class
#
module.exports = class global.CI_Output

  final_output: ''
  cache_expiration: 0
  headers: {}
  mime_types: {}
  _enable_profiler: false
  _zlib_oc: false
  _profiler_sections: {}

  parse_exec_vars: true #  whether or not to parse variables like {elapsed_time} and {memory_usage}

  constructor: ->

    log_message('debug', "Output Class Initialized")
    @final_output = ''
    @cache_expiration = 0
    @headers = {}
    @mime_types = {}
    @_profiler_sections = {}

    #  Get mime types for later
    if file_exists(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
      $mimes = require(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)

    else
      $mimes = require(APPPATH + 'config/mimes' + EXT)

    @mime_types = $mimes
    $SRV.output @
    load_class('Cache', 'core')

  # --------------------------------------------------------------------
  # Method Stubs
  #
  #   These methods will be overriden by the middleware
  # --------------------------------------------------------------------

  #  --------------------------------------------------------------------

  #
  # Get Output
  #
  # Returns the current output string
  #
  # @access	public
  # @return	string
  #
  get_output :  ->
    @final_output


  #  --------------------------------------------------------------------

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
    @final_output = $output

    @


  #  --------------------------------------------------------------------

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
    if @final_output is ''
      @final_output = $output

    else
      @final_output+=$output


    @


  #  --------------------------------------------------------------------

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

    @headers.push [$header, $replace]

    @


  #  --------------------------------------------------------------------

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
      if @mime_types[$extension]?
        $mime_type = @mime_types[$extension]

        if is_array($mime_type)
          $mime_type = current($mime_type)

    $header = 'Content-Type: ' + $mime_type

    @headers.push [$header, true]

    @


  #  --------------------------------------------------------------------

  #
  # Set HTTP Status Header
  # moved to Common procedural functions in 1.7.2
  #
  # @access	public
  # @param	int		the status code
  # @param	string
  # @return	void
  #
  set_status_header : ($code = 200, $text = '') ->
    @

  #  --------------------------------------------------------------------

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


  #  --------------------------------------------------------------------

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


  #  --------------------------------------------------------------------

  #
  # Set Cache
  #
  # @access	public
  # @param	integer
  # @return	void
  #
  cache : ($time) ->
    @cache_expiration = if ( not is_numeric($time)) then 0 else $time
    @



  # --------------------------------------------------------------------

  #
  # Override output instance methods
  #
  #   @returns function middlware callback
  #
  middleware: ()->

    log_message 'debug',"Output middleware initialized"

    ($req, $res, $next) =>

      #$CI = $res.CI
      $BM = load_new('Benchmark', 'core')
      $BM.mark 'total_execution_time_start'

      # --------------------------------------------------------------------
      @set_status_header = ($code = 200, $text = '') ->
        $res.status($code)
        @


      #  --------------------------------------------------------------------

      #
      # Display Output
      #
      # All "view" data is automatically put into this variable by the controller class:
      #
      # $this->final_output
      #
      # This function sends the finalized output data to the browser along
      # with any server headers and profile data.  It also stops the
      # benchmark timer so the page rendering speed and memory usage can be shown.
      #
      # @access	public
      # @return	mixed
      #
      @_display = ($output = '') ->
        #  Note:  We use globals because we can't use $CI =& get_instance()
        #  since this function is sometimes called by the caching mechanism,
        #  which happens before the CI super object is available.

        #  Grab the super object if we can.
        if class_exists('CI_Controller')
          $CI = get_instance()

        #  --------------------------------------------------------------------

        #  Set the output data
        if $output is ''
          $output = @final_output


        #  --------------------------------------------------------------------

        #  Do we need to write a cache file?  Only if the controller does not have its
        #  own _output() method and we are not dealing with a cache file, which we
        #  can determine by the existence of the $CI object above
        if @cache_expiration > 0 and $CI?  and  not method_exists($CI, '_output')
          @_write_cache($output)


        #  --------------------------------------------------------------------

        #  Parse out the elapsed time and memory usage,
        #  then swap the pseudo-variables with the data

        $elapsed = $BM.elapsed_time('total_execution_time_start', 'total_execution_time_end')

        if @parse_exec_vars is true
          $memory = if ( not function_exists('memory_get_usage')) then '0' else round(memory_get_usage() / 1024 / 1024, 2) + 'MB'
          $output = str_replace('{elapsed_time}', $elapsed, $output)
          $output = str_replace('{elapsed_time}', $elapsed, $output)
          $output = str_replace('{memory_usage}', $memory, $output)
          $output = str_replace('{memory_usage}', $memory, $output)


        #  --------------------------------------------------------------------

        #  Is compression requested?
        if $CFG.item('compress_output') is true and @_zlib_oc is false
          if extension_loaded('zlib')
            if $_SERVER['HTTP_ACCEPT_ENCODING']?  and strpos($_SERVER['HTTP_ACCEPT_ENCODING'], 'gzip') isnt false
              ob_start('ob_gzhandler')




        #  --------------------------------------------------------------------

        #  Are there any server headers to send?
        if count(@headers) > 0
          for $header in @headers
            $res.header($header[0], $header[1])



        #  --------------------------------------------------------------------

        #  Does the $CI object exist?
        #  If not we know we are dealing with a cache file so we'll
        #  simply echo out the data and exit.
        if not $CI?
          $res.send $output
          log_message('debug', "Final output sent to browser")
          log_message('debug', "Total execution time: " + $elapsed)
          return true

        #  --------------------------------------------------------------------

        #  Do we need to generate profile data?
        #  If so, load the Profile class and run it.
        if @_enable_profiler is true
          $res.CI.benchmark = $BM
          $res.CI.load.library('profiler')

          if not empty(@_profiler_sections)
            $res.CI.profiler.set_sections(@_profiler_sections)


          #  If the output data contains closing </body> and </html> tags
          #  we will remove them and add them back after we insert the profile data
          $match = preg_match("|</body>[^]*?</html>|igm", $output)
          if $match?
            $output = preg_replace("|</body>[^]*?</html>|igm", '', $output)
            $output+=$res.CI.profiler.run()
            $output+='</body></html>'

          else
            $output+=$res.CI.profiler.run()



        #  --------------------------------------------------------------------

        #  Does the controller contain a function named _output()?
        #  If so send the output there.  Otherwise, echo it.
        if method_exists($res.CI, '_output')
          $res.CI._output($output)

        else
          $res.send $output #  Send it to the browser!

        @final_output = ''
        log_message('debug', "Final output sent to browser")
        log_message('debug', "Total execution time: " + $elapsed)


      #  --------------------------------------------------------------------

      #
      # Write a Cache File
      #
      # @access	public
      # @return	void
      #
      @_write_cache = ($output) ->
        #$CI = get_instance()
        $path = $CI.config.item('cache_path')

        $cache_path = if ($path is '') then APPPATH + 'cache/' else $path

        if not is_dir($cache_path) or  not is_really_writable($cache_path)
          log_message('error', "Unable to write cache file: " + $cache_path)
          return


        $uri = $CI.config.item('base_url') + $CI.config.item('index_page') + $CI.uri.uri_string()

        $cache_path+=md5($uri)

        if not ($fp = fopen($cache_path, FOPEN_WRITE_CREATE_DESTRUCTIVE))
          log_message('error', "Unable to write cache file: " + $cache_path)
          return

        $expire = time() + (@cache_expiration * 60)

        if flock($fp, LOCK_EX)
          fwrite($fp, $expire + 'TS--->' + $output)
          flock($fp, LOCK_UN)

        else
          log_message('error', "Unable to secure a file lock for file at: " + $cache_path)
          return

        fclose($fp)
        chmod($cache_path, FILE_WRITE_MODE)

        log_message('debug', "Cache file written: " + $cache_path)


      #  --------------------------------------------------------------------

      #
      # Update/serve a cached file
      #
      # @access	public
      # @return	void
      #
      @_display_cache = ($CFG, $URI) ->
        $cache_path = if ($CFG.item('cache_path') is '') then APPPATH + 'cache/' else $CFG.item('cache_path')

        #  Build the file path.  The file name is an MD5 hash of the full URI
        $uri = $CFG.item('base_url') + $CFG.item('index_page') + $URI.uri_string

        $filepath = $cache_path + md5($uri)

        if not file_exists($filepath)
          return false


        if not ($fp = fopen($filepath, FOPEN_READ)) then return false
        flock($fp, LOCK_SH)

        $cache = ''
        if filesize($filepath) > 0
          $cache = fread($fp, filesize($filepath))


        flock($fp, LOCK_UN)
        fclose($fp)

        #  Strip out the embedded timestamp
        if not preg_match("/(\d+TS--->)/", $cache, $match)
          return false


        #  Has the file expired? If so we'll delete it.
        if time()>=trim(str_replace('TS--->', '', $match['1']))
          if is_really_writable($cache_path)
            unlink($filepath)
            log_message('debug', "Cache file has expired. File deleted")
            return false



        #  Display the cache
        @_display(str_replace($match['0'], '', $cache))
        log_message('debug', "Cache file is current. Sending it to browser.")
        return true


      $next()


# END CI_Output class

# End of file Output.coffee
# Location: ./system/core/Output.coffee