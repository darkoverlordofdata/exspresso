#+--------------------------------------------------------------------+
#| HotelModel.coffee
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
#	Class HotelModel
#
module.exports = class modules.travel.models.TravelModel

  #
  # Get booked rooms
  #
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getBooked: ($next) ->

    @db.select ['travel_hotels.name', 'travel_hotels.address', 'travel_hotels.city', 'travel_hotels.state', 'travel_bookings.checkinDate', 'travel_bookings.checkoutDate', 'travel_bookings.id']
    @db.from 'travel_bookings'
    @db.where 'travel_bookings.state', 'BOOKED'
    @db.join 'travel_hotels', 'travel_hotels.id = travel_bookings.hotel','inner'
    @db.get ($err, $bookings) ->

      return $next($err) if $err?
      $next null, $bookings.result()

  #
  # Get hotel count
  #
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getCount: ($next) ->

    @db.countAll 'travel_hotels', $next


  #
  # Get hotels like pattern
  #
  # @param  [String]  $like search pattern
  # @param  [Integer] $pageSize number of hits to display
  # @param  [Integer] $start start at row
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getLike: ($like, $pageSize, $start, $next) ->

    @db.from 'travel_hotels'
    @db.like 'name', "%#{$like}%"
    @db.limit $pageSize, $start
    @db.get ($err, $hotels) ->

      return $next($err) if $err?
      $next null, $hotels.result()


  #
  # Get hotel by id
  #
  # @param  [Integer] $id hotel id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getById: ($id, $next) ->

    @db.from 'travel_hotels'
    @db.where 'id', $id
    @db.get ($err, $hotel) ->

      return $next($err) if $err?
      $next null, $hotel.row()

  #
  # Get booking by id
  #
  # @param  [Integer] $id hotel id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getBookingById: ($id, $next) ->

    @db.from 'travel_bookings'
    @db.where 'id', $id
    @db.get ($err, $booking) ->

      return $next($err) if $err?
      $next null, $booking.row()

  #
  # Confirm booking
  #
  # @param  [Integer] $id booking id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  confirmBooking: ($id, $next) ->
    @db.where 'id', $id
    @db.update 'travel_bookings', state: 'BOOKED', $next

  #
  # Cancel booking
  #
  # @param  [Integer] $id booking id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  cancelBooking: ($id, $next) ->
    @db.where 'id', $id
    @db.update 'travel_bookings', state: 'CANCELLED', $next


  #
  # Create booking
  #
  # @param  [Integer] $data booking data
  # @param  [Function] $next  async function
  # @return [Void]
  #
  createBooking: ($data, $next) ->

    $data.state = "CREATED"
    @db.insert 'travel_bookings', $data, ($err) =>
      return $next($err) if $err?

      @db.insertId ($err, $id) ->
        return $next($err) if $err?
        $next null, $id


  login: ($name, $pwd) ->

  logout: () ->

  #
  # Install the Hotel Module data
  #
  # @return [Void]
  #
  install: () ->

    @load.dbforge() unless @dbforge?
    @queue @install_hotels
    @queue @install_customers
    @queue @install_bookings

  #
  # Step 1:
  # Install Check
  # Create the hotel table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_hotels: ($next) =>

    #
    # if hotels doesn't exist, create and load initial data
    #
    @dbforge.createTable 'travel_hotels', $next, ($table) ->
      $table.addKey 'id', true
      $table.addField
        id:
          type: 'INT', constraint: 5, unsigned: true, auto_increment: true
        price:
          type: 'INT'
        name:
          type: 'VARCHAR', constraint: 255
        address:
          type: 'VARCHAR', constraint: 255
        city:
          type: 'VARCHAR', constraint: 255
        state:
          type: 'VARCHAR', constraint: 255
        zip:
          type: 'VARCHAR', constraint: 255
        country:
          type: 'VARCHAR', constraint: 255


      $table.addData [
        {id: 1, price: 199, name: "Westin Diplomat", address: "3555 S. Ocean Drive", city: "Hollywood", state: "FL", zip: "33019", country: "USA"},
        {id: 2, price: 60, name: "Jameson Inn", address: "890 Palm Bay Rd NE", city: "Palm Bay", state: "FL", zip: "32905", country: "USA"},
        {id: 3, price: 199, name: "Chilworth Manor", address: "The Cottage, Southampton Business Park", city: "Southampton", state: "Hants", zip: "SO16 7JF", country: "UK"},
        {id: 4, price: 120, name: "Marriott Courtyard", address: "Tower Place, Buckhead", city: "Atlanta", state: "GA", zip: "30305", country: "USA"},
        {id: 5, price: 180, name: "Doubletree", address: "Tower Place, Buckhead", city: "Atlanta", state: "GA", zip: "30305", country: "USA"},
        {id: 6, price: 450, name: "W hotel", address: "Union Square, Manhattan", city: "NY", state: "NY", zip: "10011", country: "USA"},
        {id: 7, price: 450, name: "W hotel", address: "Lexington Ave, Manhattan", city: "NY", state: "NY", zip: "10011", country: "USA"},
        {id: 8, price: 250, name: "hotel Rouge", address: "1315 16th Street NW", city: "Washington", state: "DC", zip: "20036", country: "USA"},
        {id: 9, price: 300, name: "70 Park Avenue hotel", address: "70 Park Avenue", city: "NY", state: "NY", zip: "10011", country: "USA"},
        {id: 10, price: 300, name: "Conrad Miami", address: "1395 Brickell Ave", city: "Miami", state: "FL", zip: "33131", country: "USA"},
        {id: 11, price: 80, name: "Sea Horse Inn", address: "2106 N Clairemont Ave", city: "Eau Claire", state: "WI", zip: "54703", country: "USA"},
        {id: 12, price: 90, name: "Super 8 Eau Claire Campus Area", address: "1151 W Macarthur Ave", city: "Eau Claire", state: "WI", zip: "54701", country: "USA"},
        {id: 13, price: 160, name: "Marriot Downtown", address: "55 Fourth Street", city: "San Francisco", state: "CA", zip: "94103", country: "USA"},
        {id: 14, price: 200, name: "Hilton Diagonal Mar", address: "Passeig del Taulat 262-264", city: "Barcelona", state: "Catalunya", zip: "08019", country: "Spain"},
        {id: 15, price: 210, name: "Hilton Tel Aviv", address: "Independence Park", city: "Tel Aviv", state: "", zip: "63405", country: "Israel"},
        {id: 16, price: 240, name: "InterContinental Tokyo Bay", address: "Takeshiba Pier", city: "Tokyo", state: "", zip: "105", country: "Japan"},
        {id: 17, price: 130, name: "hotel Beaulac", address: " Esplanade L�opold-Robert 2", city: "Neuchatel", state: "", zip: "2000", country: "Switzerland"},
        {id: 18, price: 140, name: "Conrad Treasury Place", address: "William & George Streets", city: "Brisbane", state: "QLD", zip: "4001", country: "Australia"},
        {id: 19, price: 230, name: "Ritz Carlton", address: "1228 Sherbrooke St", city: "West Montreal", state: "Quebec", zip: "H3G1H6", country: "Canada"},
        {id: 20, price: 460, name: "Ritz Carlton", address: "Peachtree Rd, Buckhead", city: "Atlanta", state: "GA", zip: "30326", country: "USA"},
        {id: 21, price: 220, name: "Swissotel", address: "68 Market Street", city: "Sydney", state: "NSW", zip: "2000", country: "Australia"},
        {id: 22, price: 250, name: "Meli� White House", address: "Albany Street", city: "Regents Park London", state: "", zip: "NW13UP", country: "Great Britain"},
        {id: 23, price: 210, name: "hotel Allegro", address: "171 West Randolph Street", city: "Chicago", state: "IL", zip: "60601", country: "USA"}
      ]

  #
  # Step 2:
  # Install Check
  # Create the customer table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_customers: ($next) =>

    #
    # if customers doesn't exist, create and load initial data
    #
    @dbforge.createTable 'travel_customers', $next, ($table) ->
      $table.addKey 'id', true
      $table.addField
        id:
          type: 'INT', constraint: 5, unsigned: true, auto_increment: true
        username:
          type: 'VARCHAR', constraint: 255
        password:
          type: 'VARCHAR', constraint: 255
        name:
          type: 'VARCHAR', constraint: 255

      $table.addData [
        {id: 1, username: "keith", password: "", name: "Keith"}
        {id: 2, username: "erwin", password: "", name: "Erwin"}
        {id: 3, username: "jeremy", password: "", name: "Jeremy"}
        {id: 4, username: "scott", password: "", name: "Scott"}
      ]

  #
  # Step 3:
  # Install Check
  # Create the bookings table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_bookings: ($next) =>

    #
    # if bookings doesn't exist, create it
    #
    @dbforge.createTable 'travel_bookings', $next, ($table) ->
      $table.addKey 'id', true
      $table.addField
        id:
          type: 'INT', constraint: 5, unsigned: true, auto_increment: true
        email:
          type: 'VARCHAR', constraint: 255
        username:
          type: 'VARCHAR', constraint: 255
        hotel:
          type: 'INT'
        checkinDate:
          type: 'DATETIME'
        checkoutDate:
          type: 'DATETIME'
        creditCard:
          type: 'VARCHAR', constraint: 255
        creditCardName:
          type: 'VARCHAR', constraint: 255
        creditCardExpiryMonth:
          type: 'INT'
        creditCardExpiryYear:
          type: 'INT'
        smoking:
          type: 'VARCHAR', constraint: 255
        beds:
          type: 'INT'
        amenities:
          type: 'VARCHAR', constraint: 255
        state:
          type: 'VARCHAR', constraint: 255




