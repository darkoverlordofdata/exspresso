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
    @db = @load.database('postgres', true)


  ## --------------------------------------------------------------------

  #
  # Search for Hotels
  #
  #   @access	public
  #   @return	void
  #
  #
  search: ->

    SELECT 'hotel.name', 'hotel.address', 'hotel.city', 'hotel.state', 'booking.checkinDate', 'booking.checkoutDate', 'booking.id',
    FROM 'booking',
    WHERE 'booking.state', IS 'BOOKED',
    INNER JOIN 'hotel', ON 'hotel.id = booking.hotel',
    GO @db,($err, $bookings) =>

      @load.view "pgtravel/main",
        bookings: $bookings

  ## --------------------------------------------------------------------

  #
  # Display hotel search results
  #
  #   @access	public
  #   @return	void
  #
  hotels: ->

    $searchString = @req.param("searchString")
    $pageSize = parseInt(@req.param('pageSize'),10)

    SELECT '*',
    FROM 'hotel',
    WHERE 'name', LIKE "%#{$searchString}%",
    LIMIT $pageSize, OFFSET 0,
    GO @db,($err, $hotels) =>

      @load.view "pgtravel/hotels",
        hotels: $hotels


  ## --------------------------------------------------------------------

  #
  # Display a hotel
  #
  #   @access	public
  #   @param string   The hotel record id#
  #   @return	void
  #
  hotel: ($id) ->

    SELECT '*',
    FROM 'hotel',
    WHERE 'id', IS $id,
    GO @db,($err, $hotel) =>

      @load.view "pgtravel/detail",
        hotel: $hotel

  ## --------------------------------------------------------------------

  #
  # Book the room
  #
  #   @access	public
  #   @return	void
  #
  booking: ->

    if @req.body.cancel? then @redirect "/pgtravel/search"

    SELECT '*',
    FROM 'hotel',
    WHERE 'id', IS @req.param("hotelId"),
    GO @db,($err, $hotel) =>

      @load.view "pgtravel/booking",
        hotel: $hotel

  ## --------------------------------------------------------------------

  #
  # Confirm the booking
  #
  #   @access	public
  #   @return	void
  #
  confirm: ->

    if @req.body.cancel? then @redirect "/pgtravel/search"

    $id = @req.param("hotelId")

    SELECT '*',
    FROM 'hotel',
    WHERE 'id', IS $id,
    GO @db,($err, $hotel) =>

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

      INSERT INTO 'booking',
      ['username', 'hotel', 'checkinDate', 'checkoutDate', 'creditCard', 'creditCardName', 'creditCardExpiryMonth', 'creditCardExpiryYear', 'smoking', 'beds', 'amenities', 'state'],
      VALUES ['demo', $hotel.id, checkinDate, checkoutDate, creditCard, creditCardName, creditCardExpiryMonth, creditCardExpiryYear, smoking, beds, amenities, state],
      GO @db,($err) =>

        if $err then throw new Error($err)

        $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
        $booking.totalPayment = $booking.numberOfNights * $hotel.price
        @load.view "pgtravel/confirm",

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
    FROM 'booking',
    WHERE 'id', IS $id,
    GO @db,($err, $booking) =>

      if @req.body.confirm?

        $state = {state: 'BOOKED'}

        UPDATE 'booking',
        WHERE 'id', IS $id,
        SET $state,
        GO @db,($err) =>

          @redirect "/pgtravel/search"

      else if @req.body.cancel?

        $state = {state: 'CANCELLED'}

        UPDATE 'booking',
        WHERE 'id', IS $id,
        SET $state,
        GO @db,($err) =>

          @redirect "/pgtravel/search"


      else if @req.body.revise?

        SELECT '*',
        FROM 'hotel',
        WHERE 'id', IS $booking.hotel,
        GO @db,($err, $hotel) =>

          $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
          $booking.totalPayment = $booking.numberOfNights * $hotel.price
          @load.view "pgtravel/booking",
            hotel: $hotel
            booking: $booking



#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: .application/controllers/Travel.coffee