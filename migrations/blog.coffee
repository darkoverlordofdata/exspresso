#+--------------------------------------------------------------------+
#| create-blog-tables.coffee
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
#	blog - Create the blog database tables
#
#
#
APPPATH = process.cwd()+'/application/'
{Blog} = require(APPPATH+'models/Blog')
console.log "BLOG"

## --------------------------------------------------------------------

#
# UP
#
#   Create the blog tables
#
#   @access	public
#   @param object database
#   @param function migration callback
#   @return	void
#
exports.up = ($db, $callback) ->

  new Blog($db).create ($err) ->
    if $err then return $callback $err
    new Blog($db).insert require('./data/Blog.json'), ($err) ->
      if $err then $callback $err
      $callback()

## --------------------------------------------------------------------

#
# DOWN
#
#   Drop the blog tables
#
#   @access	public
#   @param object database
#   @param function migration callback
#   @return	void
#
exports.down = ($db, $callback) ->

  new Blog($db).drop ($err) ->
    if $err then return $callback($err)
    $callback()



# End of file blog.coffee
# Location: ./migrations/blog.coffee