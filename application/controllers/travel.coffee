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

    super()
    @load.model 'Travel'
    @Travel.initialize()

  ## --------------------------------------------------------------------

  #
  # Intro
  #
  # Demo hotel app intro
  #
  #   @access	public
  #   @return	void
  #
  intro: ->

    @render "travel/intro"

  ## --------------------------------------------------------------------

  #
  # Search
  #
  # Search for hotels
  #
  #   @access	public
  #   @return	void
  #
  search: ->

    query = @Travel.Booking.findAll(where: {state: "BOOKED"})
    query.on "success", (bookings) =>

      @render "travel/main",
        bookings: bookings

  ## --------------------------------------------------------------------

  #
  # Hotels
  #
  # Display search results
  #
  #   @access	public
  #   @return	void
  #
  hotels: ->

    query = @Travel.Hotel.findAll(where: ["name like ?", "%" + @req.param("searchString") + "%"])
    query.on "success", ($result) =>

      @render "travel/hotels",
        hotels: $result

  ## --------------------------------------------------------------------

  #
  # Hotel
  #
  # Display one hotel
  #
  #   @access	public
  #   @param string   The hotel record id#
  #   @return	void
  #
  hotel: ($id) ->

    query = @Travel.Hotel.find(parseInt($id, 10))
    query.on "success", ($result) =>

      @render "travel/detail",
        hotel: $result

#
# Export the class:
#
module.exports = Travel

# End of file Travel.coffee
# Location: .application/controllers/Travel.coffee