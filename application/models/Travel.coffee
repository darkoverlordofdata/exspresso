#+--------------------------------------------------------------------+
#| travel.coffee
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
#	Travel Model Class
#
#
Sequelize       = require("sequelize")                  # Sequelize 1.5 ORM
url             = require('url')                        # Utilities for URL resolution and parsing.
{FCPATH}        = require(process.cwd() + '/index')     # '/var/www/Exspresso/'
{BASEPATH}      = require(FCPATH + '/index')            # '/var/www/Exspresso/system/'
{get_config}    = require(BASEPATH + 'core/Common')     # Loads the main config.coffee file.
{log_message}   = require(BASEPATH + 'core/Common')     # Error Logging Interface.
CI_Model        = require(BASEPATH + 'core/Model')      # Exspresso Model Base Class


class Travel extends CI_Model

  _sequelize:   null  # ORM Object Model
  _customer:    null  # Customer Table
  _hotel:       null  # Hotel Table
  _booking:     null  # Booking Table

  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  # Connect to and initialize database
  #
  # @return 	nothing
  #
  constructor: ->
    @initialize()

  ## --------------------------------------------------------------------

  Travel::__defineGetter__ 'Customer', ->
    return @_customer

  ## --------------------------------------------------------------------

  Travel::__defineGetter__ 'Hotel', ->
    return @_hotel

  ## --------------------------------------------------------------------

  Travel::__defineGetter__ 'Booking', ->
    return @_booking

  ## --------------------------------------------------------------------

  initialize: ->

    $config = get_config()
    $db     = url.parse $config.db_url

    if $db.auth?
      [$username, $password] = $db.auth.split(':')
    else
      [$username, $password] = ['','']

    $database = $db.pathname.substr(1)
    $hostname = $db.hostname
    $dialect  = $db.protocol.split(':')[0]
    $port     = $db.port

    @_sequelize = new Sequelize($database, $username, $password,
      host:     $hostname
      port:     $port
      dialect:  $dialect
      logging:  false
      storage:  $database
    )

    #
    # ------------------------------------------------------
    # Table options:
    # ------------------------------------------------------
    #
    $options =
      timestamps:             false
      freezeTableName:        true

    #
    # ------------------------------------------------------
    # TABLE Customer
    # ------------------------------------------------------
    #
    @_customer = @_sequelize.define "Customer",

      username:               Sequelize.STRING
      password:               Sequelize.STRING
      name:                   Sequelize.STRING
      $options

    #
    # ------------------------------------------------------
    # TABLE Hotel
    # ------------------------------------------------------
    #
    @_hotel = @_sequelize.define "Hotel",

      id:                     Sequelize.INTEGER
      price:                  Sequelize.INTEGER
      name:                   Sequelize.STRING
      address:                Sequelize.STRING
      city:                   Sequelize.STRING
      state:                  Sequelize.STRING
      zip:                    Sequelize.STRING
      country:                Sequelize.STRING
      $options

    #
    # ------------------------------------------------------
    # TABLE Booking
    # ------------------------------------------------------
    #
    @_booking = @_sequelize.define "Booking",

      username:               Sequelize.STRING
      hotel:                  Sequelize.INTEGER
      checkinDate:            Sequelize.DATE
      checkoutDate:           Sequelize.DATE
      creditCard:             Sequelize.STRING
      creditCardName:         Sequelize.STRING
      creditCardExpiryMonth:  Sequelize.INTEGER
      creditCardExpiryYear:   Sequelize.INTEGER
      smoking:                Sequelize.STRING
      beds:                   Sequelize.INTEGER
      amenities:              Sequelize.STRING
      state:                  Sequelize.STRING
      $options

    #
    # ------------------------------------------------------
    # Relationships
    # ------------------------------------------------------
    #
    @_booking.hasOne @_hotel
    #
    # initialize the database
    #
    @_sequelize.sync()


## --------------------------------------------------------------------

#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: .application/models/Travel.coffee