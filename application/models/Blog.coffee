#+--------------------------------------------------------------------+
#| Blog.coffee
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
#	Blog - data base table
#
#
#

class exports.Blog extends require('./Table').Table

  name: 'blog'
  columns:
    id:
      type:                 'int'
      primaryKey:           true
      autoIncrement:        true

    author_id:              'int'       # User id of author
    category_id:            'int'       # blog category
    status:                 'int'       # 0 = draft, 1 = published
    created_on:             'datetime'  # create date
    updated_on:             'datetime'  # last change date
    title:                  'string'    # article title
    body:                   'text'      # article body






# End of file Blog.coffee
# Location: ./Blog.coffee