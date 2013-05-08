#+--------------------------------------------------------------------+
#| test.coffee
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
#	  Unit Test page
#
require APPPATH+'core/PublicController.coffee'

module.exports = class Test extends application.core.PublicController

  constructor: ($args...) ->
    super $args...
    @load.library 'Unit' # load unit testing lib


  #
  # Index Action
  #
  # Display demo unit test
  #
  # @return [Void]
  #
  indexAction: ->

    @theme.view 'test',
      test: @unit.run(1+1, 2, 'one_plus_one', 'Demo unit test: Adds one plus one<br /><pre><code>1 + 1 = 2</code></pre>')

  #
  # Decode Action
  #
  # Show the decode test
  #
  # @return [Void]
  #
  decodeAction: ->

    $result = @security.xssClean('<fred name="&"')
    console.log '--------------------------------'
    log_message 'debug', $result
    console.log '--------------------------------'
    $expected = '&amp;'

    @theme.view 'test',

      test: @unit.run($result, $expected, 'entity_decode', "Entity Decode<br /><pre><code>&amp; = &amp;amp;</code></pre>")


  #
  # Input Action
  #
  # Show the Input test
  #
  # @return [Void]
  #
  inputAction: ->

    # <a href="javascript:alert('!')">

    @theme.view 'input',
      input_field: @security.xssClean(@input.post('input_field'))

