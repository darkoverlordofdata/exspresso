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

class global.Exspresso_Controller

  _queue            : null  # async function queue
  BM                : null  # Expresso_Benchmark
  req               : null  # http request object
  res               : null  # http response object
  module            : null  # module parsed from the uri
  class             : null  # class parsed from the uri
  method            : null  # method parsed from the uri
  controller        : null  # controller (this)
  queue             : null  # access to view or add to _queue
  run               : null  # runs _queue
  redirect          : null  # http header redirect
  render            : null  # render output to the browser
  config            : null  # Expresso_Config
  uni               : null  # Expresso_Utf8
  server            : null  # Expresso_Server
  router            : null  # Expresso_Router
  lang              : null  # Expresso_Lang
  load              : null  # Expresso_Loader
  uri               : null  # Expresso_URI
  input             : null  # Expresso_Input
  output            : null  # Expresso_Output
  $_SERVER          : null  # fabricated table to mimic PHP
  $_GET             : null  # shortcut to @input.get()
  $_POST            : null  # shortcut to @input.post()
  $_COOKIE          : null  # shortcut to @input.cookie()

  #
  # Initialize Controller objects
  #
  # @access	public
  # @param  object    Benchmark object
  # @param	object    Request object
  # @param	object    Response object
  # @param	string    module name
  # @param	string    class name
  # @param	string    method name
  # @return	void
  #
  constructor: ($BM, $req, $res, $module, $class, $method) ->

    log_message 'debug', "Controller Class Initialized"
    $this = @

    defineProperties $this,
      _queue        : {enumerable: false, writeable: false, value: []}
      BM            : {enumerable: true,  writeable: false, value: $BM}
      req           : {enumerable: true,  writeable: false, value: $req}
      res           : {enumerable: true,  writeable: false, value: $res}
      module        : {enumerable: true,  writeable: false, value: $module}
      class         : {enumerable: true,  writeable: false, value: $class}
      method        : {enumerable: true,  writeable: false, value: $method}
      controller    : {enumerable: true,  writeable: false, value: $this}
      queue         : {enumerable: true,  writeable: false, value: $this.queue}
      run           : {enumerable: true,  writeable: false, value: $this.run}
      redirect      : {enumerable: true,  writeable: false, value: $this.redirect}
      render        : {enumerable: true,  writeable: false, value: $this.render}
      config        : {enumerable: true,  writeable: false, value: Exspresso.config}
      uni           : {enumerable: true,  writeable: false, value: Exspresso.uni}
      server        : {enumerable: true,  writeable: false, value: Exspresso.server}
      router        : {enumerable: true,  writeable: false, value: Exspresso.router}
      lang          : {enumerable: true,  writeable: false, value: Exspresso.lang}

    $BM.mark 'loading_time:_base_classes_start'
    defineProperties $this,
      load          : {enumerable: true,  writeable: false, value: load_new('Loader',  'core', $this)}
      uri           : {enumerable: true,  writeable: false, value: load_new('URI',     'core', $this)}
      input         : {enumerable: true,  writeable: false, value: load_new('Input',   'core', $this)}

    defineProperties $this,
      output        : {enumerable: true,  writeable: false, value: load_new('Output',  'core', $this)}
      $_SERVER      : {enumerable: true,  writeable: false, get: -> $this.req.server}
      $_GET         : {enumerable: true,  writeable: false, get: -> $this.req.query}
      $_POST        : {enumerable: true,  writeable: false, get: -> $this.req.body}
      $_COOKIE      : {enumerable: true,  writeable: false, get: -> $this.req.cookies}

    @load.initialize()  # do the autoloads
    $BM.mark 'loading_time:_base_classes_end'

    # From here forward, custom controllers
    # shall use the @load.method to load classes

  #
  # Render a view
  #
  # @access	public
  # @param	string
  # @param	object
  # @param	function
  # @return	void
  #
  render: ($view, $data = {}, $next) =>

    @res.render $view, create_mixin(@, $data), ($err, $html) =>

      return $next($err, $html) if $next?
      Exspresso.hooks._call_hook 'post_controller', @
      return show_error($err) if $err
      @res.send $html

  #
  # Async job queue for the controller
  #
  # @access	public
  # @param	function
  # @return	array
  #
  queue: ($fn) =>
    if $fn then @_queue.push($fn) else @_queue

  #
  # Run the functions in the queue
  #
  # @access	public
  # @param  array
  # @param	function
  # @return	void
  #
  run: ($queue, $next) =>

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
  redirect: ($url) =>
    Exspresso.hooks._call_hook 'post_controller', @
    @res.redirect $url



# END Exspresso_Controller class
module.exports = Exspresso_Controller
# End of file Controller.coffee
# Location: ./system/core/Controller.coffee