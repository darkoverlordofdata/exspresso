#+--------------------------------------------------------------------+
#| Hotel.coffee
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
#	Hotel - Main application
#
#
#
class exports.Hotel extends require('../Table').Table

  name: 'hotel'
  columns:
    id:
      type:                 'int'
      primaryKey:           true
      autoIncrement:        true

    price:                  'int'
    name:                   'string'
    address:                'string'
    city:                   'string'
    state:                  'string'
    zip:                    'string'
    country:                'string'



# End of file Hotel.coffee
# Location: ./Hotel.coffee