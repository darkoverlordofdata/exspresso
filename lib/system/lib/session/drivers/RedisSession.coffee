#+--------------------------------------------------------------------+
#| RedisSession.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#   Redis Session store driver
#
#
class system.lib.RedisSession extends require('connect-redis')(require('express'))

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

  #
  # Session Database setup
  #
  #   create session table
  #
    # @return [Void]  #
  create: () ->
    return


module.exports = system.lib.RedisSession
# End of file RedisSession.coffee
# Location: .system/lib/Session/drivers/RedisSession.coffee