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
#

class global.Exspresso_Controller

  _module     : ''        # module
  _queue      : null      # async queue
  BM          : null      # Benchmark object
  req         : null      # http Request object
  res         : null      # http Response object
  next        : null      # http next function

  constructor: ($req, $res, $next, $module) ->

    @_module = $module
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

    # the remaining class objects are unique for each Expresso
    # application controller

    @uri    = load_new('URI', 'core', @)
    @output = load_new('Output', 'core', @)
    @input  = load_new('Input', 'core', @)
    Object.defineProperties @,
      $_GET     : get: -> return @input.get()
      $_POST    : get: -> return @input.post()
      $_SERVER  : get: -> return @input.server()
      $_COOKIE  : get: -> return @input.cookie()

    @load   = load_new('Loader', 'core', @)
    @load.initialize()



  queue: ($fn) ->
    if $fn then @_queue.push($fn) else @_queue

  # --------------------------------------------------------------------

  #
  # Render a view
  #
  # @access	public
  # @param	string
  # @param	object
  # @param	function
  # @return	void
  #
  render: ($view, $data = {}, $callback) =>
    $data.Exspresso = @
    @res.render $view, $data, ($err, $html) =>

      if $callback? then $callback $err, $html
      else
        if $err then show_error $err
        else
          @res.send $html

  # --------------------------------------------------------------------

  #
  # Redirect to another url
  #
  # @access	public
  # @param	string
  # @return	void
  #
  redirect: ($url) =>
    @res.redirect $url


# END Exspresso_Controller class
module.exports = Exspresso_Controller
# End of file Controller.coffee
# Location: ./system/core/Controller.coffee