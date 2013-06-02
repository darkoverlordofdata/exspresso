#+--------------------------------------------------------------------+
#| PageCache.coffee
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
#	Page Cache Hooks using REDIS
#

fs = require('fs')
#
# Initialize the redis client
#
client = do ->
  try
    redis = require('redis')
    $url = process.env.REDISCLOUD_URL || process.env.REDISTOGO_URL || 'redis://localhost:6379'
    client = redis.createClient(parse_url($url).port, parse_url($url).host, no_ready_check: true)
    client.auth parse_url($url).pass
    client

  catch $e
    log_message 'error', 'Unable to connect to REDIS'
    false

#
# Override Output Write Cache
#
# @param  [String]  output  HTML to cache
# @return [Void]
#
system.core.Output::_write_cache = ($output) ->

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
  client.set $uri, $output


module.exports =

  #
  # Display a Cached Page
  #
  # @param  [Object]  config  params from hook config
  # @param  [Object]  output  the output object
  # @param  [Function]  next  the async callback
  # @return [Void]
  #
  displayCache: ($config, $output, $next) ->

    log_message 'debug', 'cache_override Hook Initialized'
    return $next(null, false) if client is false

    $cache_path = if ($output.config.item('cache_path') is '') then APPPATH + 'cache/' else $output.config.item('cache_path')

    #  Build the file path.
    $uri = $output.config.item('base_url') + $output.config.item('index_page') + $output.uri.uriString()

    client.get $uri, ($err, $value) =>
      return $next(null, false) if $err
      return $next(null, false) if $value is null

      $next(null, $output.display(null, $value.toString()))




