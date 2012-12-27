#+--------------------------------------------------------------------+
#| 004_Travel_add_hotels_data.coffee
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
#	004_Travel_add_hotels_data - Migration
#
#
#
class Migration_Travel_add_hotels_data extends CI_Migration

  seq: '004'
  description: 'Initialize the hotels data'
  table: 'hotel'

  up: ($callback) ->

    @db.insert_batch @table, @data, $callback

  down: ($callback) ->

    @db.truncate @table, $callback

  data:
    [
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

module.exports = Migration_Travel_add_hotels_data

# End of file 004_Travel_add_hotels_data.coffee
# Location: .modules/travel/migrations/004_Travel_add_hotels_data.coffee