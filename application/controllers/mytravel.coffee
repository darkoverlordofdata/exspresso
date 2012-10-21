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
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message, show_error} = require(BASEPATH + 'core/Common')

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
    @db = @load.database('mysql', true)


  ## --------------------------------------------------------------------

  #
  # Search for hotels
  #
  #   @access	public
  #   @return	void
  #
  #
  search: ->

    @db.select 'hotel.name', 'hotel.address', 'hotel.city', 'hotel.state', 'booking.checkinDate', 'booking.checkoutDate', 'booking.id'
    @db.from 'booking'
    @db.where 'booking.state', 'BOOKED'
    @db.join 'hotel', 'hotel.id = booking.hotel','inner'
    @db.get ($err, $bookings) =>

      @load.view "mytravel/main",
        bookings: $bookings

  ## --------------------------------------------------------------------

  #
  # Display hotel search results
  #
  #   @access	public
  #   @return	void
  #
  hotels: ->

    $searchString = @input.post("searchString")
    $pageSize = parseInt(@input.post('pageSize'),10)

    @db.from 'hotel'
    @db.like 'name', "%#{$searchString}%"
    @db.limit $pageSize, 0
    @db.get @db, ($err, $hotels) =>

      @load.view "mytravel/hotels",
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

    @db.from 'hotel'
    @db.where 'id', $id
    @db.get ($err, $hotel) =>

      @load.view "mytravel/detail",
        hotel: $hotel

  ## --------------------------------------------------------------------

  #
  # Book the room
  #
  #   @access	public
  #   @return	void
  #
  booking: ->

    if @input.post('cancel')? then @redirect "/mytravel/search"

    @db.from 'hotel'
    @db.where 'id', @input.post("hotelId")
    @db.get ($err, $hotel) =>

      @load.view "mytravel/booking",
        hotel: $hotel

  ## --------------------------------------------------------------------

  #
  # Confirm the booking
  #
  #   @access	public
  #   @return	void
  #
  confirm: ->

    if @input.post('cancel')? then @redirect "/mytravel/search"

    $id = @input.post("hotelId")

    @db.from 'hotel'
    @db.where 'id', $id
    @db.get ($err, $hotel) =>

      $booking =
        username:               'demo' #req.session.user
        hotel:                  $hotel.id
        checkinDate:            moment(@input.post('checkinDate'), "MM-DD-YYYY")
        checkoutDate:           moment(@input.post('checkoutDate'), "MM-DD-YYYY")
        creditCard:             @input.post('creditCard')
        creditCardName:         @input.post('creditCardName')
        creditCardExpiryMonth:  parseInt(@input.post('creditCardExpiryMonth'))
        creditCardExpiryYear:   parseInt(@input.post('creditCardExpiryYear'))
        smoking:                @input.post('smoking')
        beds:                   1
        amenities:              @input.post('amenities')
        state:                  "CREATED"

      @db.insert 'booking', $booking, ($err) =>

        if $err then throw new Error($err)

        $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
        $booking.totalPayment = $booking.numberOfNights * $hotel.price
        @load.view "mytravel/confirm",

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

    $id = @input.post('bookingId')
    @db.from 'booking'
    @db.where 'id', $id
    @db.get ($err, $results) =>

      $booking = $results

      if @input.post('confirm')?

        @db.where 'id', $id
        @db.update 'booking', state: 'BOOKED', ($err) =>

          @redirect "/mytravel/search"

      else if @input.post('cancel')?

        @db.where 'id', $id
        @db.update 'booking', state: 'CANCELLED', ($err) =>

          @redirect "/mytravel/search"


      else if @input.post('revise')?

        @db.from 'hotel'
        @db.where 'id', $booking.hotel
        @db.get ($err, $results) =>

          $hotel = $results
          $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
          $booking.totalPayment = $booking.numberOfNights * $hotel.price
          @load.view "mytravel/booking",
            hotel: $hotel
            booking: $booking



#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: .application/controllers/Travel.coffee