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

class system.core.Controller

  #
  # Initialize Controller objects
  #
  # @access	public
  # @param  object    Server object
  # @param  object    Benchmark object
  # @param  object    Hooks object
  # @param  object    Config object
  # @param  object    URI object
  # @param  object    Output object
  # @param  object    Security object
  # @param  object    Input object
  # @param  object    I18n object
  # @param	object    Request object
  # @param	object    Response object
  # @param	string    module name
  # @param	string    class name
  # @param	string    method name
  # @return	void
  #
  constructor: ($server, $bench, $hooks, $config, $uri, $output, $security, $input, $i18n, $req, $res, $module, $class, $method) ->

    defineProperties @,

      # $uri segments
      module      : {writeable: false, enumerable: true, value: $module}      # $uri module name
      class       : {writeable: false, enumerable: true, value: $class}       # $uri class name
      method      : {writeable: false, enumerable: true, value: $method}      # $uri method name

      # http objects
      req         : {writeable: false, enumerable: true, value: $req}         # http Request object
      res         : {writeable: false, enumerable: true, value: $res}         # http Response object
      $_COOKIE    : {writeable: false, enumerable: true, value: $req.cookies} # http cookies
      $_FILES     : {writeable: false, enumerable: true, value: $req.files}   # http dowmload files list
      $_GET       : {writeable: false, enumerable: true, value: $req.query}   # http get values
      $_POST      : {writeable: false, enumerable: true, value: $req.body}    # http post values
      $_SERVER    : {writeable: false, enumerable: true, value: $req.server}  # server properties

      # methods
      queue       : {writeable: false, enumerable: true, value: @queue}       # accessor method for @_queue
      redirect    : {writeable: false, enumerable: true, value: @redirect}    # redirect url
      render      : {writeable: false, enumerable: true, value: @render}      # render view
      run         : {writeable: false, enumerable: true, value: @run}         # run the queue

      # properties
      _queue      : {writeable: false, enumerable: false, value: []}          # async queue

      # Assign all the class objects that were instantiated by the
      # bootstrap file (Exspresso.coffee) to local class variables
      # so that Exspresso can run as one big super object.
      bm          : {writeable: false, enumerable: true, value: $bench}       # system.core.Benchmark
      config      : {writeable: false, enumerable: true, value: $config}      # system.core.Config
      hooks       : {writeable: false, enumerable: true, value: $hooks}       # system.core.Hooks
      input       : {writeable: false, enumerable: true, value: $input}       # system.core.Input
      i18n        : {writeable: false, enumerable: true, value: $i18n}        # system.core.I18n
      output      : {writeable: false, enumerable: true, value: $output}      # system.core.Output
      security    : {writeable: false, enumerable: true, value: $security}    # system.core.Security
      server      : {writeable: false, enumerable: true, value: $server}      # system.core.Server
      uri         : {writeable: false, enumerable: true, value: $uri}         # system.core.URI

      # bootstrap the loader object into the controller:
      load        : {writeable: false, enumerable: true, value: load_core('Loader', @)}

    log_message 'debug', "Controller Class Initialized"

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

    $inputdex = 0
    $iterate = ->

      $next (null) if $queue.length is 0
      #
      # call the function at index
      #
      $function = $queue[$inputdex]
      $function ($err) ->
        return $next($err) if $err
        $inputdex += 1
        if $inputdex is $queue.length then $next null
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



# END Controller class
module.exports = system.core.Controller
# End of file Controller.coffee
# Location: ./system/core/Controller.coffee