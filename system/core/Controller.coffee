#+--------------------------------------------------------------------+
#| Controller.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
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
# @copyright  Copyright (c) 2012, Dark Overlord of Data
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
#
#
# ------------------------------------------------------
#  Instantiate the loader class and initialize
# ------------------------------------------------------
#
class global.Exspresso_Controller

  _req        : null      # http Request object
  _res        : null      # http Response object
  _module     : ''        # module
  _queue      : null      # async queue

  constructor: ($req, @_module) ->

    $req.res.CI = $req.CI = @
    @_req = $req
    @_res = $req.res

    # Assign all the class objects that were instantiated by the
    # bootstrap file (Exspresso.coffee) to local class variables
    # so that the Exspresso app can run as one big super object.

    for $var, $class of is_loaded()
      @[$var] = load_class($class)

    @session = Exspresso.session

    # from this point on, each controller has it's own loader
    # so that callbacks will run in the controller context
    @load = load_new('Loader', 'core')
    @load.initialize(@) # NO AUTOLOAD!!!
    @_queue = []

    log_message 'debug', "Controller Class Initialized"

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
    $data.CI = @
    @_res.render $view, $data, ($err, $html) =>

      if $callback? then $callback $err, $html
      else
        if $err then show_error $err
        else
          @_res.send $html

  # --------------------------------------------------------------------

  #
  # Redirect to another url
  #
  # @access	public
  # @param	string
  # @return	void
  #
  redirect: ($url) =>
    @_res.redirect $url


# END Exspresso_Controller class
module.exports = Exspresso_Controller
# End of file Controller.coffee
# Location: ./system/core/Controller.coffee