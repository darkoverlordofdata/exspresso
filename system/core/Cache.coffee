#+--------------------------------------------------------------------+
#| Cache.coffee
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
#	Cache
#
#
#
cache           = require('connect-cache')              # Caching system for Connect

#  ------------------------------------------------------------------------

#
# Exspresso Cache Class
#
module.exports = class global.CI_Cache

  constructor: ->

    @_initialize()

    log_message('debug', "Cache Class Initialized")


  ## --------------------------------------------------------------------

  #
  # Initialize cache
  #
  #
  #   @access	private
  #   @return	void
  #
  _initialize: () ->

    $app      = require(BASEPATH + 'core/Exspresso').app
    $config   = require(BASEPATH + 'core/Exspresso').config.config

    if $config.cache

      switch $app.get('env')
      #
      # Per environment caching
      #

        when 'development'
        #
        #   Dev environment
        #
          $app.use cache
            rules: [{regex: /.*/, ttl: 3600000}]
            loopback: 'localhost:' + $config.port

        when 'test'
        #
        #   Unit test environment
        #
          $app.use cache
            rules: [{regex: /.*/, ttl: 3600000}]

        when 'production'
        #
        #   Production environment
        #
          $app.use cache
            rules: [{regex: /.*/, ttl: 3600000}]

        else
        #
        #   Unknown environment
        #
          $app.use cache
            rules: [{regex: /.*/, ttl: 3600000}]
    return



# END CI_Cache class

# End of file Cache.coffee
# Location: ./system/core/Cache.coffee