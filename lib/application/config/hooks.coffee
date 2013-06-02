#
#
#| -------------------------------------------------------------------------
#| Hooks
#| -------------------------------------------------------------------------
#| This file lets you define "hooks" to extend Exspresso without hacking the core
#| files.
#|
#|
#
module.exports =

  #
  # Override standard, file system based caching
  # with Redis caching
  #
  cache_override:

    function: 'displayCache'
    filename: 'PageCacheRedis.coffee'
    filepath: 'hooks'

