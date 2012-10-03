#+--------------------------------------------------------------------+
#| test-helper.coffee
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
#	test-helper
#
#   Tests for helper.coffee
#
#
helper = require('../helper')
describe 'helper', ->



  describe "is_string", ->

    it 'should return true for string', ->

      helper.is_string('test string').should.equal.true

    it 'should return false for number', ->

      helper.is_string(1).should.equal.false




  describe 'in_array', ->

    it 'should return false when not found', ->

      helper.in_array('fred', ['barney', 'wilma', 'betty']).should.equal false

    it 'should return index when found', ->

      helper.in_array('fred', ['barney', 'wilma', 'fred', 'betty']).should.equal 2




  describe 'strtolower', ->

    it "should return 'a' for 'A'", ->

      helper.strtolower('A').should.equal 'a'

# End of file test-helper.coffee
# Location: ./test-helper.coffee