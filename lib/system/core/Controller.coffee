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
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#
# Exspresso Application Controller Class
#
# This class object is the super class for all controllers
#
# @see http://coffeedoc.info/github/darkoverlordofdata/exspresso/master/ Controller Graph
#
class system.core.Controller extends system.core.Object

  #
  # @property [String] module name
  #
  module: ''
  #
  # @property [String] class name
  #
  class: ''
  #
  # @property [String] method name
  #
  method: ''
  #
  # @property [Object] http request object
  #
  req: null
  #
  # @property [Object] http response object
  #
  res: null
  #
  # @property [Object] array of cookies
  #
  $_COOKIE: null
  #
  # @property [Object] array of uploaded files
  #
  $_FILES: null
  #
  # @property [Object] http GET method parameters
  #
  $_GET: null
  #
  # @property [Object] http POST method parameters
  #
  $_POST: null
  #
  # @property [Object] array of server properties for the request
  #
  $_SERVER: null
  #
  # @property [Object] benchmark object
  #
  bm: null
  #
  # @property [Object] config object
  #
  config: null
  #
  # @property [Object] hooks object
  #
  hooks: null
  #
  # @property [Object] input object
  #
  input: null
  #
  # @property [Object] i18n object
  #
  i18n: null
  #
  # @property [Object] output object
  #
  output: null
  #
  # @property [Object] security object
  #
  security: null
  #
  # @property [Object] server object
  #
  server: null
  #
  # @property [Object] uri object
  #
  uri: null


  #
  # Initialize Controller objects
  #
  # @param  [system.core.Server]  server Server object
  # @param  [system.core.Benchmark]  benchmark Benchmark object
  # @param  [system.core.Hooks]  hooks Hooks object
  # @param  [system.core.Config  config Config object
  # @param  [system.core.URI]  uri URI object
  # @param  [system.core.Output]  output Output object
  # @param  [system.core.Security]  security Security object
  # @param  [system.core.Input]  input Input object
  # @param  [system.core.I18n]  i18n I18n object
  # @param  [Object]  req Request object
  # @param  [Object]  res Response object
  # @param  [String]  module Module name
  # @param  [String]  class Class name
  # @param  [String]  method Method name
  # @return [Void]
  #
  constructor: ($server, $bench, $hooks, $config, $uri, $output, $security, $input, $i18n, $req, $res, $module, $class, $method) ->

    @define
      # $uri segments
      module      : $module      # $uri module name
      class       : $class       # $uri class name
      method      : $method      # $uri method name

      # http objects
      req         : $req         # http Request object
      res         : $res         # http Response object
      $_COOKIE    : $req.cookies # http cookies
      $_FILES     : $req.files   # http dowmload files list
      $_GET       : $req.query   # http get values
      $_POST      : $req.body    # http post values
      $_SERVER    : $req.server  # server properties

      # methods
      redirect    : @redirect    # redirect url
      render      : @render      # render view

      # Assign all the class objects that were instantiated by the
      # bootstrap file (exspresso.coffee) to local class variables
      # so that Exspresso can run as one big super object.
      bm          : $bench       # system.core.Benchmark
      config      : $config      # system.core.Config
      hooks       : $hooks       # system.core.Hooks
      input       : $input       # system.core.Input
      i18n        : $i18n        # system.core.I18n
      output      : $output      # system.core.Output
      security    : $security    # system.core.Security
      server      : $server      # system.core.Server
      uri         : $uri         # system.core.URI

      # bootstrap the loader object into the controller:
      load: load_core('Loader', @)

    log_message 'debug', "Controller Class Initialized"

    @load.initialize()  # do the autoloads


  #
  # Render a view
  #
  # @param  [String]  view path to the view template
  # @param  [Object]  data hash of data to render with template
  # @param  [Function]  next  callback
  # @return [Void]
  #
  render: ($view, $data = {}, $next) ->

    @res.render $view, create_mixin(@, $data), ($err, $html) =>

      return $next($err, $html) if $next?
      return show_error($err) if $err
      @res.send $html

  #
  # Redirect to another url
  #
  # @param  [String]  url the url to redirect to
  # @return [Void]
  #
  redirect: ($url) ->
    @res.redirect $url



# END Controller class
module.exports = system.core.Controller
# End of file Controller.coffee
# Location: ./system/core/Controller.coffee