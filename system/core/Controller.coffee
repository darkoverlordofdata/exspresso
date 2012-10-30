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
#
# ------------------------------------------------------
#  Instantiate the loader class and initialize
# ------------------------------------------------------
#
class global.CI_Controller

  constructor: ->

    # Assign all the class objects that were instantiated by the
    # bootstrap file (Exspresso.coffee) to local class variables
    # so that CI can run as one big super object.

    for $var, $class of is_loaded()
      @[$var] = load_class($class)

    @session = get_instance().session

    # from this point on, each controller has it's own loader
    # so that callbacks will run in the controller context
    @load = load_new('Loader', 'core')
    @load.initialize(@) # NO AUTOLOAD!!!


    log_message 'debug', "Controller Class Initialized"


CI_Controller.get_instance = () -> require(BASEPATH + 'core/Exspresso')


# END CI_Controller class
module.exports = CI_Controller
# End of file Controller.coffee
# Location: ./system/core/Controller.coffee