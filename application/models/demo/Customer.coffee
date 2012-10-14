#+--------------------------------------------------------------------+
#| Customer.coffee
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
#	Customer - Main application
#
#
#
class exports.Customer extends require('../Table').Table

  name: 'customer'
  columns:
    id:
      type:                 'int'
      primaryKey:           true
      autoIncrement:        true

    username:               'string'
    password:               'string'
    name:                   'string'


# End of file Customer.coffee
# Location: ./Customer.coffee