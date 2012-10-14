#+--------------------------------------------------------------------+
#| populate-demo-tables.coffee
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
#	demo-data - Populates the demo data
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
#   Initialize the data
#
#   @access	public
#   @param object database
#   @param function migration callback
#   @return	void
#
exports.up = ($db, $callback) ->

  new Customer($db).insert require('./data/Customer.json'), ($err) ->
    if $err then $callback $err

  new Hotel($db).insert require('./data/Hotel.json'), ($err) ->
    if $err then $callback $err

  $callback()

## --------------------------------------------------------------------

#
# DOWN
#
#   this does nothing
#
#   @access	public
#   @param object database
#   @param function migration callback
#   @return	void
#
exports.down = ($db, $callback) ->

  $callback()

# End of file demo-data.coffee
# Location: ./migrations/demo-data.coffee