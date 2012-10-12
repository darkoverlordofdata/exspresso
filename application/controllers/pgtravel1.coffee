#+--------------------------------------------------------------------+
#| travel.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	Travel Controller Class
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')

CI_Controller   = require(BASEPATH + 'core/Controller') # Exspresso Controller Base Class

class Travel extends CI_Controller

  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  # Load the demo travel data model
  #
  #   @access	public
  #   @return	void
  #
  constructor: ->

    super()
    @load.model 'PgTravel', 'Travel'
    @Travel.initialize()

  ## --------------------------------------------------------------------

  #
  # Search
  #
  # Search for hotels
  #
  #   @access	public
  #   @return	void
  #
  search: ->

    query = @Travel.Booking.findAll(where: {state: "BOOKED"})
    query.on "success", (bookings) =>

      @render "pgtravel/main",
        bookings: bookings

  ## --------------------------------------------------------------------

  #
  # Hotels
  #
  # Display search results
  #
  #   @access	public
  #   @return	void
  #
  hotels: ->

    query = @Travel.Hotel.findAll(where: ["name like ?", "%" + @req.param("searchString") + "%"])
    query.on "success", ($result) =>

      @render "pgtravel/hotels",
        hotels: $result

  ## --------------------------------------------------------------------

  #
  # Hotel
  #
  # Display one hotel
  #
  #   @access	public
  #   @param string   The hotel record id#
  #   @return	void
  #
  hotel: ($id) ->

    query = @Travel.Hotel.find(parseInt($id, 10))
    query.on "success", ($result) =>

      @render "pgtravel/detail",
        hotel: $result


  ## --------------------------------------------------------------------

  #
  # Book Hotel
  #
  booking: ->

    if @req.body.cancel? then @res.redirect "/pgtravel/search"

    query = @Travel.Hotel.find(parseInt(@req.param("hotelId")))
    query.on "success", (result) =>
      @render "pgtravel/booking",
        hotel: result

  ## --------------------------------------------------------------------

  #
  # Confirm
  #
  confirm: ->

    moment = require('moment')
    if @req.body.cancel? then @res.redirect "/pgtravel/search"
    query = @Travel.Hotel.find(parseInt(@req.body.hotelId))
    query.on("success", (result) =>

      booking = @Travel.Booking.build(
        username:               'demo' #req.session.user
        hotel:                  result.id
        checkinDate:            moment(@req.body.checkinDate, "MM-DD-YYYY")
        checkoutDate:           moment(@req.body.checkoutDate, "MM-DD-YYYY")
        creditCard:             @req.body.creditCard
        creditCardName:         @req.body.creditCardName
        creditCardExpiryMonth:  parseInt(@req.body.creditCardExpiryMonth)
        creditCardExpiryYear:   parseInt(@req.body.creditCardExpiryYear)
        smoking:                @req.body.smoking
        beds:                   1
        amenities:              @req.body.amenities
        state:                   "CREATED"
      )
      booking.save().on("success", =>
        booking.numberOfNights = (booking.checkoutDate - booking.checkinDate) / (24 * 60 * 60 * 1000)
        booking.totalPayment = booking.numberOfNights * result.price
        @res.render "pgtravel/confirm",
          hotel: result
          booking: booking

      ).on "failure", (error) =>
        console.log error
        @res.send error, 500

    ).on "failure", (error) =>
      console.log error
      @res.send error, 500

  ## --------------------------------------------------------------------

  #
  # submit - revise - cancel
  #
  book: ->

    query = @Travel.Booking.find(parseInt(@req.body.bookingId))
    query.on("success", (booking) =>

      if @req.body.confirm?
        booking.state = "BOOKED"
        booking.save().on("success", =>
          @res.redirect "/pgtravel/search"
        ).on "failure", (error) =>
          console.log error
          @res.send error, 500

      else if @req.body.cancel?
        booking.state = "CANCELLED"
        booking.save().on("success", =>
          @res.redirect "/pgtravel/search"
        ).on "failure", (error) =>
          console.log error
          @res.send error, 500

      else if @req.body.revise?
        @Travel.Hotel.find(booking.hotel).on "success", (hotel) =>
          booking.numberOfNights = (booking.checkoutDate - booking.checkinDate) / (24 * 60 * 60 * 1000)
          booking.totalPayment = booking.numberOfNights * hotel.price
          @res.render "pgtravel/booking",
            hotel: hotel
            booking: booking

      ).on "failure", (error) =>
      console.log error
      @res.send error, 500


#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: .application/controllers/Travel.coffee