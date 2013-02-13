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
moment          = require('moment')                     # Parse, manipulate, and display dates
bcrypt          = require('bcrypt')                     # A bcrypt library for NodeJS.
require APPPATH+'core/PublicController.coffee'


class Travel extends PublicController

  ## --------------------------------------------------------------------

  #
  # Customer Login
  #
  #   @access	public
  #   @return	void
  #
  #
  login: () ->

    $url = @input.get_post('url')

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
          @session.set_userdata 'usercode', $customer

          @session.set_flashdata 'info', 'Hello '+$customer.name
          return @redirect $url
        else
          return @redirect "/travel/logout"


  ## --------------------------------------------------------------------

  #
  # Authenticate Customer credentials
  #
  #   @access	public
  #   @return	void
  #
  #
  authenticate: () ->

    $url = @input.get_post('url')

    $username = @input.post("username")
    $password = @input.post("password")
    $remember = @input.post("remember")

    @db.from 'customer'
    @db.where 'username', $username
    @db.get ($err, $customer) =>

      if $customer.num_rows is 0
        @session.set_flashdata 'error', 'Invalid credentials. Please try again.'
        return @redirect "/travel/login"
        return

      $customer = $customer.row()
      if $password is $customer.password

        if $remember
          @input.set_cookie 'username', $customer.username, new Date(Date.now()+900000)
          @input.set_cookie 'usercode', $customer.password, new Date(Date.now()+900000)

        delete $customer.password
        @session.set_userdata 'customer', $customer

        @session.set_flashdata  'info', 'Hello '+$customer.name
        return @redirect $url
      else
        @session.set_flashdata 'error', 'Invalid credentials. Please try again.'
        return @redirect "/travel/login"


  ## --------------------------------------------------------------------

  #
  # Customer Logout
  #
  #   @access	public
  #   @return	void
  #
  #
  logout: () ->

    @session.set_flashdata  'info', 'Goodbye!'
    @session.unset_userdata 'customer'
    @input.set_cookie 'username', ''
    @input.set_cookie 'usercode', ''
    return @redirect "/travel"


  ## --------------------------------------------------------------------

  #
  # Search for hotels
  #
  #   @access	public
  #   @return	void
  #
  #
  search: () ->

    $searchString = @session.userdata("searchString") ||  ''
    $pageSize     = @session.userdata('pageSize') || ''

    @db.select ['hotel.name', 'hotel.address', 'hotel.city', 'hotel.state', 'booking.checkinDate', 'booking.checkoutDate', 'booking.id']
    @db.from 'booking'
    @db.where 'booking.state', 'BOOKED'
    @db.join 'hotel', 'hotel.id = booking.hotel','inner'
    @db.get ($err, $bookings) =>

      @template.view "travel/main", $err || {
        bookings:       $bookings.result()
        searchString:   $searchString
        pageSize:       ''+parseInt($pageSize,10)
        pageSizes:
            '5':    5
            '10':   10
            '20':   20
      }


  ## --------------------------------------------------------------------

  #
  # Display hotel search results
  #
  #   @access	public
  #   @return	void
  #
  hotels: ($start = 0) ->

    base_url = @load.helper('url').base_url

    $start = parseInt($start)
    if @input.post("submit")?
      $searchString = @input.post("searchString")
      $pageSize     = parseInt(@input.post('pageSize'),10)
      @session.set_userdata
        searchString  : $searchString
        pageSize      : $pageSize

    else
      $searchString = @session.userdata("searchString")
      $pageSize     = parseInt(@session.userdata('pageSize'),10)

    @db.count_all 'hotel', ($err, $count) =>

      return @template.view($err) if $err

      @load.library 'pagination',
        base_url    : base_url.call(@)+'travel/hotels/'
        uri_segment : 3
        total_rows  : parseInt($count, 10)
        per_page    : $pageSize

      @db.from 'hotel'
      @db.like 'name', "%#{$searchString}%"
      @db.limit $pageSize, $start
      @db.get ($err, $hotels) =>

        @template.view "travel/hotels", $err || {
          hotels:       $hotels.result()
          searchString: $searchString
          pageSize:     $pageSize
          pagination:   @pagination
        }



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

      @template.view "travel/detail", $err || {
        id:       $id
        hotel:    $hotel.row()
      }


  ## --------------------------------------------------------------------

  #
  # Book the room
  #
  #   @access	public
  #   @return	void
  #
  booking: ($id) ->

    if @input.post('cancel')? then return @redirect "/travel"

    if not @session.userdata('customer')
      return @redirect "/travel/login?url=/travel/booking/#{$id}"

    @db.from 'hotel'
    @db.where 'id', $id
    @db.get ($err, $hotel) =>

      @template.view "travel/booking", $err || {
        id:       $id
        hotel:    $hotel.row()
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





  ## --------------------------------------------------------------------

  #
  # Confirm the booking
  #
  #   @access	public
  #   @return	void
  #
  confirm: ($id) ->

    if @input.get_post('cancel')? then return @redirect "/travel"

    if not @session.userdata('customer')
      return @redirect "/travel/login?url=/travel/confirm/#{$id}"

    @db.from 'hotel'
    @db.where 'id', $id
    @db.get ($err, $hotel) =>

      return @template.view($err) if $err

      $hotel = $hotel.row()
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

      @db.insert 'booking', $booking, ($err) =>

        if $err then throw new Error($err)
        @db.insert_id ($err, $booking_id) =>

          return @template.view($err) if $err
          if not $booking_id? then throw new Error('insert id not returned')

          $booking.id = $booking_id
          $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
          $booking.totalPayment = $booking.numberOfNights * $hotel.price
          @template.view "travel/confirm",

            hotel:    $hotel
            booking:  $booking


  ## --------------------------------------------------------------------

  #
  # Book/Revise/Cancel
  #
  #   @access	public
  #   @return	void
  #
  book: ($id) ->

    if not @session.userdata('customer')
      return @redirect "/travel/login?url=/travel/book/#{$id}"

    @db.from 'booking'
    @db.where 'id', $id
    @db.get ($err, $booking) =>

      return @template.view($err) if $err
      $booking = $booking.row()

      if @input.post('confirm')?

        @db.where 'id', $id
        @db.update 'booking', state: 'BOOKED', ($err) =>

          return @redirect "/travel"

      else if @input.post('cancel')?

        @db.where 'id', $id
        @db.update 'booking', state: 'CANCELLED', ($err) =>

          return @redirect "/travel"

      else if @input.post('revise')?

        @db.from 'hotel'
        @db.where 'id', $booking.hotel
        @db.get ($err, $hotel) =>

          return @template.view($err) if $err

          $booking.numberOfNights = ($booking.checkoutDate - $booking.checkinDate) / (24 * 60 * 60 * 1000)
          $booking.totalPayment = $booking.numberOfNights * $hotel.price
          @template.view "travel/booking",
            hotel:    $hotel.row()
            booking:  $booking



#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: ./application/modules/travel/controllers/Travel.coffee