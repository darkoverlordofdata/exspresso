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

  cache_override:

    function: 'displayCache'
    filename: 'PageCache.coffee'
    filepath: 'hooks'

