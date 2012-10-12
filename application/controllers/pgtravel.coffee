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
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')
{DISTINCT, FROM, GO, INNER, INSERT, INTO, IS, JOIN, LEFT, LIKE, LIMIT, OFFSET, ON, ORDER_BY, OUTER, RIGHT, SELECT, SET, UPDATE, VALUES, WHERE} = require(FCPATH + 'lib/sql.dsl')

moment          = require('moment')                     # Parse, manipulate, and display dates
CI_Controller   = require(BASEPATH + 'core/Controller') # Exspresso Controller Base Class


class Travel extends CI_Controller

  ## --------------------------------------------------------------------

  #
  # Load the configured database
  #
  #   @access	public
  #   @return	void
  #
  constructor: ->

    super()
    @load.database get_config().db_url, false, true


  ## --------------------------------------------------------------------

  #
  # Search for Hotels
  #
  #   @access	public
  #   @return	void
  #
  #
  search: ->

    SELECT 'Hotel.name', 'Hotel.address', 'Hotel.city', 'Hotel.state', 'Booking.checkinDate', 'Booking.checkoutDate', 'Booking.id',
    FROM 'Booking',
    WHERE 'Booking.state', IS 'BOOKED',
    INNER JOIN 'Hotel', ON 'Hotel.id = Booking.hotel',
    GO @db, ($err, $bookings) =>

      if $err
        console.log $err
        @res.send $err, 500
        return

      @render "pgtravel/main",
        bookings: $bookings

  ## --------------------------------------------------------------------

  #
  # Display Hotel search results
  #
  #   @access	public
  #   @return	void
  #
  hotels: ->

    $searchString = @req.param("searchString")
    $pageSize = parseInt(@req.param('pageSize'),10)

    SELECT '*',
    FROM 'Hotel',
    WHERE 'name', LIKE "%#{$searchString}%",
    LIMIT $pageSize, OFFSET 0,
    GO @db, ($err, $hotels) =>

      if $err
        console.log $err
        @res.send $err, 500
        return

      @render "pgtravel/hotels",
        hotels: $hotels


  ## --------------------------------------------------------------------

  #
  # Display a Hotel
  #
  #   @access	public
  #   @param string   The Hotel record id#
  #   @return	void
  #
  hotel: ($id) ->

    SELECT '*',
    FROM 'Hotel',
    WHERE 'id', IS $id,
    GO @db, ($err, $hotel) =>

      if $err
        console.log $err
        @res.send $err, 500
        return

      @render "pgtravel/detail",
        hotel: $hotel

  ## --------------------------------------------------------------------

  #
  # Book the room
  #
  #   @access	public
  #   @return	void
  #
  booking: ->

    if @req.body.cancel? then @res.redirect "/pgtravel/search"

    SELECT '*',
    FROM 'Hotel',
    WHERE 'id', IS @req.param("hotelId"),
    GO @db, ($err, $hotel) =>

      @render "pgtravel/booking",
        hotel: $hotel

  ## --------------------------------------------------------------------

  #
  # Confirm the Booking
  #
  #   @access	public
  #   @return	void
  #
  confirm: ->

    if @req.body.cancel? then @res.redirect "/pgtravel/search"

    $id = @req.param("hotelId")

    SELECT '*',
    FROM 'Hotel',
    WHERE 'id', IS $id,
    GO @db, ($err, $hotel) =>

      if $err
        console.log $err
        @res.send $err, 500
        return

      checkinDate =             moment(@req.body.checkinDate, "MM-DD-YYYY")
      checkoutDate =            moment(@req.body.checkoutDate, "MM-DD-YYYY")
      creditCard =              @req.body.creditCard
      creditCardName =          @req.body.creditCardName
      creditCardExpiryMonth =   parseInt(@req.body.creditCardExpiryMonth)
      creditCardExpiryYear =    parseInt(@req.body.creditCardExpiryYear)
      smoking =                 @req.body.smoking
      beds =                    1
      amenities =               @req.body.amenities
      state =                   "CREATED"

      INSERT INTO 'Booking',
      ['username', 'hotel', 'checkinDate', 'checkoutDate', 'creditCard', 'creditCardName', 'creditCardExpiryMonth', 'creditCardExpiryYear', 'smoking', 'beds', 'amenities', 'state'],
      VALUES ['demo', $hotel.id, checkinDate, checkoutDate, creditCard, creditCardName, creditCardExpiryMonth, creditCardExpiryYear, smoking, beds, amenities, state],
      GO @db, ($err) =>

        if $err
          @res.send $err, 500

        else
          $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
          $booking.totalPayment = $booking.numberOfNights * $hotel.price
          @res.render "pgtravel/confirm",

            hotel: $hotel
            booking: $booking


  ## --------------------------------------------------------------------

  #
  # Book/Revise/Cancel
  #
  #   @access	public
  #   @return	void
  #
  book: ->

    $id = @req.body.BookingId

    SELECT '*',
    FROM 'Booking',
    WHERE 'id', IS $id,
    GO @db, ($err, $booking) =>

      if $err
        @res.send $err, 500

      else

        if @req.body.confirm?

          $state = {state: 'BOOKED'}

          UPDATE 'Booking',
          WHERE 'id', IS $id,
          SET $state,
          GO @db, ($err) =>

            @res.redirect "/pgtravel/search"

        else if @req.body.cancel?

          $state = {state: 'CANCELLED'}

          UPDATE 'Booking',
          WHERE 'id', IS $id,
          SET $state,
          GO @db, ($err) =>

            @res.redirect "/pgtravel/search"


        else if @req.body.revise?

          SELECT '*',
          FROM 'Hotel',
          WHERE 'id', IS $booking.hotel,
          GO @db, ($err, $hotel) =>

            if $err
              @res.send $err, 500

            else

              $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
              $booking.totalPayment = $booking.numberOfNights * $hotel.price
              @render "pgtravel/booking",
                hotel: $hotel
                booking: $booking



#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: .application/controllers/Travel.coffee