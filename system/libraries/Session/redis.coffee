#+--------------------------------------------------------------------+
#| postgres.coffee
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
#	postgres driver for sessions
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{file_exists, parse_url}  = require(FCPATH + 'lib')
{Exspresso, config_item, get_class, get_config, get_instance, is_loaded, load_class, load_new, load_object, log_message, show_error, register_class} = require(BASEPATH + 'core/Common')


#  ------------------------------------------------------------------------

#
# Redis Session store driver
#
#
class Session_redis extends require('connect-redis')(require('express'))

  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  #   If needed, create the table and cleanup jobs
  #
  # @return 	nothing
  #
  constructor: ($parent) ->


    $dns = parse_url($parent.sess_use_database)

    super
      host: $dns.hostname
      port: $dns.port
      pass: $dns.password


module.exports = Session_redis
# End of file postgres.coffee
# Location: ./system/libraries/Session/postgres.coffee