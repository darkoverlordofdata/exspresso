#+--------------------------------------------------------------------+
#| home.coffee
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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	  Home page
#
#
#
require APPPATH+'core/PublicController.coffee'

class Home extends application.core.PublicController

  #
  # Index
  #
  # Display the home page
  #
  #   @access	public
  # @return [Void]  #
  indexAction: ->

    @db.from 'blog'
    @db.where 'id', '1'
    @db.get ($err, $blog) =>

      @template.view 'home_page', $err ||
        blog: $blog.row()


#
# Export the class:
#
module.exports = Home

# End of file home.coffee
# Location: .application/controllers/home.coffee