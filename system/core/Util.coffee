#+--------------------------------------------------------------------+
#| globals.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Darklite is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	util
#
#
#
fs = require('fs')

exspresso.util =

  imports : (path) ->

    for key, item of require(path)
      @[key] = item

  define : (name, value, scope = global) ->

    Object.defineProperty scope, name,
      'value':			value
      'enumerable': true
      'writable':		false


  is_dir : (path) ->

    try
      stats = fs.lstatSync(path)
      b = stats.isDirectory()
    catch ex
      b = false
    finally
      return b

  realpath : (path) ->

    if fs.existsSync(path)
      return fs.realpathSync(path)
    else
      return false

  file_exists : (path) ->

    return fs.existsSync(path)



# End of file globals.coffee
# Location: ./globals.coffee