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
#	travel model
#
#
#
# *  Database:
# *
# *  $ mysqladmin -u root -p create tagsobe
# *  $ mysql -u root -p tagsobe -e "grant usage on *.* to tagsobe@localhost identified by 'tagsobe'"
# *  $ mysql -u root -p tagsobe -e "grant all privileges on tagsobe.* to tagsobe@localhost"
# *
# *  $ mysql -u tagsobe -ptagsobe tagsobe < ./import.sql
# *
#
#

Sequelize = require("sequelize")

#
# Connect to database
#
sequelize = new Sequelize("tagsobe", "tagsobe", "tagsobe",
  host: "localhost"
  logging: false
)

#
# Table options:
#
options =
  timestamps:             false
  freezeTableName:        true

#
# TABLE Customer
#
Customer = sequelize.define "Customer"

  username:               Sequelize.STRING
  password:               Sequelize.STRING
  name:                   Sequelize.STRING
  options

#
# TABLE Hotel
#
Hotel = sequelize.define "Hotel"

  id:                     Sequelize.INTEGER
  price:                  Sequelize.INTEGER
  name:                   Sequelize.STRING
  address:                Sequelize.STRING
  city:                   Sequelize.STRING
  state:                  Sequelize.STRING
  zip:                    Sequelize.STRING
  country:                Sequelize.STRING
  options

#
# TABLE Booking
#
Booking = sequelize.define "Booking"

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
  options

#
# Relationships
#
Booking.hasOne Hotel
#
# initialize the database
#
sequelize.sync()
#
# Export Objects:
#
module.exports = db =
  Booking:    Booking
  Customer:   Customer
  Hotel:      Hotel


