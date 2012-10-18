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
#	Input
#
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{parse_url, rawurldecode, substr} = require(FCPATH + 'lib')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

express         = require('express')                    # Express 3.0 Framework

#  ------------------------------------------------------------------------

#
# Exspresso Input Class
#
module.exports = class Exspresso.CI_Input

  constructor: ->

    @_initialize()

    log_message('debug', "Input Class Initialized")


  ## --------------------------------------------------------------------

  #
  # Initialize Input
  #
  #
  #   @access	private
  #   @return	void
  #
  _initialize: () ->

    $app      = require(BASEPATH + 'core/Exspresso').app
    $config   = require(BASEPATH + 'core/Exspresso').config._config

    $app.use express.bodyParser()
    $app.use express.methodOverride()
    return



# END CI_Input class

# End of file Input.coffee
# Location: ./system/core/Input.coffee