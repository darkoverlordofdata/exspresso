#+--------------------------------------------------------------------+
#| Booking.coffee
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
#	Booking - Main application
#
#
#
class exports.Booking extends require('../Table').Table

  name: 'booking'
  columns:
    id:
      type:                 'int'
      primaryKey:           true
      autoIncrement:        true

    username:               'string'
    hotel:                  'int'
    checkinDate:            'datetime'
    checkoutDate:           'datetime'
    creditCard:             'string'
    creditCardName:         'string'
    creditCardExpiryMonth:  'int'
    creditCardExpiryYear:   'int'
    smoking:                'string'
    beds:                   'int'
    amenities:              'string'
    state:                  'string'


# End of file Booking.coffee
# Location: ./Booking.coffee