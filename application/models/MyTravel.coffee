#+--------------------------------------------------------------------+
#| MyTravel.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Darklite is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	MyTravel - Main application
#
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{parse_url} = require(FCPATH + 'pal')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')

ActiveRecord    = require('mysql-activerecord')         # MySQL ActiveRecord Adapter for Node.js
CI_Model        = require(BASEPATH + 'core/Model')      # Exspresso Model Base Class


class Travel extends CI_Model

  _db = null
  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  # Connect to and initialize database
  #
  # @return 	nothing
  #
  constructor: ->

    ## --------------------------------------------------------------------

  initialize: ->

    $connection = parse_url(@config._config.mysql_url)
    @_db = new ActiveRecord.Adapter(
      server:     $connection.host
      username:   $connection.user
      password:   $connection.pass
      database:   $connection.path
    )

  booked: ($render) ->

    @_db.where(state: "BOOKED").get('Booking', $render)


  hotels: ($name, $render) ->

    @_db.where("name like '%%'").get('Hotel', $render)
    #@_db.where("name like %#{$name}%").get('Hotels', $render)


  hotel: ($id, $render) ->

    @_db.where(id: $id).get('Hotel', $render)

## --------------------------------------------------------------------

#
# Export the class:
#
module.exports = Travel


# End of file MyTravel.coffee
# Location: ./MyTravel.coffee