#+--------------------------------------------------------------------+
#| Controller.coffee
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
#
# Exspresso Application Controller Class
#
# This class object is the super class for all controllers
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'helper')
{config_item, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

#
# ------------------------------------------------------
#  Instantiate the loader class and initialize
# ------------------------------------------------------
#

class CI_Controller

  constructor: ->

    # Assign all the class objects that were instantiated by the
    # bootstrap file (Exspresso.coffee) to local class variables
    # so that CI can run as one big super object.

    # for $var, $class of is_loaded()
    #   @[$var] = load_class($class)

    # @load = load_class('Loader', 'core')
    # @load.initialize()

    # Each controller object get's it's own
    # then we don't need a global get_instance reference
    @load = load_new('Loader', 'core').initialize(@)
    @config = load_class('Config', 'core')

    log_message 'debug', "Controller Class Initialized"


# END CI_Controller class

#Exspresso.CI_Controller = CI_Controller
register_class 'CI_Controller', CI_Controller
module.exports = CI_Controller

# End of file Controller.coffee
# Location: ./system/core/Controller.coffee