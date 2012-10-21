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
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{file_exists, is_bool, parse_url, rawurldecode, substr} = require(FCPATH + 'lib')
{Exspresso, config_item, get_config, get_instance, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

express         = require('express')                    # Express 3.0 Framework
middleware      = require(BASEPATH + 'core/Middleware') # Exspresso Middleware module

#  ------------------------------------------------------------------------

#
# Exspresso Output Class
#
module.exports = class Exspresso.CI_Output

  final_output: {}
  cache_expiration: 0
  headers: {}
  mime_types: {}
  enable_profiler: false
  _zlib_oc: false
  _profiler_sections: {}
  parse_exec_vars: true#  whether or not to parse variables like {elapsed_time} and {memory_usage}

  constructor: ->

    log_message('debug', "Output Class Initialized")
    #  Get mime types for later
    if file_exists(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
      $mimes = require(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)

    else
      $mimes = require(APPPATH + 'config/mimes' + EXT)

    @mime_types = $mimes
    @_initialize()



  ## --------------------------------------------------------------------

  #
  # Initialize Output
  #
  #
  #   @access	private
  #   @return	void
  #
  _initialize: () ->

    $CI = get_instance()
    $app = $CI.app
    $config = $CI.config._config

    if $config.use_layouts
      $app.use require('express-partials')() # use 2.x layout style

    #
    # Expose folders
    #
    $app.set 'views', APPPATH + $config.views
    $app.use express.static(WEBROOT)

    #
    # Use Jade templating?
    #
    if $config.template is 'jade'
      $app.set 'view engine', 'jade'

    #
    # Use some other templating?
    #
    else
      consolidate = require('consolidate')    # for template support
      $app.engine $config.template, consolidate[$config.template]
      $app.set 'view engine', $config.view_ext

    #
    # CSS asset middleware
    #
    if $config.css is 'stylus'
      $app.use require('stylus').middleware(WEBROOT)

    else if $config.css is 'less'
      $app.use require('less-middleware')({ src: WEBROOT })

    #
    # Favorites icon
    #
    if $config.favicon?
      $app.use express.favicon(WEBROOT + $config.favicon)

    else
      $app.use express.favicon()

    #
    # Profiler
    #
    $app.use middleware.profiler(@)
    $app.use @_overrides()


    return

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
    return @final_output


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

    return @


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


    return @


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
    return @


  #  --------------------------------------------------------------------

  #
  # Set Content Type Header
  #
  # @access	public
  # @param	string	extension of the file we're outputting
  # @return	void
  #
  set_content_type : ($mime_type) ->
    return @


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
    return @


  #  --------------------------------------------------------------------

  #
  # Enable/disable Profiler
  #
  # @access	public
  # @param	bool
  # @return	void
  #
  enable_profiler : ($val = true) ->
    @enable_profiler = if (is_bool($val)) then $val else true

    return @


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


    return @


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

    return @



  # --------------------------------------------------------------------

  #
  # Override output instance methods
  #
  #   @returns function middlware callback
  #
  _overrides: ()->

    log_message 'debug',"Input middleware initialized"

    ($req, $res, $next) =>


      # --------------------------------------------------------------------
      @set_content_type = ($mime_type) ->

        $res.type $mime_type
        return @

      # --------------------------------------------------------------------
      @set_header = ($header, $replace = true) ->

        $pos = $header.indexOf(' ')
        $type = rtrim($header.substr(0, $pos), ': ')
        $value = trim($header.substr($pos))
        $res.set $type, $value

      # --------------------------------------------------------------------
      @set_status_header = ($code = 200, $text = '') ->

        $res.status($code)
        if $text isnt '' then $res.send $text
        return @

      $next()


# END CI_Output class

# End of file Output.coffee
# Location: ./system/core/Output.coffee