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
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, WEBROOT} = require(process.cwd() + '/index')
{array_merge, file_exists, is_dir, ltrim, realpath, rtrim, trim, ucfirst} = require(FCPATH + '/helper')
{Exspresso, config_item, get_config, get_instance, is_loaded, load_class, log_message} = require(BASEPATH + 'core/Common')

#
# ------------------------------------------------------
#  Instantiate the loader class and initialize
# ------------------------------------------------------
#
$self = instance: null


class CI_Controller

  constructor: ->

    $self.instance = @

    # Assign all the class objects that were instantiated by the
    # bootstrap file (Exspresso.coffee) to local class variables
    # so that CI can run as one big super object.

    for $var, $class of is_loaded()
      @[$var] = load_class($class)

    @load = load_class('Loader', 'core')


    log_message 'debug', "Controller Class Initialized"

CI_Controller.get_instance = ()  ->

  return $self.instance

# END CI_Controller class

Exspresso.CI_Controller = CI_Controller
module.exports = CI_Controller

# End of file Controller.coffee
# Location: ./system/core/Controller.coffee