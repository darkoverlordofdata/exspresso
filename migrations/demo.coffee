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
{Booking} = require(APPPATH+'models/demo/Booking')
{Customer} = require(APPPATH+'models/demo/Customer')
{Hotel} = require(APPPATH+'models/demo/Hotel')

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

  new Customer($db).create ($err) ->
    if $err then return $callback($err)
    new Hotel($db).create ($err) ->
      if $err then return $callback($err)
      new Booking($db).create $callback

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

  new Customer($db).drop ($err) ->
    if $err then return $callback($err)
    new Hotel($db).drop ($err) ->
      if $err then return $callback($err)
      new Booking($db).drop $callback



# End of file demo.coffee
# Location: ./migrations/demo.coffee