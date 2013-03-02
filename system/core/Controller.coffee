#+--------------------------------------------------------------------+
#| Controller.coffee
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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#
#
# Exspresso Application Controller Class
#
# This class object is the super class for all controllers
# Methods are bound with fat arrow ( => ) so that when called from
# child objects, they will run in the Controller context.
#

class global.Exspresso_Controller extends Exspresso_Object

  #
  # Initialize Controller objects
  #
  # @access	public
  # @param  object    Benchmark object
  # @param  object    Server object
  # @param  object    Hooks object
  # @param  object    Config object
  # @param  object    Utf8 object
  # @param  object    Lang object
  # @param  object    Router object
  # @param	object    Request object
  # @param	object    Response object
  # @param	string    module name
  # @param	string    class name
  # @param	string    method name
  # @return	void
  #
  constructor: ($SRV, $BM, $EXT, $CFG, $UNI, $URI, $RTR, $OUT, $SEC, $IN, $LANG, $req, $res, $module, $class, $method) ->

    log_message 'debug', "Controller Class Initialized"

    @properties

      # uri segments
      module      : $module             # uri module name
      class       : $class              # uri class name
      method      : $method             # uri method name

      # http objects
      req         : $req                # http Request object
      res         : $res                # http Response object
      $_COOKIE    : $req.cookies        # http cookies object
      $_FILES     : $req.files          # http download files object
      $_GET       : $req.query          # http get object
      $_POST      : $req.body           # http post object
      $_SERVER    : $req.server         # http server properties

      # methods
      queue       : @queue              # accessor method for @_queue
      run         : @run                # run the queue
      redirect    : @redirect           # redirect url
      render      : @render             # render view

      # properties
      _queue      : []                  # async queue

      # Assign all the class objects that were instantiated by the
      # bootstrap file (Exspresso.coffee) to local class variables
      # so that Exspresso can run as one big super object.

      server      : $SRV                # Exspresso_Server
      bm          : $BM                 # Exspresso_Benchmark
      hooks       : $EXT                # Exspresso_Hooks
      config      : $CFG                # Exspresso_Config
      uni         : $UNI                # Exspresso_Utf8
      uri         : $URI                # Exspresso_URI
      router      : $RTR                # Exspresso_Router
      output      : $OUT                # Exspresso_Output
      input       : $IN                 # Exspresso_Input
      security    : $SEC                # Exspresso_Security
      lang        : $LANG               # Exspresso_Lang


    @property load: load_mixin('Loader', 'core', @)
    @load.initialize()  # do the autoloads


  #
  # Render a view
  #
  # @access	public
  # @param	string
  # @param	object
  # @param	function
  # @return	void
  #
  render: ($view, $data = {}, $next) ->

    @res.render $view, create_mixin(@, $data), ($err, $html) =>

      return $next($err, $html) if $next?
      @hooks.callHook 'post_controller', @
      return show_error($err) if $err
      @res.send $html

  #
  # Async job queue for the controller
  #
  # @access	public
  # @param	function
  # @return	array
  #
  queue: ($fn) ->
    if $fn then @_queue.push($fn) else @_queue

  #
  # Run the functions in the queue
  #
  # @access	public
  # @param  array
  # @param	function
  # @return	void
  #
  run: ($queue, $next) ->

    if typeof $next isnt 'function'
      [$queue, $next] = [@_queue, $queue]

    $index = 0
    $iterate = ->

      $next (null) if $queue.length is 0
      #
      # call the function at index
      #
      $function = $queue[$index]
      $function ($err) ->
        return $next($err) if $err
        $index += 1
        if $index is $queue.length then $next null
        else $iterate()

    $iterate()

  #
  # Redirect to another url
  #
  # @access	public
  # @param	string
  # @return	void
  #
  redirect: ($url) ->
    @hooks.callHook 'post_controller', @
    @res.redirect $url



# END Exspresso_Controller class
module.exports = Exspresso_Controller
# End of file Controller.coffee
# Location: ./system/core/Controller.coffee