#+--------------------------------------------------------------------+
#| Wines.coffee
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
#	Class Wine
#
module.exports = class modules.wine.models.Wines extends system.core.Model

  table: 'wines'
  #
  # Initialize Wines Model
  #
  constructor: ($args...) ->

    super $args...
    log_message 'debug', 'Wines Model Initialized'


  #
  # Get list of wines
  #
  # @param  [Function] next  async function
  # @return [Void]
  #
  getList: ($next) ->
    @db.from @table
    @db.orderBy 'name'
    @db.get ($err, $data) ->
      return $next($err) if $err?
      $next null, $data.result()


  #
  # Get wine by id
  #
  # @param  [Integer] id wine id
  # @param  [Function] next  async function
  # @return [Void]
  #
  getById: ($id, $next) ->
    @db.from @table
    @db.where 'id', $id
    @db.get ($err, $data) ->
      return $next($err) if $err?
      $next null, $data.row()



  #
  # Get wine by name
  #
  # @param  [Integer] like  wine name pattern
  # @param  [Function] next  async function
  # @return [Void]
  #
  getByName: ($like, $next) ->
    @db.from @table
    @db.like 'name', "%#{$like}%"
    @db.get ($err, $data) ->
      return $next($err) if $err?
      $next null, $data.result()

  #
  # Delete wine
  #
  # @param  [Integer] id wines id
  # @param  [Function] next  async function
  # @return [Void]
  #
  delete: ($id, $next) ->
    @db.where 'id', $id
    @db.delete @table, $next

  #
  # Create new wine
  #
  # @param  [Integer] data wines document
  # @param  [Function] next  async function
  # @return [Void]
  #
  create: ($data, $next) ->

    @db.insert @table, $data, ($err) =>
      return $next($err) if $err?

      @db.insertId ($err, $id) ->
        return $next($err) if $err?
        $next null, $id

  #
  # Update wine
  #
  # @param  [Integer] id wines id
  # @param  [Integer] doc wines document
  # @param  [Function] next  async function
  # @return [Void]
  #
  update: ($id, $data, $next) ->
    @db.where 'id', $id
    @db.update @table, $data, $next


  #
  # Install the Wine Module data
  #
  # @return [Void]
  #
  install: () ->

    @load.dbforge() unless @dbforge?
    @queue @install_wines


  #
  # Step 1:
  # Install Check
  # Create the wines table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_wines: ($next) =>

    #
    # if table doesn't exist, create and load initial data
    #
    @dbforge.createTable @table, $next, ($table) ->
      $table.addKey 'id', true
      $table.addField
        id:
          type: 'INT', constraint: 5, unsigned: true, auto_increment: true
        name:
          type: 'VARCHAR', constraint: 45
        year:
          type: 'VARCHAR', constraint: 45
        grapes:
          type: 'VARCHAR', constraint: 45
        country:
          type: 'VARCHAR', constraint: 45
        region:
          type: 'VARCHAR', constraint: 45
        description:
          type: 'TEXT'
        picture:
          type: 'VARCHAR', constraint: 256


      $table.addData
        id: 1
        name: 'CHATEAU DE SAINT COSME'
        year: '2009'
        grapes: 'Grenache / Syrah'
        country:  'France'
        region: 'Southern Rhone / Gigondas'
        description:  "The aromas of fruit and spice give one a hint of the light drinkability of this lovely wine, which makes an excellent complement to fish dishes."
        picture:  'saint_cosme.jpg'
      $table.addData
        id: 2
        name: 'LAN RIOJA CRIANZA'
        year: '2006'
        grapes: 'Tempranillo'
        country:  'Spain'
        region: 'Rioja'
        description:  "A resurgence of interest in boutique vineyards has opened the door for this excellent foray into the dessert wine market. Light and bouncy, with a hint of black truffle, this wine will not fail to tickle the taste buds."
        picture:  'lan_rioja.jpg'
      $table.addData
        id: 3
        name: 'MARGERUM SYBARITE'
        year: '2010'
        grapes: 'Sauvignon Blanc'
        country:  'USA'
        region: 'California Central Cost'
        description:  "The cache of a fine Cabernet in ones wine cellar can now be replaced with a childishly playful wine bubbling over with tempting tastes of\nblack cherry and licorice. This is a taste sure to transport you back in time."
        picture:  'margerum.jpg'
      $table.addData
        id: 4
        name: 'OWEN ROE \"EX UMBRIS\"'
        year: '2009'
        grapes: 'Syrah'
        country:  'USA'
        region: 'Washington'
        description:  "A one-two punch of black pepper and jalapeno will send your senses reeling, as the orange essence snaps you back to reality. Dont miss\nthis award-winning taste sensation."
        picture:  'ex_umbris.jpg'
      $table.addData
        id: 5
        name: 'REX HILL'
        year: '2009'
        grapes: 'Pinot Noir'
        country:  'USA'
        region: 'Oregon'
        description:  "One cannot doubt that this will be the wine served at the Hollywood award shows, because it has undeniable star power. Be the first to catch\nthe debut that everyone will be talking about tomorrow."
        picture:  'rex_hill.jpg'
      $table.addData
        id: 6
        name: 'VITICCIO CLASSICO RISERVA'
        year: '2007'
        grapes: 'Sangiovese Merlot'
        country:  'Italy'
        region: 'Tuscany'
        description:  "Though soft and rounded in texture, the body of this wine is full and rich and oh-so-appealing. This delivery is even more impressive when one takes note of the tender tannins that leave the taste buds wholly satisfied."
        picture:  'viticcio.jpg'
      $table.addData
        id: 7
        name: 'CHATEAU LE DOYENNE'
        year: '2005'
        grapes: 'Merlot'
        country:  'France'
        region: 'Bordeaux'
        description:  "Though dense and chewy, this wine does not overpower with its finely balanced depth and structure. It is a truly luxurious experience for the\nsenses."
        picture:  'le_doyenne.jpg'
      $table.addData
        id: 8
        name: 'DOMAINE DU BOUSCAT'
        year: '2009'
        grapes: 'Merlot'
        country:  'France'
        region: 'Bordeaux'
        description:  "The light golden color of this wine belies the bright flavor it holds. A true summer wine, it begs for a picnic lunch in a sun-soaked vineyard."
        picture:  'bouscat.jpg'
      $table.addData
        id: 9
        name: 'BLOCK NINE'
        year: '2009'
        grapes: 'Pinot Noir'
        country:  'USA'
        region: 'California'
        description:  "With hints of ginger and spice, this wine makes an excellent complement to light appetizer and dessert fare for a holiday gathering."
        picture:  'block_nine.jpg'
      $table.addData
        id: 10
        name: 'DOMAINE SERENE'
        year: '2007'
        grapes: 'Pinot Noir'
        country:  'USA'
        region: 'Oregon'
        description:  "Though subtle in its complexities, this wine is sure to please a wide range of enthusiasts. Notes of pomegranate will delight as the nutty finish completes the picture of a fine sipping experience."
        picture:  'domaine_serene.jpg'
      $table.addData
        id: 11
        name: 'BODEGA LURTON'
        year: '2011'
        grapes: 'Pinot Gris'
        country:  'Argentina'
        region: 'Mendoza'
        description:  "Solid notes of black currant blended with a light citrus make this wine an easy pour for varied palates."
        picture:  'bodega_lurton.jpg'
      $table.addData
        id: 12
        name: 'LES MORIZOTTES'
        year: '2009'
        grapes: 'Chardonnay'
        country:  'France'
        region: 'Burgundy'
        description:  "Breaking the mold of the classics, this offering will surprise and undoubtedly get tongues wagging with the hints of coffee and tobacco in\nperfect alignment with more traditional notes. Breaking the mold of the classics, this offering will surprise and\nundoubtedly get tongues wagging with the hints of coffee and tobacco in\nperfect alignment with more traditional notes. Sure to please the late-night crowd with the slight jolt of adrenaline it brings."
        picture:  'morizottes.jpg'

