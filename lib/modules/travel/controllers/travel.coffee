#+--------------------------------------------------------------------+
#| travel.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
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
require APPPATH+'core/PublicController.coffee'


class Travel extends application.core.PublicController


  bcrypt = require('bcrypt')  # A bcrypt library for NodeJS.

  #
  # Initialize the controller
  #
  constructor: ($args...) ->

    super $args...
    @load.model 'HotelModel', 'hotels'

  #
  # Search Action
  #
  # Search for hotels
  #
  # @return [Void]
  #
  searchAction: () ->

    $searchString = @session.userdata("searchString") ||  ''
    $pageSize     = @session.userdata('pageSize') || ''

    @hotels.getBooked ($err, $bookings) =>

      @template.view "travel/main", $err || {
        bookings      : $bookings
        searchString  : $searchString
        pageSize      : ''+parseInt($pageSize,10)
        pageSizes     :
            '5'         :  5
            '10'        : 10
            '20'        : 20
      }


  #
  # Hotels Action
  #
  #
  # Display hotel search results
  #
  # @param  [String]  $start  start at row number
  # @return [Void]
  #
  hotelsAction: ($start = 0) ->

    base_url = @load.helper('url').base_url

    $start = parseInt($start)
    if @input.post("submit")?
      $searchString = @input.post("searchString")
      $pageSize     = parseInt(@input.post('pageSize'),10)
      @session.setUserdata
        searchString  : $searchString
        pageSize      : $pageSize

    else
      $searchString = @session.userdata("searchString")
      $pageSize     = parseInt(@session.userdata('pageSize'),10)

    @hotels.getCount ($err, $count) =>

      return @template.view($err) if $err

      @load.library 'pagination',
        base_url      : base_url.call(@)+'travel/hotels/'
        uri_segment   : 3
        total_rows    : parseInt($count, 10)
        per_page      : $pageSize

      @hotels.getLike $searchString, $pageSize, $start, ($err, $hotels) =>

        @template.view "travel/hotels", $err || {
          hotels        : $hotels
          searchString  : $searchString
          pageSize      : $pageSize
        }



  #
  # Hotel Action
  #
  #
  # Display a hotel
  #
  # @param string   The hotel record id#
  # @return [Void]
  #
  hotelAction: ($id) ->

    @hotels.getById $id, ($err, $hotel) =>

      @template.view "travel/detail", $err || {
        id      : $id
        hotel   : $hotel
      }


  #
  # Booking Action
  #
  #
  # Book the room
  #
  # @return [Void]
  #
  bookingAction: ($id) ->

    if @input.post('cancel')? then return @redirect "/travel"

    if not @session.userdata('customer')
      return @redirect "/travel/login?url=/travel/booking/#{$id}"

    @hotels.getById $id, ($err, $hotel) =>

      @template.view "travel/booking", $err || {
        id      : $id
        hotel   : $hotel
        beds:
                  '1'   : 'One king-size bed'
                  '2'   : 'Two double beds'
                  '3'   : 'Three beds'
        cardMonth:
                  '1'   : 'Jan'
                  '2'   : 'Feb'
                  '3'   : 'Mar'
                  '4'   : 'Apr'
                  '5'   : 'May'
                  '6'   : 'Jun'
                  '7'   : 'Jul'
                  '8'   : 'Aug'
                  '9'   : 'Sep'
                  '10'  : 'Oct'
                  '11'  : 'Nov'
                  '12'  : 'Dev'
        cardYear:
                  '1'   : '2012'
                  '2'   : '2013'
                  '3'   : '2014'
                  '4'   : '2015'
                  '5'   : '2016'
      }

  #
  # Confirm Action
  #
  #
  # Confirm the booking
  #
  # @return [Void]
  #
  confirmAction: ($id) ->

    if @input.getPost('cancel')? then return @redirect "/travel"

    if not @session.userdata('customer')
      return @redirect "/travel/login?url=/travel/confirm/#{$id}"

    date = @load.helper('date').date
    @hotels.getById $id, ($err, $hotel) =>

      return @template.view($err) if $err

      $customer = @session.userdata('customer')
      $booking =
        username      : $customer.username
        hotel         : $hotel.id
        checkinDate   : date("MM-DD-YYYY", @input.post('checkinDate'))
        checkoutDate  : date("MM-DD-YYYY", @input.post('checkoutDate'))
        cardNumber    : @input.post('cardNumber')
        cardName      : @input.post('cardName')
        cardMonth     : parseInt(@input.post('cardMonth'))
        cardYear      : parseInt(@input.post('cardYear'))
        smoking       : @input.post('smoking')
        beds          : 1
        amenities     : @input.post('amenities')
        state         : "CREATED"

      @hotels.createBooking $booking, ($err, $booking_id) =>

        return @template.view($err) if $err

        $booking.id = $booking_id
        $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
        $booking.totalPayment = $booking.numberOfNights * $hotel.price
        @template.view "travel/confirm",
          hotel       : $hotel
          booking     : $booking


  #
  # Book Action
  #
  #
  # Book/Revise/Cancel
  #
  # @param  [String]  $id booking id
  # @return [Void]
  #
  bookAction: ($id) ->

    if not @session.userdata('customer')
      return @redirect "/travel/login?url=/travel/book/#{$id}"

    @hotels.getById $id, ($err, $booking) =>

      return @template.view($err) if $err

      if @input.post('confirm')?

        #
        # Confirm
        #
        @hotels.confirmBooking $id, ($err) =>

          return @redirect "/travel"

      else if @input.post('cancel')?

        #
        # Cancel
        #
        @hotels.cancelBooking $id, ($err) =>

          return @redirect "/travel"

      else if @input.post('revise')?

        #
        # Revise
        #
        @hotels.getById $booking.hotel, ($err, $hotel) =>

          return @template.view($err) if $err

          $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
          $booking.totalPayment = $booking.numberOfNights * $hotel.price
          @template.view "travel/booking",
            hotel     : $hotel
            booking   : $booking


  #
  # Login Action
  #
  #
  # Customer Login
  #
  # @return [Void]
  #
  loginAction: () ->

    $url = @input.getPost('url')

    if @input.cookie('username') is ''

      @template.view "travel/login",
        url: $url

    else

      @db.from 'customer'
      @db.where 'username', @input.cookie('username')
      @db.get ($err, $customer) =>

        if $err or $customer.num_rows is 0
          @template.view "travel/login",
            url: $url
          return

        $customer = $customer.row()
        if $customer.password is @input.cookie('usercode')
          @session.setUserdata 'usercode', $customer

          @session.setFlashdata 'info', 'Hello '+$customer.name
          return @redirect $url
        else
          return @redirect "/travel/logout"


  #
  # Authenticate Action
  #
  #
  # Authenticate Customer credentials
  #
  # @return [Void]
  #
  authenticateAction: () ->

    $url = @input.getPost('url')

    $username = @input.post("username")
    $password = @input.post("password")
    $remember = @input.post("remember")

    @db.from 'customer'
    @db.where 'username', $username
    @db.get ($err, $customer) =>

      if $customer.num_rows is 0
        @session.setFlashdata 'error', 'Invalid credentials. Please try again.'
        return @redirect "/travel/login"

      $customer = $customer.row()
      if $password is $customer.password

        if $remember
          @input.setCookie 'username', $customer.username, new Date(Date.now()+900000)
          @input.setCookie 'usercode', $customer.password, new Date(Date.now()+900000)

        delete $customer.password
        @session.setUserdata 'customer', $customer

        @session.setFlashdata  'info', 'Hello '+$customer.name
        return @redirect $url
      else
        @session.setFlashdata 'error', 'Invalid credentials. Please try again.'
        return @redirect "/travel/login"


  #
  # Logout Action
  #
  # Customer Logout
  #
  # @return [Void]
  #
  logoutAction: () ->

    @session.setFlashdata  'info', 'Goodbye!'
    @session.unsetUserdata 'customer'
    @input.setCookie 'username', ''
    @input.setCookie 'usercode', ''
    return @redirect "/travel"



#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: ./application/modules/travel/controllers/Travel.coffee