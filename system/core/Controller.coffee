#+--------------------------------------------------------------------+
#| Controller.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#
#	Controller base class
#
class Controller

  #
  #	Create new controller
  #
  #	@param	object	http request object
  #	@param	object	http response object
  # @returns nothing
  #
  constructor: (@req, @res) ->

  #
  #	Render the controller
  #
  #	@param	string	view template file name
  #	@param	object	context for template engine
  # @returns nothing
  #
  render: (view, data) ->
    @res.render view, data
    return

module.exports = Controller