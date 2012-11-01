#+--------------------------------------------------------------------+
#| Category.coffee
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
#	Category - data base table
#
#
#

class exports.Category extends require('./Table').Table

  name: 'category'
  columns:
    id:
      type:                 'int'
      primaryKey:           true
      autoIncrement:        true

    name:                   'string'    # category name

# End of file Category.coffee
# Location: ./Category.coffee