#+--------------------------------------------------------------------+
#| Table.coffee
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
#	Table - Main application
#
#
#
class exports.Table

  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  #   Initialize metadata
  #
  #   @access	public
  #   @param object database
  #   @return	void
  #
  constructor: (@db) ->

    #
    # fix names so that reserved words, etc. will be accepted
    #
    @name = @_escape(@name)
    $columns = {}
    for $name, $data of @columns
      $columns[@_escape($name)] = $data
    @columns = $columns

    @list = []
    for $name of @columns
      @list.push $name


  ## --------------------------------------------------------------------

  #
  # Create
  #
  #   Create the table in the database
  #
  #   @access	public
  #   @param function migration callback
  #   @return	void
  #
  create: ($callback) =>
    @db.createTable @name, @columns, $callback

  ## --------------------------------------------------------------------

  #
  # Drop
  #
  #   Drops the table from the database
  #
  #   @access	public
  #   @param function migration callback
  #   @return	void
  #
  drop: ($callback) =>
    @db.dropTable @name, $callback

  ## --------------------------------------------------------------------

  #
  # Insert
  #
  #   Inserts a row or rows of data into the table
  #
  #   @access	public
  #   @param array data to add to the table
  #   @param function migration callback
  #   @return	void
  #
  insert: ($data, $callback) =>

    if not Array.isArray($data[0])
      $data = [$data]


    for $row in $data
      if @list.length isnt $row.length
        return $callback('Expected '+@list.length+' columns, found '+$row.length)
      else
        @db.insert @name, @list, $row, ($err) ->
          if $err then return $callback($err)

    $callback()

  ## --------------------------------------------------------------------

  #
  # Escape
  #
  #   Escape an identifier as required by the db driver
  #
  #   @access	private
  #   @param string value to escape
  #   @return	void
  #
  _escape: ($value) ->

    switch @db.connection.config.driver

      when 'pg'     then '"' + $value + '"'
      when 'mysql'  then '`' + $value + '`'
      else $value


# End of file Table.coffee
# Location: ./Table.coffee