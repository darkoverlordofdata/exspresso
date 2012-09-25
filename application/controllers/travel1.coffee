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
moment = require("moment")

#
# Travel Controller
#
#   @param  {object}  Server Application
#   @param  {object}  DB Model
#
module.exports = exports = (app, config, db) ->

  #
  # Login
  #
  app.get "/login", (req, res) ->
    res.render "travel/login",
      url: req.param("url")

  #
  # Logout
  #
  app.get "/logout", (req, res) ->
    req.session.destroy()
    res.redirect "/search"

  #
  # Do the authenthication
  #
  app.post "/authenticate", (req, res) ->
    query = db.Customer.find(where:
      username: req.param("username")
    )
    query.on "success", (user) ->
      if user?
        req.session.user = user.username
        res.redirect encodeURI(req.param("url"))

  #
  # Authentication middleware
  #
  auth = ->
    return (req, res, next) ->
      if req.session.user?
        next()
      else
        res.redirect("/login?url=" + encodeURI(req.url))


  #
  # #into to hotel app
  #
  app.get "/intro", (req, res) ->
    res.render "travel/intro"

  #
  # Search Hotels
  #
  app.all "/search", (req, res) ->
    query = db.Booking.findAll(where: {state: "BOOKED"})
    query.on "success", (bookings) ->
      res.render "travel/main",
        bookings: bookings

  #
  # Hotel Results
  #
  app.post "/hotels", (req, res) ->
    query = db.Hotel.findAll(where: ["name like ?", "%" + req.param("searchString") + "%"])
    query.on "success", (result) ->
      res.render "travel/hotels",
        hotels: result

  #
  # View Hotel
  #
  app.get "/hotel/:id", (req, res) ->
    query = db.Hotel.find(parseInt(req.param('id')))
    query.on "success", (result) ->
      res.render "travel/detail",
        hotel: result

  #
  # Book Hotel
  #
  app.all "/booking", auth(), (req, res) ->

    if req.body.cancel? then res.redirect "/search"

    query = db.Hotel.find(parseInt(req.param("hotelId")))
    query.on "success", (result) ->
      res.render "travel/booking",
        hotel: result

  #
  # Confirm
  #
  app.post "/confirm", auth(), (req, res) ->
    if req.body.cancel? then res.redirect "/search"
    query = db.Hotel.find(parseInt(req.body.hotelId))
    query.on "success", (result) ->
      booking = db.Booking.build(
        username: req.session.user
        hotel: result.id
        checkinDate: moment(req.body.checkinDate, "MM-DD-YYYY")
        checkoutDate: moment(req.body.checkoutDate, "MM-DD-YYYY")
        creditCard: req.body.creditCard
        creditCardName: req.body.creditCardName
        creditCardExpiryMonth: parseInt(req.body.creditCardExpiryMonth)
        creditCardExpiryYear: parseInt(req.body.creditCardExpiryYear)
        smoking: req.body.smoking
        beds: 1
        amenities: req.body.amenities
        state: "CREATED"
      )
      booking.save().on("success", ->
        booking.numberOfNights = (booking.checkoutDate - booking.checkinDate) / (24 * 60 * 60 * 1000)
        booking.totalPayment = booking.numberOfNights * result.price
        res.render "travel/confirm",
          hotel: result
          booking: booking

      ).on "failure", (error) ->
        console.log error
        res.send error, 500

  #
  # submit - revise - cancel
  #
  app.post "/book", auth(), (req, res) ->
    query = db.Booking.find(parseInt(req.body.bookingId))
    query.on "success", (booking) ->
      if req.body.confirm?
        booking.state = "BOOKED"
        booking.save().on("success", ->
          res.redirect "/search"
        ).on "failure", (error) ->
          console.log error
          res.send error, 500

      else if req.body.cancel?
        booking.state = "CANCELLED"
        booking.save().on("success", ->
          res.redirect "/search"
        ).on "failure", (error) ->
          console.log error
          res.send error, 500

      else if req.body.revise?
        db.Hotel.find(booking.hotel).on "success", (hotel) ->
          booking.numberOfNights = (booking.checkoutDate - booking.checkinDate) / (24 * 60 * 60 * 1000)
          booking.totalPayment = booking.numberOfNights * hotel.price
          res.render "travel/booking",
            hotel: hotel
            booking: booking


