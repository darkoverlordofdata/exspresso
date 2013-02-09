#+--------------------------------------------------------------------+
#| test.coffee
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
#	test - Main application
#
#
#
class class1

  @load = ->
    console.log "LOAD"
    console.log @name

class class2 extends class1

class1.load()
class2.load()

# End of file test.coffee
# Location: ./test.coffee