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
#  ------------------------------------------------------------------------

#
# Redis Session store driver
#
#
class CI_Session_redis extends require('connect-redis')(require('express'))

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


module.exports = CI_Session_redis
# End of file postgres.coffee
# Location: ./system/libraries/Session/postgres.coffee