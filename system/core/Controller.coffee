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
# Methods are bound with fat arrow ( => ) so that they are selected
# for copying by the Exspresso_Object constructor. When called from
# child objects, they will run in the Controller context.
#

class global.Exspresso_Controller

  __hasOwnProperty    = Object.hasOwnProperty
  __defineProperties  = Object.defineProperties

  _module       : ''        # module name
  _class        : ''        # class name
  _method       : ''        # method name
  _queue        : null      # async queue

  BM            : null      # Benchmark object
  req           : null      # http Request object
  res           : null      # http Response object
  next          : null      # http next function

  @get $_GET    : -> @input.get()
  @get $_POST   : -> @input.post()
  @get $_SERVER : -> @input.server()
  @get $_COOKIE : -> @input.cookie()

  #
  # Initialize Controller objects
  #
  # @access	public
  # @param	object    Request object
  # @param	object    Response object
  # @param	function  Next middleware in stack
  # @param	string    module name
  # @param	string    class name
  # @param	string    method name
  # @return	void
  #
  constructor: ($req, $res, $next, $module, $class, $method) ->

    @_module = $module
    @_class = $class
    @_method = $method
    @_queue = []
    log_message 'debug', "Controller Class Initialized"

    #
    # ------------------------------------------------------
    #  Start the timer... tick tock tick tock...
    # ------------------------------------------------------
    #
    @BM = load_new('Benchmark', 'core', @)
    @BM.mark 'total_execution_time_start'

    @req = $req
    @res = $res
    @next = $next
    $res.Exspresso = $req.Exspresso = @

    # Assign all the class objects that were instantiated by the
    # bootstrap file (Exspresso.coffee) to local class variables
    # so that the Exspresso app can run as one big super object.

    @config = Exspresso.config
    @server = Exspresso.server
    @router = Exspresso.router
    @lang   = Exspresso.lang

    # The remaining class objects are unique for each Expresso
    # application controller

    @load   = load_new('Loader',  'core', @)
    @uri    = load_new('URI',     'core', @)
    @output = load_new('Output',  'core', @)
    @input  = load_new('Input',   'core', @)
    @load.initialize()  # do the autoloads

    # From here forward, custom controllers
    # shall use the @load.method to load classes



  #
  # Get the controller module name
  #
  # @access	public
  # @return	string
  #
  fetch_module: => @_module
  #
  # Get the controller class name
  #
  # @access	public
  # @return	string
  #
  fetch_class: => @_class
  #
  # Get the controller method name
  #
  # @access	public
  # @return	string
  #
  fetch_method: => @_method

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

    #
    # View Controller constructor
    #
    #   Wrap view data with controller methods
    #   This gives the view access to all methods and
    #   properties of the controller
    #
    # @access	private
    # @param	object
    #
    Controller = ($data) ->
      for $key, $obj of $data
        @[$key] = $obj
      return

    # Here's the magic -
    # expose the current controller via the prototype
    Controller:: = @

    @res.render $view, new Controller($data), ($err, $html) =>

      return $next($err, $html) if $next?
      return show_error($err) if $err
      @res.send $html

  #
  # Redirect to another url
  #
  # @access	public
  # @param	string
  # @return	void
  #
  redirect: ($url) =>
    @res.redirect $url

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
  #   @access	public
  #   @param  array
  #   @param	function
  #   @return	void
  #
  run: ($queue, $next) ->

    if typeof $next isnt 'function'
      [$queue, $next] = [@_queue, $queue]

    $index = 0
    $iterate = ->

      if $queue.length is 0 then $next null
      else
        #
        # call the function at index
        #
        $ctor = $queue[$index]
        $ctor ($err) ->
          if $err
            log_message 'debug', 'Controller::run'
            console.log $err

          $index += 1
          if $index is $queue.length then $next null
          else $iterate()

    $iterate()



# END Exspresso_Controller class
module.exports = Exspresso_Controller
# End of file Controller.coffee
# Location: ./system/core/Controller.coffee