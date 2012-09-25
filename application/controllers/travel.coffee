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
#	travel - Main application
#
#

moment  = require("moment")

module.exports = class Travel extends exspresso.Controller

  constructor: ->

    super()
    @load.model 'travel', 'db'

  #
  # #into to hotel app
  #
  intro: ->
    @render "travel/intro"

  #
  # Search Hotels
  #
  search: ->

    query = @db.Booking.findAll(where: {state: "BOOKED"})
    query.on "success", (bookings) =>

      @render "travel/main",
        bookings: bookings

  #
  # Hotel Results
  #
  hotels: ->

    query = @db.Hotel.findAll(where: ["name like ?", "%" + @req.param("searchString") + "%"])
    query.on "success", (result) =>

      @render "travel/hotels",
        hotels: result

  #
  # View Hotel
  #
  hotel: (id) ->

    query = @db.Hotel.find(parseInt(id, 10))
    query.on "success", (result) =>

      @render "travel/detail",
        hotel: result

