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
    @load.database get_config().mysql_url, false, true


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
    @db.join 'hotel', 'hotel.id = booking.hotel', 'inner'
    @db.get ($err, $results, $fields) =>

      if $err
        console.log $err
        @res.send $err, 500
        return

      @render "mytravel/main",
        bookings: $results

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
    GO @db, ($err, $results) =>

      if $err
        console.log $err
        @res.send $err, 500
        return

      @render "mytravel/hotels",
        hotels: $results


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
    @db.get ($err, $results, $fields) =>

      if $err
        console.log $err
        @res.send $err, 500
        return

      @render "mytravel/detail",
        hotel: $results

  ## --------------------------------------------------------------------

  #
  # Book the room
  #
  #   @access	public
  #   @return	void
  #
  booking: ->

    if @req.body.cancel? then @res.redirect "/mytravel/search"

    @db.from 'hotel'
    @db.where 'id', @req.param("hotelId")
    @db.get ($err, $results, $fields) =>

      @render "mytravel/booking",
        hotel: $results

  ## --------------------------------------------------------------------

  #
  # Confirm the booking
  #
  #   @access	public
  #   @return	void
  #
  confirm: ->

    if @req.body.cancel? then @res.redirect "/mytravel/search"

    $id = @req.param("hotelId")
    console.log "confirm hotel id = #{$id}"

    @db.from 'hotel'
    @db.where 'id', $id
    @db.get ($err, $results, $fields) =>

      moment = require('moment')
      $hotel = $results

      if $err
        console.log $err
        @res.send $err, 500
        return

      console.log $results

      $booking =
        username:               'demo' #req.session.user
        hotel:                  $hotel.id
        checkinDate:            moment(@req.body.checkinDate, "MM-DD-YYYY")
        checkoutDate:           moment(@req.body.checkoutDate, "MM-DD-YYYY")
        creditCard:             @req.body.creditCard
        creditCardName:         @req.body.creditCardName
        creditCardExpiryMonth:  parseInt(@req.body.creditCardExpiryMonth)
        creditCardExpiryYear:   parseInt(@req.body.creditCardExpiryYear)
        smoking:                @req.body.smoking
        beds:                   1
        amenities:              @req.body.amenities
        state:                  "CREATED"

      @db.insert 'booking', $booking, ($err, $info) =>

        if $err
          @res.send $err, 500

        else
          $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
          $booking.totalPayment = $booking.numberOfNights * $hotel.price
          @res.render "mytravel/confirm",

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

    $id = @req.body.bookingId
    @db.from 'booking'
    @db.where 'id', $id
    @db.get ($err, $results, $fields) =>

      if $err
        @res.send $err, 500

      else

        $booking = $results

        if @req.body.confirm?

          @db.where 'id', $id
          @db.update 'booking', state: 'BOOKED', ($err) =>

            @res.redirect "/mytravel/search"

        else if @req.body.cancel?

          @db.where 'id', $id
          @db.update 'booking', state: 'CANCELLED', ($err) =>

            @res.redirect "/mytravel/search"


        else if @req.body.revise?

          @db.from 'hotel'
          @db.where 'id', $booking.hotel
          @db.get ($err, $results, $fields) =>

            if $err
              @res.send $err, 500

            else
              $hotel = $results
              $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
              $booking.totalPayment = $booking.numberOfNights * $hotel.price
              @render "mytravel/booking",
                hotel: $hotel
                booking: $booking



#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: .application/controllers/Travel.coffee