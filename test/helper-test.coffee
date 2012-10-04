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
#	Helper Tests
#
#   Tests for helper.coffee
#
#
helper = require('../helper') #->  this is the module being tested  <-#

class helper._classes.ScoobyDoo

  whereAreYou: ->

#? -------------------------------------------------------------------+
describe 'helper', ->

  #? -----------------------------------------------------------------+
  describe 'array_merge', ->

    #! ---------------------------------------------------------------+
    it 'should return return all 4 names', ->

      helper.array_merge({fred: 'Frank Welker'}, {shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}).should.eql {fred: 'Frank Welker', shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}


  #? -----------------------------------------------------------------+
  describe 'array_shift', ->

    #! ---------------------------------------------------------------+
    it "should return return first in ['shaggy', 'velma', 'daphne']", ->

      helper.array_shift(['shaggy', 'velma', 'daphne']).should.equal 'shaggy'


  #? -----------------------------------------------------------------+
  describe 'array_unshift', ->

    #! ---------------------------------------------------------------+
    it "should add 'shaggy' to ['velma', 'daphne']", ->

      helper.array_unshift(['velma', 'daphne'], 'shaggy').should.equal 3


  #? -----------------------------------------------------------------+
  describe 'class_exists', ->

    #! ---------------------------------------------------------------+
    it "should return true for ScoobyDoo", ->

      helper.class_exists('ScoobyDoo').should.equal true

    it "should return false for DynoMut", ->

      helper.class_exists('DynoMut').should.equal false


  #? -----------------------------------------------------------------+
  describe 'count', ->

    #! ---------------------------------------------------------------+
    it "should return 3 for ['shaggy','velma','daphne']", ->

      helper.count(['shaggy','velma','daphne']).should.equal 3

    #! ---------------------------------------------------------------+
    it "should return 3 for {shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}", ->

      helper.count({shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}).should.equal 3


  #? -----------------------------------------------------------------+
  describe 'dirname', ->

    #! ---------------------------------------------------------------+
    it "should return current folder", ->

      helper.dirname(__filename).should.equal process.cwd()+'/test'


  #? -----------------------------------------------------------------+
  describe 'explode', ->

    #! ---------------------------------------------------------------+
    it "should return  ['shaggy','velma','daphne'] for 'shaggy,velma,daphne'", ->

      helper.explode(',', 'shaggy,velma,daphne').should.eql ['shaggy','velma','daphne']


  #? -----------------------------------------------------------------+
  describe 'file_exists', ->

    #! ---------------------------------------------------------------+
    it "should return true for current file", ->

      helper.file_exists(__filename).should.equal true



  #? -----------------------------------------------------------------+
  describe 'implode', ->

    #! ---------------------------------------------------------------+
    it "should return 'shaggy,velma,daphne' for ['shaggy','velma','daphne']", ->

      helper.implode(',', ['shaggy','velma','daphne']).should.equal 'shaggy,velma,daphne'



  #? -----------------------------------------------------------------+
  describe 'in_array', ->

    #! ---------------------------------------------------------------+
    it 'should return false when not found', ->

      helper.in_array('fred', ['shaggy', 'velma', 'daphne']).should.equal false

    #! ---------------------------------------------------------------+
    it 'should return the index when found', ->

      helper.in_array('fred', ['shaggy', 'velma', 'fred', 'daphne']).should.equal 2


  #? -----------------------------------------------------------------+
  describe "is_array", ->

    #! ---------------------------------------------------------------+
    it "should return true for an array", ->

      helper.is_array(['shaggy', 'velma', 'daphne']).should.equal.true

    #! ---------------------------------------------------------------+
    it "should return false for a string", ->

      helper.is_array('shaggy, velma, daphne').should.equal.false


  #? -----------------------------------------------------------------+
  describe "is_dir", ->

    #! ---------------------------------------------------------------+
    it "should return true for ./", ->

      helper.is_dir('./').should.equal.true

    #! ---------------------------------------------------------------+
    it "should return false for ./readme.md", ->

      helper.is_dir('./readme.md').should.equal.false


  #? -----------------------------------------------------------------+
  describe "is_null", ->

    #! ---------------------------------------------------------------+
    it "should return true for a null", ->

      helper.is_null(null).should.equal.true

    #! ---------------------------------------------------------------+
    it "should return false for a string", ->

      helper.is_null('scooby').should.equal.false


  #? -----------------------------------------------------------------+
  describe "is_string", ->

    #! ---------------------------------------------------------------+
    it 'should return true for string', ->

      helper.is_string('hex girlz rule').should.equal.true

    #! ---------------------------------------------------------------+
    it 'should return false for number', ->

      helper.is_string(1).should.equal.false


  #? -----------------------------------------------------------------+
  describe "is_object", ->

    #! ---------------------------------------------------------------+
    it "should return true for an object", ->

      helper.is_object({name: 'fred'}).should.equal.true

    #! ---------------------------------------------------------------+
    it "should return false for a string", ->

      helper.is_object('fred').should.equal.false


  #? -----------------------------------------------------------------+
  describe 'ltrim', ->

    #! ---------------------------------------------------------------+
    it "should return 'Mystery Machin' for 'Mystery Machine' - 'Me'", ->

      helper.rtrim('Mystery Machine', 'Me').should.equal 'Mystery Machin'


  #? -----------------------------------------------------------------+
  describe 'realpath', ->

    #! ---------------------------------------------------------------+
    it "should return current folder", ->

      helper.realpath("./").should.equal process.cwd()


  #? -----------------------------------------------------------------+
  describe 'rtrim', ->

    #! ---------------------------------------------------------------+
    it "should return 'ystery Machine' for 'Mystery Machine' - 'Me'", ->

      helper.ltrim('Mystery Machine', 'Me').should.equal 'ystery Machine'


  #? -----------------------------------------------------------------+
  describe 'str_replace', ->

    #! ---------------------------------------------------------------+
    it "should return 'Hex Girls'", ->

      helper.str_replace('Girlz', 'Girls', 'Hex Girlz').should.equal 'Hex Girls'


  #? -----------------------------------------------------------------+
  describe 'strpos', ->

    #! ---------------------------------------------------------------+
    it "should find the first 'oo'", ->

      helper.strpos('ScoobyDoo', 'oo').should.equal 2

    it "should find the next 'oo'", ->

      helper.strpos('ScoobyDoo', 'oo', 3).should.equal 7



  #? -----------------------------------------------------------------+
  describe 'strrchr', ->

    #! ---------------------------------------------------------------+
    it "should find '*daphne'", ->

      helper.strrchr('shaggy*velma*daphne', '*').should.equal "*daphne"

    it "should also find '*daphne'", ->

      helper.strrchr('shaggy*velma*daphne', 42).should.equal "*daphne"



  #? -----------------------------------------------------------------+
  describe 'strrpos', ->

    #! ---------------------------------------------------------------+
    it "should find the last 'oo'", ->

      helper.strrpos('ScoobyDoo', 'oo').should.equal 7


  #? -----------------------------------------------------------------+
  describe 'strtolower', ->

    #! ---------------------------------------------------------------+
    it "should return 'mystery machine'", ->

      helper.strtolower('Mystery Machine').should.equal 'mystery machine'


  #? -----------------------------------------------------------------+
  describe 'substr', ->

    #! ---------------------------------------------------------------+
    it "should return", ->

      helper.substr('shaggy', 1).should.equal 'haggy'

    it "should return", ->

      helper.substr('shaggy', 1, 3).should.equal 'hag'


  #? -----------------------------------------------------------------+
  describe 'trim', ->

    #! ---------------------------------------------------------------+
    it "should return 'ystery Machin' for 'Mystery Machine' - 'Me'", ->

      helper.trim('Mystery Machine', 'Me').should.equal 'ystery Machin'


  #? -----------------------------------------------------------------+
  describe 'ucfirst', ->

    #! ---------------------------------------------------------------+
    it "should return 'Mystery' for 'mystery'", ->

      helper.ucfirst('mystery').should.equal 'Mystery'





# End of file test-helper.coffee
# Location: ./test-helper.coffee