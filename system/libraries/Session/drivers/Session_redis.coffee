#+--------------------------------------------------------------------+
#| Session_redis.coffee
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
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012, Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#   Redis Session store driver
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
# End of file Session_redis.coffee
# Location: ./system/libraries/Session/drivers/Session_redis.coffee