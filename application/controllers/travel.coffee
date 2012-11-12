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

    $url = @input.get_post('url')

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
          @redirect "/travel/#{$db}/login"
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
          @redirect "/travel/#{$db}/login"


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
          form:
            action:       "/travel/#{$db}/hotels"
            attrs:
              name:       'mainForm'
              class:      'form-search'
            hidden:
              mainForm:   'mainForm'
            submit:
              name:       'findHotels'
              value:      'Search'
              class:      'btn btn-primary'
          searchString:
            name:         'searchString'
            value:        @input.get("searchString")
            class:        'input-medium search-query'
          pageSize:
            name:         'pageSize'
            options:
              '5':    5
              '10':   10
              '20':   20
            selected: ''+parseInt(@input.get('pageSize'),10)
            extras:   'id="pageSize" size="1"'



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
          change: "/travel/#{$db}?searchString=#{$searchString}&pageSize=#{$pageSize}"




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
          form:
            action: "/travel/#{$db}/booking/#{$id}"
            attrs:  ''
            hidden:
                    hotelId:    $id
            submit:
                    name:       'submit'
                    value:      'Book Hotel'
                    class:      'btn btn-primary'
            cancel:
                    name:       'cancel'
                    value:      'Back to Search'
                    class:      'btn'


  ## --------------------------------------------------------------------

  #
  # Book the room
  #
  #   @access	public
  #   @return	void
  #
  booking: ($db, $id) ->

    if @input.post('cancel')? then @redirect "/travel/#{$db}"

    if not @session.userdata('customer')
      @redirect "/travel/#{$db}/login?url=/travel/#{$db}/booking/#{$id}"

    @db = @load.database($db, true)
    @db.initialize =>

      @db.from 'hotel'
      @db.where 'id', $id
      @db.get ($err, $hotel) =>

        @load.view "travel/booking",
          db:     $db
          hotel:  $hotel.row()
          form:
            action: "/travel/#{$db}/confirm/#{$id}"
            attrs:
                    class:      'form'
            hidden:
                    hotelId:    $id
            submit:
                    name:       'submit'
                    value:      'Proceed'
                    class:      'btn btn-primary'
            cancel:
                    name:       'cancel'
                    value:      'Cancel'
                    class:      'btn'
          checkinDate:
                    name:       'checkinDate'
                    class:      'datepicker'
          checkoutDate:
                    name:       'checkoutDate'
                    class:      'datepicker'
          control_label:
                    class:      'control-label'
          beds:
                    name:       'beds'
                    options:
                                '1':    'One king-size bed'
                                '2':    'Two double beds'
                                '3':    'Three beds'
                    selected:   ''
                    extras:     ''
          smoking:
                    name:       'smoking'
                    id:         'smoking'
                    value:      true
                    checked:    false
          nonSmoking:
                    name:       'smoking'
                    id:         'non-smoking'
                    value:      false
                    checked:    true
          cardNumber:
                    name:       'cardNumber'
                    id:         'cardNumber'
                    value:      ''
          cardName:
                    name:       'cardName'
                    id:         'cardName'
                    value:      ''
                    maxlength:  '40'
          cardMonth:
                    name:       'cardMonth'
                    options:
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
                    selected:   ''
                    extras:     'style="width:5.5em"'
          cardYear:
                    name:       'cardYear'
                    options:
                                '1':    '2012'
                                '2':    '2013'
                                '3':    '2014'
                                '4':    '2015'
                                '5':    '2016'
                    selected:   ''
                    extras:     'style="width:5.5em"'






  ## --------------------------------------------------------------------

  #
  # Confirm the booking
  #
  #   @access	public
  #   @return	void
  #
  confirm: ($db, $id) ->

    if @input.get_post('cancel')? then @redirect "/travel/#{$db}"

    if not @session.userdata('customer')
      @redirect "/travel/#{$db}/login?url=/travel/#{$db}/confirm/#{$id}"

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
          card:             @input.post('card')
          cardName:         @input.post('cardName')
          cardExpiryMonth:  parseInt(@input.post('cardExpiryMonth'))
          cardExpiryYear:   parseInt(@input.post('cardExpiryYear'))
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
  book: ($db, $id) ->

    if not @session.userdata('customer')
      @redirect "/travel/#{$db}/login?url=/travel/#{$db}/book/#{$id}"

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