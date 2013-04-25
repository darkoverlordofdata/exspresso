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
#   Redis Session store driver
#
#
module.exports = class system.lib.RedisSession extends require('connect-redis')(require('express'))

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


