#+--------------------------------------------------------------------+
#| postgres.coffee
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
#	postgres driver for sessions
#
#  ------------------------------------------------------------------------

#
# Redis Session store driver
#
#
class Exspresso_Session_redis extends require('connect-redis')(require('express'))

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

  #  --------------------------------------------------------------------

  #
  # Session Database setup
  #
  #   create session table
  #
  # @access	public
  # @return	void
  #
  create: () ->
    return


module.exports = Exspresso_Session_redis
# End of file postgres.coffee
# Location: ./system/libraries/Session/postgres.coffee