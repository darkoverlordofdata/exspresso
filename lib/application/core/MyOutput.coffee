#+--------------------------------------------------------------------+
#| MyOutput.coffee
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
#	Class application.core.MyOutput
#
#   Customizations to support Redis page caching
#   Used for AppFog, as the file system isn't persistant
#
module.exports = class application.core.MyOutput extends system.core.Output

  #
  # @property [Object] Redis client
  #
  redis: null

  #
  # Set the properties
  #
  # @param  [system.core.Exspresso] controller  the system controller
  #
  constructor: ($args...) ->
    super $args...

    log_message 'debug', 'MyOutput Initialized'
    #
    # Initialize the redis client
    #
    try
      redis = require('redis')
      $url = process.env.REDISCLOUD_URL || process.env.REDISTOGO_URL || 'redis://localhost:6379'
      @redis = redis.createClient(parse_url($url).port, parse_url($url).host, no_ready_check: true)
      @redis.auth parse_url($url).pass

    catch $err
      log_message 'error', 'Unable to connect to REDIS: %s', $err.stack


  #
  # Override Write Cache
  #
  # @param  [String]  output  HTML to cache
  # @return [Void]
  #
  _write_cache: ($output) ->

    # when should this cache expire?
    $cache_rules = @config.item('cache_rules')
    $ttl = @_cache_expiration * 60000
    $uri = @uri.uriString()

    # check the uri against the rules
    for $pattern, $ttl of $cache_rules
      break if (new RegExp($pattern)).test($uri)

    return if $ttl <= 0 # no point in caching that

    # build the cache data
    $uri = @config.item('base_url') + @config.item('index_page') + $uri
    @redis.set $uri, $output
    @redis.expire $uri, $ttl*60 # seconds per minute


