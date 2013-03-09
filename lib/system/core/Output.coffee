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
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#
# Exspresso Output Class
#
class system.core.Output

  fs = require('fs')  # file system

  _parse_exec_vars    : true  # parse profiler vars {elapsed_time} and {memory_usage}
  _enable_profiler    : false # create profiler outout?
  _zlib_oc            : false # output compression?
  _headers            : null  # array of http headers
  _mime_types         : null  # array of valid mime types
  _profiler_sections  : null  # array of profiler sections to process
  _final_output       : ''    # resultant html output
  _cache_expiration   : 0     # cache flag

  #
  # Constructor
  #
    # @param  [Object]    http request object
  # @param  [Object]    http response object
  # @param  [Object]    system.core.Benchmark
  # @param  [Object]    system.core.Hooks
  # @param  [Object]    system.core.Config
  # @param  [Object]    system.core.URI
  # @return [Void]  #
  constructor: ($req, $res, $bench, $hooks, $config, $uri) ->

    defineProperties @,
      req:      {writeable: false, value: $req}
      res:      {writeable: false, value: $res}
      hooks:    {writeable: false, value: $hooks}
      bench:    {writeable: false, value: $bench}
      config:   {writeable: false, value: $config}
      uri:      {writeable: false, value: $uri}

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
    # @return	[String]
  #
  getOutput :  ->
    @_final_output


  #
  # Set Output
  #
  # Sets the output string
  #
    # @param  [String]    # @return [Void]  #
  setOutput : ($output) ->
    @_final_output = $output
    @


  #
  # Append Output
  #
  # Appends data onto the output string
  #
    # @param  [String]    # @return [Void]  #
  appendOutput : ($output) ->
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
    # @param  [String]    # @return [Void]  #
  setHeader : ($header, $replace = true) ->
    @_headers.push [$header, $replace]
    @


  #
  # Set Content Type Header
  #
    # @param  [String]  extension of the file we're outputting
  # @return [Void]  #
  setContentType : ($mime_type) ->
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
    # @param	int		the status code
  # @param  [String]    # @return [Void]  #
  setStatusHeader : ($code = 200, $text = '') ->
    @res.status($code)
    @

  #
  # Enable/disable Profiler
  #
    # @return	[Boolean]
  # @return [Void]  #
  enableProfiler : ($val = true) ->
    @_enable_profiler = if (is_bool($val)) then $val else true
    @


  #
  # Set Profiler Sections
  #
  # Allows override of default / config settings for Profiler section display
  #
    # @param  [Array]  # @return [Void]  #
  setProfilerSections : ($sections) ->
    for $section, $enable of $sections
      @_profiler_sections[$section] = if ($enable isnt false) then true else false
    @


  #
  # Set Cache
  #
    # @param  [Integer]  # @return [Void]  #
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
    # @return [Mixed]  #
  display: ($controller = null, $output = '') ->

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

    $elapsed = @bench.elapsedTime('total_execution_time_start', 'total_execution_time_end')

    if @_parse_exec_vars is true
      $memory = if ( not function_exists('memory_get_usage')) then '0' else round(memory_get_usage() / 1024 / 1024, 2) + 'MB'
      $output = $output.replace(/{elapsed_time}/g, $elapsed)
      $output = $output.replace(/{memory_usage}/g, $memory)

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
      $footer = /<footer[^]*?<\/html>/mig
      if $footer.test($output)
        $output = $output.replace($footer, '')
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
    return

  #
  # Update/serve a cached file
  #
    # @return [Void]  #
  displayCache: () ->

    $cache_path = if (@config.item('cache_path') is '') then APPPATH + 'cache/' else @config.item('cache_path')

    #  Build the file path.  The file name is an MD5 hash of the full URI
    $uri = @config.item('base_url') + @config.item('index_page') + @uri.uriString()

    $filepath = $cache_path+md5($uri)

    if not file_exists($filepath)
      return false

    $cache = String(fs.readFileSync($filepath))
    $match = /^(.*)\t(.*)\t/.exec($cache)

    $expires = new Date($match[2])
    #  Has the file expired? If so we'll delete it.
    return _gc_cache($cache_path, $filepath) unless Date.now() < $expires.getTime()

    #  Display the cache
    log_message('debug', "Cache file is current. Sending it to browser.")
    @enableProfiler true
    @display(null, $cache.replace($match[0], ''))
    return true

  #
  # Write a Cache File
  #
    # @param  [String]  HTML to cache
  # @return [Void]  #
  _write_cache: ($output) ->

    $path = @config.item('cache_path')

    $cache_path = if ($path is '') then APPPATH + 'cache/' else $path

    # can we create the dir if needed?
    if not is_dir($cache_path)
      try
        fs.mkdirSync $cache_path, DIR_READ_MODE
      catch $err
        log_message('error', "Unable to mkdir cache path: " + $cache_path)
        return

    # can we write to the file system?
    if not is_really_writable($cache_path)
      log_message('error', "Unable to write to cache path: " + $cache_path)
      return


    # when should this cache expire?
    $cache_rules = @config.item('cache_rules')
    $ttl = @_cache_expiration * 60000
    $uri = @uri.uriString()

    # check the uri against the rules
    for $pattern, $ttl of $cache_rules
      break if (new RegExp($pattern)).test($uri)

    return if $ttl <= 0 # no point in caching that

    # build the cache data
    $uri = @config.item('base_url') + @config.item('index_page') + $uri
    $filepath = $cache_path+md5($uri)
    $expires = new Date(Date.now() + $ttl)

    # queue up the cache and immediately return
    fs.writeFile $filepath, "#{$uri}\t#{$expires}\t#{$output}", ($err) ->
      if $err
        log_message('debug', "Error writing cache file %s: %s", $filepath, $err)
      else
        log_message('debug', "Cache file written: " + $filepath)
        # set a timer to clean the cache
        setTimeout _gc_cache, ($expires.getTime() - Date.now()), $cache_path, $filepath


  #
  # Clean the Cache
  #
  #   Deletes the cache file when it expires
  #
  # @param  [String]    # @param  [String]    # @return false
  #
  _gc_cache = ($cache_path, $filepath) ->

    if is_really_writable($cache_path)
      # delete from the file system
      fs.unlink $filepath, ($err) ->
        # and from memory
        delete require.cache[$filepath]
        log_message('debug', "Cache file has expired. File '%s' deleted", $filepath)

    return false




    # END Output class
module.exports = system.core.Output

# End of file Output.coffee
# Location: ./system/core/Output.coffee