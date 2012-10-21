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

class exports.User extends require('./Table').Table

  name: 'user'
  columns:
    id:
      type:                 'int'
      primaryKey:           true
      autoIncrement:        true

    email:                  'string'    # User email address
    name:                   'string'    # User's name
    code:                   'string'    # encrypted password hash '$2a$10$Kx9nhYIRPNiUN1jvVIOsp..vEyapyRlc0AV/zqU9DVsedfydm68Rq'
    last_logon:             'datetime'  # last time user logged in
    created_on:             'datetime'  # account createtion date
    created_by:             'string'    # email of creator
    active:                 'int'       # 0 = inactive
    timezone:               'string'    # user's timezone (America/Los Angeles)
    language:               'string'    # default languange (EN)
    theme:                  'string'    # user preference
    path:                   'string'    # shown on successful logon





# End of file Hotel.coffee
# Location: ./Hotel.coffee