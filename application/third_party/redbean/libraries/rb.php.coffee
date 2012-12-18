#+--------------------------------------------------------------------+
#  rb.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee
#
#
#
# @name		CodeIgniter Base Model
# @author		Jens Segers
# @link		http://www.jenssegers.be
# @license		MIT License Copyright (c) 2012 Jens Segers
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

class RB
  
  #
  # Constructor, loads the original RedBean class file and performs
  # the setup proces using CodeIgniter's database configuration: config/database.php
  #
  __construct(){
  #  check if the original redbean file exists
  if not file_exists($redbean_path = dirname(__filename) + '/../vendor/rb.php')
    show_error('The RedBean class file was not found.')
    
  
  #  get original redbean file
  require($redbean_path)
  
  #  does the redbean class exist?
  if not class_exists('R')
    show_error('The RedBean class was not found.')
    
  
  #  get the database config file
  if not defined('ENVIRONMENT') or  not file_exists($file_path = APPPATH + 'config/' + ENVIRONMENT + '/database.php')
    if not file_exists($file_path = APPPATH + 'config/database.php')
      show_error('The configuration file database.php does not exist.')
      
    
  
  require($file_path)
  
  #  show error if config is missing
  if not $db?  or count($db) is 0
    show_error('No database connection settings were found in the database config file.')
    
  
  #  active group missing
  if not $active_group?  or  not $db[$active_group]? 
    show_error('You have specified an invalid database connection group.')
    
  
  $driver = $db[$active_group]['dbdriver']
  $host = $db[$active_group]['hostname']
  $user = $db[$active_group]['username']
  $pass = $db[$active_group]['password']
  $db = $db[$active_group]['database']
  
  #  custom port
  if strstr($host, ':')
    [$host, $port] = explode(':', $host)
    $host = "$host;port=$port"
    
  
  switch $driver
    when 'sqlite'
      R::setup("sqlite:$db", $user, $pass)
      
    when 'postgre'
      R::setup("pgsql:host=$host;dbname=$db", $user, $pass)
      
    when 'mysqli'
      R::setup("mysql:host=$host;dbname=$db", $user, $pass)
      
    else
      R::setup("$driver:host=$host;dbname=$db", $user, $pass)
      
  }
  
  #
  # Magic call method that passes every call to the R object
  # @return mixed
  #
  __call($name, $arguments){
  return call_user_func_array(['R', $name], $arguments)
  }
  
  #
  # Magic get method that passes every property request to the R object
  # @return mixed
  #
  __get($name){
  return R::$name
  }
  
  
module.exports = RB