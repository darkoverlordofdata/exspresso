#+--------------------------------------------------------------------+
#| pal-pal.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	PHP Abstraction Layer Tests
#
#   Tests for pal.coffee
#
#
pal = require('../pal') #->  this is the module being tested  <-#

## --------------------------------------------------------------------

# Test class for class_exists:

class pal._classes.ScoobyDoo

  whereAreYou: ->

#? -------------------------------------------------------------------+
describe 'pal', ->

  #? -----------------------------------------------------------------+
  describe 'array_merge', ->

    #! ---------------------------------------------------------------+
    it 'should return return all 4 names', ->

      pal.array_merge({fred: 'Frank Welker'}, {shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}).should.eql {fred: 'Frank Welker', shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}


  #? -----------------------------------------------------------------+
  describe 'array_shift', ->

    #! ---------------------------------------------------------------+
    it "should return return first in ['shaggy', 'velma', 'daphne']", ->

      pal.array_shift(['shaggy', 'velma', 'daphne']).should.equal 'shaggy'



  #? -----------------------------------------------------------------+
  describe 'array_slice', ->

    #! ---------------------------------------------------------------+
    it "should return return ['velma','fred']", ->

      pal.array_slice(['shaggy', 'velma', 'fred', 'daphne'], 1, 2).should.eql ['velma','fred']




  #? -----------------------------------------------------------------+
  describe 'array_splice', ->

    #! ---------------------------------------------------------------+
    it "should change the array", ->

      $array = ['shaggy', 'velma', 'fred', 'daphne']

      pal.array_splice($array, 1, 2).should.eql ['velma','fred']
      $array.should.eql ['shaggy', 'daphne']

      $array = ['shaggy', 'velma', 'fred', 'daphne']

      pal.array_splice($array, 1, 2, 'scooby').should.eql ['velma','fred']
      $array.should.eql ['shaggy', 'scooby', 'daphne']

      $array = ['shaggy', 'velma', 'fred', 'daphne']

      pal.array_splice($array, 1, 2, ['scooby', 'doo']).should.eql ['velma','fred']
      $array.should.eql ['shaggy', 'scooby', 'doo', 'daphne']

  #? -----------------------------------------------------------------+
  describe 'array_unshift', ->

    #! ---------------------------------------------------------------+
    it "should add 'shaggy' to ['velma', 'daphne']", ->

      pal.array_unshift(['velma', 'daphne'], 'shaggy').should.equal 3


  #? -----------------------------------------------------------------+
  describe 'class_exists', ->

    #! ---------------------------------------------------------------+
    it "should return true for ScoobyDoo", ->

      pal.class_exists('ScoobyDoo').should.equal true


    it "should return false for DynoMut", ->

      pal.class_exists('DynoMut').should.equal false


  #? -----------------------------------------------------------------+
  describe 'count', ->

    #! ---------------------------------------------------------------+
    it "should return 3 for ['shaggy','velma','daphne']", ->

      pal.count(['shaggy','velma','daphne']).should.equal 3


    it "should return 3 for {shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}", ->

      pal.count({shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}).should.equal 3


  #? -----------------------------------------------------------------+
  describe 'dirname', ->

    #! ---------------------------------------------------------------+
    it "should return current folder", ->

      pal.dirname(__filename).should.equal process.cwd()+'/test'


  #? -----------------------------------------------------------------+
  describe 'explode', ->

    #! ---------------------------------------------------------------+
    it "should return  ['shaggy','velma','daphne'] for 'shaggy,velma,daphne'", ->

      pal.explode(',', 'shaggy,velma,daphne').should.eql ['shaggy','velma','daphne']


  #? -----------------------------------------------------------------+
  describe 'file_exists', ->

    #! ---------------------------------------------------------------+
    it "should return true for current file", ->

      pal.file_exists(__filename).should.equal true



  #? -----------------------------------------------------------------+
  describe 'implode', ->

    #! ---------------------------------------------------------------+
    it "should return 'shaggy,velma,daphne' for ['shaggy','velma','daphne']", ->

      pal.implode(',', ['shaggy','velma','daphne']).should.equal 'shaggy,velma,daphne'



  #? -----------------------------------------------------------------+
  describe 'in_array', ->

    #! ---------------------------------------------------------------+
    it 'should return false when not found', ->

      pal.in_array('fred', ['shaggy', 'velma', 'daphne']).should.equal false


    it 'should return the index when found', ->

      pal.in_array('fred', ['shaggy', 'velma', 'fred', 'daphne']).should.equal 2


  #? -----------------------------------------------------------------+
  describe "is_array", ->

    #! ---------------------------------------------------------------+
    it "should return true for an array", ->

      pal.is_array(['shaggy', 'velma', 'daphne']).should.equal.true


    it "should return false for a string", ->

      pal.is_array('shaggy, velma, daphne').should.equal.false


  #? -----------------------------------------------------------------+
  describe "is_dir", ->

    #! ---------------------------------------------------------------+
    it "should return true for ./", ->

      pal.is_dir('./').should.equal.true


    it "should return false for ./readme.md", ->

      pal.is_dir('./readme.md').should.equal.false


  #? -----------------------------------------------------------------+
  describe "is_null", ->

    #! ---------------------------------------------------------------+
    it "should return true for a null", ->

      pal.is_null(null).should.equal.true


    it "should return false for a string", ->

      pal.is_null('scooby').should.equal.false


  #? -----------------------------------------------------------------+
  describe "is_string", ->

    #! ---------------------------------------------------------------+
    it 'should return true for string', ->

      pal.is_string('hex girlz rule').should.equal.true


    it 'should return false for number', ->

      pal.is_string(1).should.equal.false


  #? -----------------------------------------------------------------+
  describe "is_object", ->

    #! ---------------------------------------------------------------+
    it "should return true for an object", ->

      pal.is_object({name: 'fred'}).should.equal.true


    it "should return false for a string", ->

      pal.is_object('fred').should.equal.false


  #? -----------------------------------------------------------------+
  describe 'ltrim', ->

    #! ---------------------------------------------------------------+
    it "should return 'Mystery Machin' for 'Mystery Machine' - 'Me'", ->

      pal.rtrim('Mystery Machine', 'Me').should.equal 'Mystery Machin'


  #? -----------------------------------------------------------------+
  describe 'microtime', ->

    #! ---------------------------------------------------------------+
    it "should return a number > 0", ->

      pal.microtime().should.not.equal 0


  #? -----------------------------------------------------------------+
  describe 'parse_str', ->

    #! ---------------------------------------------------------------+
    it "should return a parsed query string", ->

      $extra = {}
      pal.parse_str "shaggy=norville", $extra
      $extra.should.eql {shaggy: 'norville'}


  #? -----------------------------------------------------------------+
  describe 'parse_url', ->

    #! ---------------------------------------------------------------+
    it "should return a parsed url", ->

      $url = "postgres://norville:rogers@zoinks:1620/shaggy"
      pal.parse_url($url).scheme.should.equal "postgres"
      pal.parse_url($url).host.should.equal "zoinks"
      pal.parse_url($url).port.should.equal "1620"
      pal.parse_url($url).user.should.equal "norville"
      pal.parse_url($url).pass.should.equal "rogers"
      pal.parse_url($url).path.should.equal "shaggy"



  #? -----------------------------------------------------------------+
  describe 'rawurldecode', ->

    #! ---------------------------------------------------------------+
    it "should return", ->

      pal.rawurldecode("scooby%20doo").should.equal "scooby doo"


#? -----------------------------------------------------------------+
  describe 'realpath', ->

    #! ---------------------------------------------------------------+
    it "should return current folder", ->

      pal.realpath("./").should.equal process.cwd()


  #? -----------------------------------------------------------------+
  describe 'rtrim', ->

    #! ---------------------------------------------------------------+
    it "should return 'ystery Machine' for 'Mystery Machine' - 'Me'", ->

      pal.ltrim('Mystery Machine', 'Me').should.equal 'ystery Machine'


  #? -----------------------------------------------------------------+
  describe 'str_replace', ->

    #! ---------------------------------------------------------------+
    it "should return 'Hex Girls'", ->

      pal.str_replace('Girlz', 'Girls', 'Hex Girlz').should.equal 'Hex Girls'


  #? -----------------------------------------------------------------+
  describe 'stristr', ->

    #! ---------------------------------------------------------------+
    it "should find 'doo", ->

      pal.stristr('Scooby Doo', 'doo').should.equal 'Doo'


  #? -----------------------------------------------------------------+
  describe 'strpos', ->

    #! ---------------------------------------------------------------+
    it "should find the first 'oo'", ->

      pal.strpos('ScoobyDoo', 'oo').should.equal 2


    it "should find the next 'oo'", ->

      pal.strpos('ScoobyDoo', 'oo', 3).should.equal 7



  #? -----------------------------------------------------------------+
  describe 'strrchr', ->

    #! ---------------------------------------------------------------+
    it "should find '*daphne'", ->

      pal.strrchr('shaggy*velma*daphne', '*').should.equal "*daphne"


    it "should also find '*daphne'", ->

      pal.strrchr('shaggy*velma*daphne', 42).should.equal "*daphne"



  #? -----------------------------------------------------------------+
  describe 'strrpos', ->

    #! ---------------------------------------------------------------+
    it "should find the last 'oo'", ->

      pal.strrpos('ScoobyDoo', 'oo').should.equal 7


  #? -----------------------------------------------------------------+
  describe 'strtolower', ->

    #! ---------------------------------------------------------------+
    it "should return 'mystery machine'", ->

      pal.strtolower('Mystery Machine').should.equal 'mystery machine'



  #? -----------------------------------------------------------------+
  describe 'strtoupper', ->

    #! ---------------------------------------------------------------+
    it "should return 'DOO'", ->

      pal.strupper('doo').should.equal 'DOO'


  #? -----------------------------------------------------------------+
  describe 'substr', ->

    #! ---------------------------------------------------------------+
    it "should return", ->

      pal.substr('shaggy', 1).should.equal 'haggy'


    it "should return", ->

      pal.substr('shaggy', 1, 3).should.equal 'hag'


  #? -----------------------------------------------------------------+
  describe 'trim', ->

    #! ---------------------------------------------------------------+
    it "should return 'ystery Machin' for 'Mystery Machine' - 'Me'", ->

      pal.trim('Mystery Machine', 'Me').should.equal 'ystery Machin'


  #? -----------------------------------------------------------------+
  describe 'ucfirst', ->

    #! ---------------------------------------------------------------+
    it "should return 'Mystery' for 'mystery'", ->

      pal.ucfirst('mystery').should.equal 'Mystery'





# End of file test-pal.coffee
# Location: ./test-pal.coffee