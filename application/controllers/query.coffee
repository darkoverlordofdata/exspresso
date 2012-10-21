#+--------------------------------------------------------------------+
#| query.coffee
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
#	Query Controller Class
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{parse_url} = require(FCPATH + 'lib')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')

CI_Controller   = require(BASEPATH + 'core/Controller') # Exspresso Controller Base Class

mysql = require('mysql')
pg = require('pg')

class Query extends CI_Controller

## --------------------------------------------------------------------

#
# Load the configured database
#
#   @access	public
#   @return	void
#

  _pg:    null
  _mysql: null

  constructor: ->

    super()
    $settings = parse_url(@config._config.mysql_url)

    @_mysql = new mysql.createClient
      host: $settings.host
      port: $settings.port
      user: $settings.user
      password: $settings.pass
      database: $settings.path.substr(1)

    pg.connect get_config().db_url, ($err, $client) =>

      if $err
        console.log $err
        @res.send $err, 500

      @_pg = $client
      console.log $client
      console.log @_pg



  mysql: ->


    @_mysql.query 'SELECT * FROM hotel', ($err, $results, $fields) =>

      if $err
        console.log $err
        @res.send $err, 500

      @load.view 'query_result',
        hotels: $results

  pg: ->

    @_pg.query 'SELECT * FROM "Hotel"', ($err, $results) =>

      if $err
        console.log $err
        @res.send $err, 500

      console.log $results
      @load.view 'query_result',
        hotels: $results.rows



module.exports = Query

# End of file query.coffee
# Location: ./query.coffee