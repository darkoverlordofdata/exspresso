#+--------------------------------------------------------------------+
#| create-demo-tables.coffee
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
#	demo - Create the demo database tables
#
#
#
APPPATH = process.cwd()+'/application/'
{User} = require(APPPATH+'models/demo/User')

## --------------------------------------------------------------------

#
# UP
#
#   Create the demo tables
#
#   @access	public
#   @param object database
#   @param function migration callback
#   @return	void
#
exports.up = ($db, $callback) ->

  new User($db).create ($err) ->
    if $err then return $callback($err)
    new User($db).insert require('./data/User.json'), ($err) ->
      if $err then $callback $err

## --------------------------------------------------------------------

#
# DOWN
#
#   Drop the demo tables
#
#   @access	public
#   @param object database
#   @param function migration callback
#   @return	void
#
exports.down = ($db, $callback) ->

  new User($db).drop ($err) ->
    if $err then return $callback($err)



# End of file demo.coffee
# Location: ./migrations/demo.coffee