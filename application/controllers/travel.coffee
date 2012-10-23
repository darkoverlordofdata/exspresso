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

CI_Controller   = require(BASEPATH + 'core/Controller') # Exspresso Controller Base Class
moment          = require('moment')                     # Parse, manipulate, and display dates
bcrypt          = require('bcrypt')                     # A bcrypt library for NodeJS.


class Travel extends CI_Controller


  ## --------------------------------------------------------------------

  #
  # Customer Login
  #
  #   @access	public
  #   @return	void
  #
  #
  login: ($db) ->

    $url        = @input.get_post('url')
    $hotelId    = @input.get_post('hotelId')
    $bookingId  = @input.get_post('bookingId')

    @db = @load.database($db, true)
    @db.initialize =>

      if @input.cookie('username') is ''

        @load.view "travel/login",
          db:  $db
          url: $url
          hotelId: $hotelId
          bookingId: $bookingId

      else

        @db.from 'customer'
        @db.where 'username', @input.cookie('username')
        @db.get ($err, $customer) =>

          if $err
            @load.view "travel/login",
              db:  $db
              url: $url
              hotelId: $hotelId
              bookingId: $bookingId
            return

          if $customer.num_rows is 0
            @load.view "travel/login",
              db:  $db
              url: $url
              hotelId: $hotelId
              bookingId: $bookingId
            return

          $customer = $customer.row()
          if $customer.password is @input.cookie('usercode')
            @session.set_userdata 'usercode', $customer

            @session.set_flashdata 'info', 'Hello '+$customer.name
            @redirect $url
          else
            @redirect "/travel/#{db}/logout"


  ## --------------------------------------------------------------------

  #
  # Authenticate Customer credentials
  #
  #   @access	public
  #   @return	void
  #
  #
  authenticate: ($db) ->

    $url        = @input.get_post('url')
    $hotelId    = @input.get_post('hotelId')
    $bookingId  = @input.get_post('bookingId')

    if $hotelId is null
      $url = "#{$url}?bookingId=#{$bookingId}"
    else
      $url = "#{$url}?hotelId=#{$hotelId}"

    @db = @load.database($db, true)
    @db.initialize =>

      $username = @input.post("username")
      $password = @input.post("password")
      $remember = @input.post("remember")

      @db.from 'customer'
      @db.where 'username', $username
      @db.get ($err, $customer) =>

        if $customer.num_rows is 0
          @session.set_flashdata 'error', 'Invalid credentials. Please try again.'
          @redirect "/travel/#{db}/login"
          return

        $customer = $customer.row()
        if $password is $customer.password

          if $remember
            @input.set_cookie 'username', $customer.username, 900000
            @input.set_cookie 'usercode', $customer.password, 900000

          delete $customer.password
          @session.set_userdata 'customer', $customer

          @session.set_flashdata  'info', 'Hello '+$customer.name
          @redirect $url
        else
          @session.set_flashdata 'error', 'Invalid credentials. Please try again.'
          @redirect "/travel/#{db}/login"


  ## --------------------------------------------------------------------

  #
  # Customer Logout
  #
  #   @access	public
  #   @return	void
  #
  #
  logout: ($db) ->

    @session.set_flashdata  'info', 'Goodbye!'
    @session.unset_userdata 'customer'
    @input.set_cookie 'username', ''
    @input.set_cookie 'usercode', ''
    @redirect "travel/#{$db}"


  ## --------------------------------------------------------------------

  #
  # Search for hotels
  #
  #   @access	public
  #   @return	void
  #
  #
  search: ($db) ->

    @db = @load.database($db, true)
    @db.initialize =>

      @db.select ['hotel.name', 'hotel.address', 'hotel.city', 'hotel.state', 'booking.checkinDate', 'booking.checkoutDate', 'booking.id']
      @db.from 'booking'
      @db.where 'booking.state', 'BOOKED'
      @db.join 'hotel', 'hotel.id = booking.hotel','inner'
      @db.get ($err, $bookings) =>

        @load.view "travel/main",
          db:       $db
          bookings: $bookings.result()

  ## --------------------------------------------------------------------

  #
  # Display hotel search results
  #
  #   @access	public
  #   @return	void
  #
  hotels: ($db) ->

    @db = @load.database($db, true)
    @db.initialize =>

      $searchString = @input.post("searchString")
      $pageSize = parseInt(@input.post('pageSize'),10)

      @db.from 'hotel'
      @db.like 'name', "%#{$searchString}%"
      @db.limit $pageSize, 0
      @db.get @db, ($err, $hotels) =>

        @load.view "travel/hotels",
          db:     $db
          hotels: $hotels.result()


  ## --------------------------------------------------------------------

  #
  # Display a hotel
  #
  #   @access	public
  #   @param string   The hotel record id#
  #   @return	void
  #
  hotel: ($db, $id) ->

    @db = @load.database($db, true)
    @db.initialize =>

      @db.from 'hotel'
      @db.where 'id', $id
      @db.get ($err, $hotel) =>

        @load.view "travel/detail",
          db:     $db
          hotel:  $hotel.row()

  ## --------------------------------------------------------------------

  #
  # Book the room
  #
  #   @access	public
  #   @return	void
  #
  booking: ($db) ->

    if @input.post('cancel')? then @redirect "/travel/#{$db}"

    $id = @input.get_post("hotelId")

    if not @session.userdata('customer')
      @redirect "/travel/#{$db}/login?url=/travel/#{$db}/booking&hotelId=#{$id}"

    @db = @load.database($db, true)
    @db.initialize =>

      @db.from 'hotel'
      @db.where 'id', $id
      @db.get ($err, $hotel) =>

        @load.view "travel/booking",
          db:     $db
          hotel:  $hotel.row()

  ## --------------------------------------------------------------------

  #
  # Confirm the booking
  #
  #   @access	public
  #   @return	void
  #
  confirm: ($db) ->

    if @input.get_post('cancel')? then @redirect "/travel/#{$db}"

    $id = @input.post("hotelId")

    if not @session.userdata('customer')
      @redirect "/travel/#{$db}/login?url=/travel/#{$db}/confirm&hotelId=#{$id}"

    @db = @load.database($db, true)
    @db.initialize =>


      @db.from 'hotel'
      @db.where 'id', $id
      @db.get ($err, $hotel) =>

        $hotel = $hotel.row()
        $customer = @session.userdata('customer')
        $booking =
          username:               $customer.username
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
          @db.insert_id ($err, $booking_id) =>

            if not $booking_id? then throw new Error('insert id not returned')

            $booking.id = $booking_id
            $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
            $booking.totalPayment = $booking.numberOfNights * $hotel.price
            @load.view "travel/confirm",

              db:       $db
              hotel:    $hotel
              booking:  $booking


  ## --------------------------------------------------------------------

  #
  # Book/Revise/Cancel
  #
  #   @access	public
  #   @return	void
  #
  book: ->

    $id = @input.get_post('bookingId')

    if not @session.userdata('customer')
      @redirect "/travel/#{$db}/login?url=/travel/#{$db}/book&bookingId=#{$id}"

    @db = @load.database($db, true)
    @db.initialize =>


      @db.from 'booking'
      @db.where 'id', $id
      @db.get ($err, $booking) =>

        $booking = $booking.row()
        if @input.post('confirm')?

          @db.where 'id', $id
          @db.update 'booking', state: 'BOOKED', ($err) =>

            @redirect "/travel/#{$db}"

        else if @input.post('cancel')?

          @db.where 'id', $id
          @db.update 'booking', state: 'CANCELLED', ($err) =>

            @redirect "/travel/#{$db}"

        else if @input.post('revise')?

          @db.from 'hotel'
          @db.where 'id', $booking.hotel
          @db.get ($err, $hotel) =>

            $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
            $booking.totalPayment = $booking.numberOfNights * $hotel.price
            @load.view "travel/booking",
              db:       $db
              hotel:    $hotel.row()
              booking:  $booking



#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: .application/controllers/Travel.coffee