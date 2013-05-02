#+--------------------------------------------------------------------+
#| welcome.coffee
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
#	Welcome Controller
#
# This is the default controller
#

module.exports = class Welcome extends system.core.Controller

  #
  # Index
  #
  # Demo welcome page
  #
  # @access	public
  # @return [Void]
  #
  indexAction: ->

    #@load.view 'welcome_message', site_name: config_item('site_name')
    @load.library 'parser'
    #@parser.parse 'welcome_message', site_name: config_item('site_name')
    @parser.parse 'welcome_message.html', site_name: config_item('site_name')

