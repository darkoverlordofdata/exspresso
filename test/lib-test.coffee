#+--------------------------------------------------------------------+
#| lib-lib.coffee
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
#   Tests for lib.coffee
#
#
lib = require('../lib') #->  this is the module being tested  <-#

## --------------------------------------------------------------------

# Test class for class_exists:

class lib._classes.ScoobyDoo

  whereAreYou: ->

#? -------------------------------------------------------------------+
describe 'lib', ->


  #? -----------------------------------------------------------------+
  describe 'array_keys', ->

    #! ---------------------------------------------------------------+
    it 'should extract array keys', ->

      $array =
        0: 100
        color: "red"

      lib.array_keys($array).should.eql ['0', 'color']

      $array = ["blue", "red", "green", "blue", "blue"]

      lib.array_keys($array, 'blue').should.eql ['0', '3', '4']


  #? -----------------------------------------------------------------+
  describe 'array_merge', ->

    #! ---------------------------------------------------------------+
    it 'should return return all 4 names', ->

      lib.array_merge({fred: 'Frank Welker'}, {shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}).should.eql {fred: 'Frank Welker', shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}


  #? -----------------------------------------------------------------+
  describe 'array_shift', ->

    #! ---------------------------------------------------------------+
    it "should return return first in ['shaggy', 'velma', 'daphne']", ->

      lib.array_shift(['shaggy', 'velma', 'daphne']).should.equal 'shaggy'



  #? -----------------------------------------------------------------+
  describe 'array_slice', ->

    #! ---------------------------------------------------------------+
    it "should return return ['velma','fred']", ->

      lib.array_slice(['shaggy', 'velma', 'fred', 'daphne'], 1, 2).should.eql ['velma','fred']




  #? -----------------------------------------------------------------+
  describe 'array_splice', ->

    #! ---------------------------------------------------------------+
    it "should change the array", ->

      $array = ['shaggy', 'velma', 'fred', 'daphne']

      lib.array_splice($array, 1, 2).should.eql ['velma','fred']
      $array.should.eql ['shaggy', 'daphne']

      $array = ['shaggy', 'velma', 'fred', 'daphne']

      lib.array_splice($array, 1, 2, 'scooby').should.eql ['velma','fred']
      $array.should.eql ['shaggy', 'scooby', 'daphne']

      $array = ['shaggy', 'velma', 'fred', 'daphne']

      lib.array_splice($array, 1, 2, ['scooby', 'doo']).should.eql ['velma','fred']
      $array.should.eql ['shaggy', 'scooby', 'doo', 'daphne']



  #? -----------------------------------------------------------------+
  describe 'array_unique', ->

    #! ---------------------------------------------------------------+
    it 'should extract unique values', ->

      $array =
        a: "green"
        0: "red"
        b: "green"
        1: "blue"
        c: "red"

      lib.array_unique($array).should.eql {a: 'green', '0': 'red', '1': 'blue'}

      $array = [4, '4', '3', 4, 3, '3']

      lib.array_unique($array).should.eql {0: 4, 2: '3'}

  #? -----------------------------------------------------------------+
  describe 'array_values', ->

    #! ---------------------------------------------------------------+
    it 'should extract array values', ->

      $array =
        size: 'XL'
        color: 'gold'

      lib.array_values($array).should.eql ['XL', 'gold']


  #? -----------------------------------------------------------------+
  describe 'array_unshift', ->

    #! ---------------------------------------------------------------+
    it "should add 'shaggy' to ['velma', 'daphne']", ->

      lib.array_unshift(['velma', 'daphne'], 'shaggy').should.equal 3


  #? -----------------------------------------------------------------+
  describe 'class_exists', ->

    #! ---------------------------------------------------------------+
    it "should return true for ScoobyDoo", ->

      lib.class_exists('ScoobyDoo').should.equal true


    it "should return false for DynoMut", ->

      lib.class_exists('DynoMut').should.equal false


  #? -----------------------------------------------------------------+
  describe 'count', ->

    #! ---------------------------------------------------------------+
    it "should return 3 for ['shaggy','velma','daphne']", ->

      lib.count(['shaggy','velma','daphne']).should.equal 3


    it "should return 3 for {shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}", ->

      lib.count({shaggy: 'Casey Kasem', velma: 'Nicole Jaffe', daphne: 'Heather North'}).should.equal 3


  #? -----------------------------------------------------------------+
  describe 'current', ->

    #! ---------------------------------------------------------------+
    it "should return current array element", ->

      lib.current([1, 2, 3]).should.equal 1

      lib.current({a: 1, b: 2, c: 3}).should.equal 1


  #? -----------------------------------------------------------------+
  describe 'dirname', ->

    #! ---------------------------------------------------------------+
    it "should return current folder", ->

      lib.dirname(__filename).should.equal process.cwd()+'/test'



  #? -----------------------------------------------------------------+
  describe 'end', ->

    #! ---------------------------------------------------------------+
    it "should return last array element", ->

      lib.end([1, 2, 3]).should.equal 3

      lib.end({a: 1, b: 2, c: 3}).should.equal 3


  #? -----------------------------------------------------------------+
  describe 'explode', ->

    #! ---------------------------------------------------------------+
    it "should return  ['shaggy','velma','daphne'] for 'shaggy,velma,daphne'", ->

      lib.explode(',', 'shaggy,velma,daphne').should.eql ['shaggy','velma','daphne']


  #? -----------------------------------------------------------------+
  describe 'file_exists', ->

    #! ---------------------------------------------------------------+
    it "should return true for current file", ->

      lib.file_exists(__filename).should.equal true



  #? -----------------------------------------------------------------+
  describe 'implode', ->

    #! ---------------------------------------------------------------+
    it "should return 'shaggy,velma,daphne' for ['shaggy','velma','daphne']", ->

      lib.implode(',', ['shaggy','velma','daphne']).should.equal 'shaggy,velma,daphne'



  #? -----------------------------------------------------------------+
  describe 'in_array', ->

    #! ---------------------------------------------------------------+
    it 'should return false when not found', ->

      lib.in_array('fred', ['shaggy', 'velma', 'daphne']).should.equal false


    it 'should return the index when found', ->

      lib.in_array('fred', ['shaggy', 'velma', 'fred', 'daphne']).should.equal 2


  #? -----------------------------------------------------------------+
  describe "is_array", ->

    #! ---------------------------------------------------------------+
    it "should return true for an array", ->

      lib.is_array(['shaggy', 'velma', 'daphne']).should.equal true


    it "should return false for a string", ->

      lib.is_array('shaggy, velma, daphne').should.equal false



  #? -----------------------------------------------------------------+
  describe 'is_bool', ->

    #! ---------------------------------------------------------------+
    it "should return return TRUE for a boolean", ->

      lib.is_bool(false).should.equal true

      lib.is_bool(1).should.equal false



  #? -----------------------------------------------------------------+
  describe "is_dir", ->

    #! ---------------------------------------------------------------+
    it "should return true for ./", ->

      lib.is_dir('./').should.equal true


    it "should return false for ./readme.md", ->

      lib.is_dir('./readme.md').should.equal false


  #? -----------------------------------------------------------------+
  describe "is_numeric", ->

    #! ---------------------------------------------------------------+
    it "should return true for a number", ->

      lib.is_numeric(10).should.equal true
      lib.is_numeric('fred').should.equal false
      lib.is_numeric('10').should.equal false


  #? -----------------------------------------------------------------+
  describe "is_null", ->

    #! ---------------------------------------------------------------+
    it "should return true for a null", ->

      lib.is_null(null).should.equal true


    it "should return false for a string", ->

      lib.is_null('scooby').should.equal false


  #? -----------------------------------------------------------------+
  describe "is_string", ->

    #! ---------------------------------------------------------------+
    it 'should return true for string', ->

      lib.is_string('hex girlz rule').should.equal true


    it 'should return false for number', ->

      lib.is_string(1).should.equal false


  #? -----------------------------------------------------------------+
  describe "is_object", ->

    #! ---------------------------------------------------------------+
    it "should return true for an object", ->

      lib.is_object({name: 'fred'}).should.equal true


    it "should return false for a string", ->

      lib.is_object('fred').should.equal false


  #? -----------------------------------------------------------------+
  describe 'rtrim', ->

    #! ---------------------------------------------------------------+
    it "should return 'Mystery Machin' for 'Mystery Machine' - 'Me'", ->

      lib.rtrim('Mystery Machine', 'Me').should.equal 'Mystery Machin'
      lib.rtrim('address').should.equal 'address'


  #? -----------------------------------------------------------------+
  describe 'microtime', ->

    #! ---------------------------------------------------------------+
    it "should return a number > 0", ->

      lib.microtime().should.not.equal 0



  #? -----------------------------------------------------------------+
  describe 'number_format', ->

    #! ---------------------------------------------------------------+
    it "should return a formated number", ->

      #lib.number_format(1234.5678).should.equal '1,235'
      lib.number_format(1234.5678, 2).should.equal '1,234.56'
      lib.number_format(1234, 2).should.equal '1,234.00'
      lib.number_format(1234.5, 2).should.equal '1,234.50'


  #? -----------------------------------------------------------------+
  describe 'parse_str', ->

    #! ---------------------------------------------------------------+
    it "should return a parsed query string", ->

      $extra = {}
      lib.parse_str "shaggy=norville", $extra
      $extra.should.eql {shaggy: 'norville'}


  #? -----------------------------------------------------------------+
  describe 'parse_url', ->

    #! ---------------------------------------------------------------+
    it "should return a parsed url", ->

      $url = "postgres://norville:rogers@zoinks:1620/shaggy"
      lib.parse_url($url).scheme.should.equal "postgres"
      lib.parse_url($url).host.should.equal "zoinks"
      lib.parse_url($url).port.should.equal "1620"
      lib.parse_url($url).user.should.equal "norville"
      lib.parse_url($url).pass.should.equal "rogers"
      lib.parse_url($url).path.should.equal "/shaggy"


  #? -----------------------------------------------------------------+
  describe 'preg_match', ->

    #! ---------------------------------------------------------------+
    it "should match regular expression", ->

      lib.preg_match('/def/g',"abcdef").should.eql ['def']


  #? -----------------------------------------------------------------+
  describe 'preg_replace', ->

    #! ---------------------------------------------------------------+
    it "should replace regular expression", ->

      $string = 'April 15, 2003'
      $pattern = '/(\\w+) (\\d+), (\\d+)/i'
      $replacement = '$11,$3'

      lib.preg_replace($pattern, $replacement, $string).should.equal 'April1,2003'


      #? -----------------------------------------------------------------+
  describe 'rawurldecode', ->

    #! ---------------------------------------------------------------+
    it "should return", ->

      lib.rawurldecode("scooby%20doo").should.equal "scooby doo"


#? -----------------------------------------------------------------+
  describe 'realpath', ->

    #! ---------------------------------------------------------------+
    it "should return current folder", ->

      lib.realpath("./").should.equal process.cwd()


  #? -----------------------------------------------------------------+
  describe 'ltrim', ->

    #! ---------------------------------------------------------------+
    it "should return 'ystery Machine' for 'Mystery Machine' - 'Me'", ->

      lib.ltrim('Mystery Machine', 'Me').should.equal 'ystery Machine'
      lib.ltrim('address').should.equal 'address'


  #? -----------------------------------------------------------------+
  describe 'str_replace', ->

    #! ---------------------------------------------------------------+
    it "should return 'Hex Girls'", ->

      lib.str_replace('Girlz', 'Girls', 'Hex Girlz').should.equal 'Hex Girls'


  #? -----------------------------------------------------------------+
  describe 'stristr', ->

    #! ---------------------------------------------------------------+
    it "should find 'doo", ->

      lib.stristr('Scooby Doo', 'doo').should.equal 'Doo'



  #? -----------------------------------------------------------------+
  describe 'strlen', ->

    #! ---------------------------------------------------------------+
    it "should return the length of a string", ->

      lib.strlen('Mystery Machine').should.equal 15


  #? -----------------------------------------------------------------+
  describe 'strncmp', ->

    #! ---------------------------------------------------------------+
    it "should compare 2 strings", ->

      lib.strncmp('velma', 'velda', 3).should.equal 0
      lib.strncmp('velma', 'velda', 4).should.equal 1
      lib.strncmp('velda', 'velma', 4).should.equal -1


  #? -----------------------------------------------------------------+
  describe 'strpos', ->

    #! ---------------------------------------------------------------+
    it "should find the first 'oo'", ->

      lib.strpos('ScoobyDoo', 'oo').should.equal 2


    it "should find the next 'oo'", ->

      lib.strpos('ScoobyDoo', 'oo', 3).should.equal 7



  #? -----------------------------------------------------------------+
  describe 'strstr', ->

    #! ---------------------------------------------------------------+
    it "should find a substring", ->

      $email  = 'name@example.com'
      lib.strstr($email, '@').should.equal '@example.com'
      lib.strstr($email, '@', true).should.equal 'name'


  #? -----------------------------------------------------------------+
  describe 'strrchr', ->

    #! ---------------------------------------------------------------+
    it "should find '*daphne'", ->

      lib.strrchr('shaggy*velma*daphne', '*').should.equal "*daphne"


    it "should also find '*daphne'", ->

      lib.strrchr('shaggy*velma*daphne', 42).should.equal "*daphne"



  #? -----------------------------------------------------------------+
  describe 'strrpos', ->

    #! ---------------------------------------------------------------+
    it "should find the last 'oo'", ->

      lib.strrpos('ScoobyDoo', 'oo').should.equal 7


  #? -----------------------------------------------------------------+
  describe 'strtolower', ->

    #! ---------------------------------------------------------------+
    it "should return 'mystery machine'", ->

      lib.strtolower('Mystery Machine').should.equal 'mystery machine'



  #? -----------------------------------------------------------------+
  describe 'strtoupper', ->

    #! ---------------------------------------------------------------+
    it "should return 'DOO'", ->

      lib.strtoupper('doo').should.equal 'DOO'



  #? -----------------------------------------------------------------+
  describe 'substr', ->

    #! ---------------------------------------------------------------+
    it "should return", ->

      lib.substr('shaggy', 1).should.equal 'haggy'


    it "should return", ->

      lib.substr('shaggy', 1, 3).should.equal 'hag'


  #? -----------------------------------------------------------------+
  describe 'trim', ->

    #! ---------------------------------------------------------------+
    it "should return 'ystery Machin' for 'Mystery Machine' - 'Me'", ->

      lib.trim('Mystery Machine', 'Me').should.equal 'ystery Machin'
      lib.trim('address').should.equal 'address'


  #? -----------------------------------------------------------------+
  describe 'ucfirst', ->

    #! ---------------------------------------------------------------+
    it "should return 'Mystery' for 'mystery'", ->

      lib.ucfirst('mystery').should.equal 'Mystery'





# End of file test-lib.coffee
# Location: ./test-lib.coffee