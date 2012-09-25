#+--------------------------------------------------------------------+
#| welcome.coffee
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
#	Welcome
#
# This is the default controller
#

module.exports = class Welcome extends exspresso.Controller

  constructor: () ->

  #
  # index
  #
  #   @param {Object} server request object
  #   @param {Object} server response object
  #
  index: ->

    @render 'welcome_message'


  #
  # about
  #
  #   @param {Object} server request object
  #   @param {Object} server response object
  #   @param {Function} next middleware
  #   @param {String} id
  #
  about: (id) ->

    @render 'about'
      id: id

