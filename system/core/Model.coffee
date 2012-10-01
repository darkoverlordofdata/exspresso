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
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'helper')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')

class CI_Model

  ## --------------------------------------------------------------------

  #
  # Model Constructor
  #
  #
  # @access	public
  # @param	object	$CI Controller Instance mixin
  # @return	void
  #
  constructor: ($CI = {}) ->

    # Allows models to access CI's loaded classes using the same
    # syntax as controllers:
    for $key, $member of $CI
      @[$key] = $member

    log_message 'debug', "Model Class Initialized"



# END CI_Model class

Exspresso.CI_Model = CI_Model
module.exports = CI_Model

# End of file Model.coffee
# Location: .system/core//Model.coffee