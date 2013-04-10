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


  moment = require('moment')  # Parse, manipulate, and display dates
  bcrypt = require('bcrypt')  # A bcrypt library for NodeJS.

  #
  # Customer Login
  #
  # @return [Void]
  #
  login: () ->

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
  # Authenticate Customer credentials
  #
  # @return [Void]
  #
  authenticate: () ->

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
  # Customer Logout
  #
  # @return [Void]
  #
  logout: () ->

    @session.setFlashdata  'info', 'Goodbye!'
    @session.unsetUserdata 'customer'
    @input.setCookie 'username', ''
    @input.setCookie 'usercode', ''
    return @redirect "/travel"


  #
  # Search for hotels
  #
  # @return [Void]
  #
  search: () ->

    $searchString = @session.userdata("searchString") ||  ''
    $pageSize     = @session.userdata('pageSize') || ''

    @load.model 'HotelModel'
    @hotelmodel.getBooked ($err, $bookings) =>

      @template.view "travel/main", $err || {
        bookings:       $bookings
        searchString:   $searchString
        pageSize:       ''+parseInt($pageSize,10)
        pageSizes:
            '5':    5
            '10':   10
            '20':   20
      }


  #
  # Display hotel search results
  #
  # @return [Void]
  #
  hotels: ($start = 0) ->

    @load.model 'HotelModel'
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

    @hotelmodel.getCount ($err, $count) =>

      return @template.view($err) if $err

      @load.library 'pagination',
        base_url    : base_url.call(@)+'travel/hotels/'
        uri_segment : 3
        total_rows  : parseInt($count, 10)
        per_page    : $pageSize

      @hotelmodel.getLike $searchString, $pageSize, $start, ($err, $hotels) =>

        @template.view "travel/hotels", $err || {
          hotels:       $hotels
          searchString: $searchString
          pageSize:     $pageSize
        }



  #
  # Display a hotel
  #
  # @param string   The hotel record id#
  # @return [Void]
  #
  hotel: ($id) ->

    @load.model 'HotelModel'
    @hotelmodel.getById $id, ($err, $hotel) =>

      @template.view "travel/detail", $err || {
        id:       $id
        hotel:    $hotel
      }


  #
  # Book the room
  #
  # @return [Void]
  #
  booking: ($id) ->

    if @input.post('cancel')? then return @redirect "/travel"

    if not @session.userdata('customer')
      return @redirect "/travel/login?url=/travel/booking/#{$id}"

    @load.model 'HotelModel'
    @hotelmodel.getById $id, ($err, $hotel) =>

      @template.view "travel/booking", $err || {
        id:       $id
        hotel:    $hotel
        beds:
                  '1':    'One king-size bed'
                  '2':    'Two double beds'
                  '3':    'Three beds'
        cardMonth:
                  '1':    'Jan'
                  '2':    'Feb'
                  '3':    'Mar'
                  '4':    'Apr'
                  '5':    'May'
                  '6':    'Jun'
                  '7':    'Jul'
                  '8':    'Aug'
                  '9':    'Sep'
                  '10':   'Oct'
                  '11':   'Nov'
                  '12':   'Dev'
        cardYear:
                  '1':    '2012'
                  '2':    '2013'
                  '3':    '2014'
                  '4':    '2015'
                  '5':    '2016'
      }





  #
  # Confirm the booking
  #
  # @return [Void]
  #
  confirm: ($id) ->

    if @input.getPost('cancel')? then return @redirect "/travel"

    if not @session.userdata('customer')
      return @redirect "/travel/login?url=/travel/confirm/#{$id}"

    @load.model 'HotelModel'
    @hotelmodel.getById $id, ($err, $hotel) =>

      return @template.view($err) if $err

      $customer = @session.userdata('customer')
      $booking =
        username:       $customer.username
        hotel:          $hotel.id
        checkinDate:    moment(@input.post('checkinDate'), "MM-DD-YYYY")
        checkoutDate:   moment(@input.post('checkoutDate'), "MM-DD-YYYY")
        cardNumber:     @input.post('cardNumber')
        cardName:       @input.post('cardName')
        cardMonth:      parseInt(@input.post('cardMonth'))
        cardYear:       parseInt(@input.post('cardYear'))
        smoking:        @input.post('smoking')
        beds:           1
        amenities:      @input.post('amenities')
        state:          "CREATED"

      @hotelmodel.createBooking $booking, ($err, $booking_id) =>

        return @template.view($err) if $err
        return @template.view(new Error('booking id not returned')) unless $booking_id?

        $booking.id = $booking_id
        $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
        $booking.totalPayment = $booking.numberOfNights * $hotel.price
        @template.view "travel/confirm",

          hotel:    $hotel
          booking:  $booking


  #
  # Book/Revise/Cancel
  #
  # @param  [String]  $id booking id
  # @return [Void]
  #
  book: ($id) ->

    if not @session.userdata('customer')
      return @redirect "/travel/login?url=/travel/book/#{$id}"

    @load.model 'HotelModel'
    @hotelmodel.getById $id, ($err, $booking) =>

      return @template.view($err) if $err

      if @input.post('confirm')?

        #
        # Confirm
        #
        @hotelmodel.confirmBooking $id, ($err) =>

          return @redirect "/travel"

      else if @input.post('cancel')?

        #
        # Cancel
        #
        @hotelmodel.cancelBooking $id, ($err) =>

          return @redirect "/travel"

      else if @input.post('revise')?

        #
        # Revise
        #
        @hotelmodel.getById $booking.hotel, ($err, $hotel) =>

          return @template.view($err) if $err

          $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
          $booking.totalPayment = $booking.numberOfNights * $hotel.price
          @template.view "travel/booking",
            hotel:    $hotel
            booking:  $booking



#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: ./application/modules/travel/controllers/Travel.coffee