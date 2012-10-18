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
{parse_url, rawurldecode, substr} = require(FCPATH + 'lib')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

express         = require('express')                    # Express 3.0 Framework
middleware      = require(BASEPATH + 'core/Middleware') # Exspresso Middleware module

#  ------------------------------------------------------------------------

#
# Exspresso Output Class
#
module.exports = class Exspresso.CI_Output

  constructor: ->

    @_initialize()

    log_message('debug', "Output Class Initialized")


  ## --------------------------------------------------------------------

  #
  # Initialize Output
  #
  #
  #   @access	private
  #   @return	void
  #
  _initialize: () ->

    $app      = require(BASEPATH + 'core/Exspresso').app
    $config   = require(BASEPATH + 'core/Exspresso').config._config

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
    # Flash messaging
    #
    $app.use require('connect-flash')()
    #
    # Run stats
    #
    $app.use middleware.profiler()

    return

# END CI_Output class

# End of file Output.coffee
# Location: ./system/core/Output.coffee