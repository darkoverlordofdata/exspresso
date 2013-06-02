#+--------------------------------------------------------------------+
#| PageCacheRedis.coffee
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
#	Page Cache Hook using REDIS
#

#
# Initialize the redis client
#
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
    return $next(null, false) if $output.redis is null

    log_message 'debug', 'cache_override Hook Initialized'

    #  Build the file path.
    $uri = $output.config.item('base_url') + $output.config.item('index_page') + $output.uri.uriString()

    $output.redis.get $uri, ($err, $value) =>
      return $next(null, false) if $err
      return $next(null, false) if $value is null

      $next null, $output.display(null, $value.toString())




