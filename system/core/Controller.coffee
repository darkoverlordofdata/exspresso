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
#
# Exspresso Application Controller Class
#
# This class object is the super class for all controllers
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

#
# ------------------------------------------------------
#  Instantiate the loader class and initialize
# ------------------------------------------------------
#

module.exports = class Exspresso.CI_Controller

  constructor: ->

    # Assign all the class objects that were instantiated by the
    # bootstrap file (Exspresso.coffee) to local class variables
    # so that CI can run as one big super object.

    for $var, $class of is_loaded()
      @[$var] = load_class($class) unless $class is 'Controller'

    # each controller has it's own loader
    # so that callbacks run in the controller context
    @load = load_new('Loader', 'core')
    @load.initialize(@)

    log_message 'debug', "Controller Class Initialized"


# END CI_Controller class

# End of file Controller.coffee
# Location: ./system/core/Controller.coffee