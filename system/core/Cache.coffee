#+--------------------------------------------------------------------+
#| Cache.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Cache Class
#
class global.Exspresso_Cache

  cache           = require('connect-cache')              # Caching system for Connect

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



# END Exspresso_Cache class
module.exports = Exspresso_Cache

# End of file Cache.coffee
# Location: ./system/core/Cache.coffee