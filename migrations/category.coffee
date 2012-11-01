#+--------------------------------------------------------------------+
#| create-category-tables.coffee
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
#	category - Create the category database tables
#
#
#
APPPATH = process.cwd()+'/application/'
{Category} = require(APPPATH+'models/Category')
## --------------------------------------------------------------------

#
# UP
#
#   Create the category tables
#
#   @access	public
#   @param object database
#   @param function migration callback
#   @return	void
#
exports.up = ($db, $callback) ->

  new Category($db).create ($err) ->
    if $err then return $callback $err
    new Category($db).insert require('./data/Category.json'), ($err) ->
      if $err then $callback $err
      $callback()

## --------------------------------------------------------------------

#
# DOWN
#
#   Drop the category tables
#
#   @access	public
#   @param object database
#   @param function migration callback
#   @return	void
#
exports.down = ($db, $callback) ->

  new Category($db).drop ($err) ->
    if $err then return $callback($err)
    $callback()



# End of file category.coffee
# Location: ./migrations/category.coffee