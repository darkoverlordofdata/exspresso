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
{parse_url}  = require(FCPATH + 'pal')

ActiveRecord    = require('mysql-activerecord')         # MySQL ActiveRecord Adapter for Node.js
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

    $config = get_config()
    $connect = parse_url($config.mysql_url)
    @db = new ActiveRecord.Adapter(
      server:     $connect.host
      username:   $connect.user
      password:   $connect.pass
      database:   $connect.path
    )

  ## --------------------------------------------------------------------

  #
  # Search
  #
  # Search for hotels
  #
  #   @access	public
  #   @return	void
  #
  # mysql://b8cd7aef144b25:654529ef@us-cdbr-east-02.cleardb.com/heroku_ee991247d15fd1c?reconnect=true
  #
  search: ->

    $select = ['hotel.name', 'hotel.address', 'hotel.city', 'hotel.state', 'booking.checkinDate', 'booking.checkoutDate', 'booking.id']

    @db.select($select)
    .join('hotel', 'booking.hotel', 'inner')
    .where("booking.hotel = hotel.id")
    .where('booking.state', 'BOOKED')
    .get 'booking', ($err, $results, $fields) =>

      if $err
        console.log $err
        @res.send $err, 500
        return

      @render "mytravel/main",
        bookings: $results

  ## --------------------------------------------------------------------

  #
  # hotels
  #
  # Display search results
  #
  #   @access	public
  #   @return	void
  #
  hotels: ->


    $searchString = @req.param("searchString")
    $pageSize = parseInt(@req.param('pageSize'),10)

    console.log "pageSize = #{$pageSize}"

    @db.where("name like '%#{$searchString}%'").get 'hotel', ($err, $results, $fields) =>

      @render "mytravel/hotels",
        hotels: $results


  ## --------------------------------------------------------------------

  #
  # hotel
  #
  # Display one hotel
  #
  #   @access	public
  #   @param string   The hotel record id#
  #   @return	void
  #
  hotel: ($id) ->

    @db.where('id', $id).get 'hotel', ($err, $results, $fields) =>

      @render "mytravel/detail",
        hotel: $results[0]

  ## --------------------------------------------------------------------

  #
  # booking
  #
  # book the room
  #
  #   @access	public
  #   @return	void
  #
  booking: ->

    if @req.body.cancel? then @res.redirect "/mytravel/search"

    @db.where('id', @req.param("hotelId")).get 'hotel', ($err, $results, $fields) =>

      @render "mytravel/booking",
        hotel: $results[0]

  ## --------------------------------------------------------------------

  #
  # Confirm
  #
  confirm: ->

    if @req.body.cancel? then @res.redirect "/mytravel/search"

    $id = @req.param("hotelId")
    console.log "confirm hotel id = #{$id}"

    @db.where('id', $id).get 'hotel', ($err, $results, $fields) =>

      moment = require('moment')
      $hotel = $results[0]

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
        state:                   "CREATED"

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
  # Submit - revise - cancel
  #
  book: ->

    $id = @req.body.bookingId
    @db.where('id', $id).get 'booking', ($err, $results, $fields) =>

      if $err
        @res.send $err, 500

      else

        $booking = $results[0]

        if @req.body.confirm?

          @db.where('id', $id).update 'booking', state: 'BOOKED', ($err) =>

            @res.redirect "/mytravel/search"

        else if @req.body.cancel?

          @db.where('id', $id).update 'booking', state: 'CANCELLED', ($err) =>

            @res.redirect "/mytravel/search"


        else if @req.body.revise?

          @db.where('id', $booking.hotel).get 'hotel', ($err, $results, $fields) =>

            if $err
              @res.send $err, 500

            else
              $hotel = $results[0]
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