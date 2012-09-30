#+--------------------------------------------------------------------+
#| Model.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	Model Class
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, WEBROOT} = require(process.cwd() + '/index')
{array_merge, file_exists, is_dir, ltrim, realpath, rtrim, trim, ucfirst} = require(FCPATH + '/helper')
{Exspresso, config_item, get_config, get_instance, is_loaded, load_class, log_message} = require(BASEPATH + 'core/Common')

class CI_Model

  constructor: ->

    # Allows models to access CI's loaded classes using the same
    # syntax as controllers:
    $CI = get_instance()
    for $key, $member of $CI
      @[$key] = $member unless $key is 'constructor'


    log_message 'debug', "Model Class Initialized"


# END CI_Model class

Exspresso.CI_Model = CI_Model
module.exports = CI_Model

# End of file Model.coffee
# Location: .system/core//Model.coffee