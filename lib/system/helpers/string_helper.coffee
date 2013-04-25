#+--------------------------------------------------------------------+
#  string_helper.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# Exspresso String Helpers
#
#

#
# Trim Slashes
#
# Removes any leading/trailing slashes from a string:
#
# /this/that/theother/
#
# becomes:
#
# this/that/theother
#
# @param  [String]  # @return	[String]
#
exports.trim_slashes = trim_slashes = ($str) ->
  return trim($str, '/')



#  ------------------------------------------------------------------------

#
# Strip Slashes
#
# Removes slashes contained in a string or in an array
#
# @param  [Mixed]  string or array
# @return [Mixed]  string or array
#
exports.strip_slashes = strip_slashes = ($str) ->
  if is_array($str)
    for $key, $val of $str
      $str[$key] = strip_slashes($val)


  else
    $str = stripslashes($str)


  return $str



#  ------------------------------------------------------------------------

#
# Strip Quotes
#
# Removes single and double quotes from a string
#
# @param  [String]  # @return	[String]
#
exports.strip_quotes = strip_quotes = ($str) ->
  $str.replace(/\'/g, '').replace(/\"/g, '')



#  ------------------------------------------------------------------------

#
# Quotes to Entities
#
# Converts single and double quotes to entities
#
# @param  [String]  # @return	[String]
#
exports.quotes_to_entities = quotes_to_entities = ($str) ->
  $str.replace(/\'/g, '&#39;').replace(/\"/g, '&quot;')



#  ------------------------------------------------------------------------

#
# Reduce Double Slashes
#
# Converts double slashes in a string to a single slash,
# except those found in http://
#
# http://www.some-site.com//index.php
#
# becomes:
#
# http://www.some-site.com/index.php
#
# @param  [String]  # @return	[String]
#
exports.reduce_double_slashes = reduce_double_slashes = ($str) ->
  return preg_replace("#(^|[^:])//+#", "\\1/", $str)



#  ------------------------------------------------------------------------

#
# Reduce Multiples
#
# Reduces multiple instances of a particular character.  Example:
#
# Fred, Bill,, Joe, Jimmy
#
# becomes:
#
# Fred, Bill, Joe, Jimmy
#
# @param  [String]  # @param  [String]  the character you wish to reduce
# @return	[Boolean]	TRUE/FALSE - whether to trim the character from the beginning/end
# @return	[String]
#
exports.reduce_multiples = reduce_multiples = ($str, $character = ',', $trim = false) ->
  $str = preg_replace('#' + reg_quote($character, '#') + '{2,}#', $character, $str)

  if $trim is true
    $str = trim($str, $character)


  return $str



#  ------------------------------------------------------------------------

#
# Create a Random String
#
# Useful for generating passwords or hashes.
#
# @param  [String]  type of random string.  basic, alpha, alunum, numeric, nozero, unique, md5, encrypt and sha1
# @param  [Integer]  number of characters
# @return	[String]
#
exports.random_string = random_string = ($type = 'alnum', $len = 8) ->
  switch $type
    when 'basic' then return rand()

    when 'alnum','numeric','nozero','alpha'

      switch $type
        when 'alpha' then $pool = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

        when 'alnum' then $pool = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

        when 'numeric' then $pool = '0123456789'

        when 'nozero'then $pool = '123456789'



      $str = ''
      for $i in [0..$len-1]

        $str+=$pool.substr(rand(0, $pool.length - 1), 1)

      return $str

    when 'unique','md5'

      return md5(uniqid(rand()))

    when 'encrypt','sha1'

      $s = @load.helper('security')

      return $s.do_hash(uniqid(rand(), true), 'sha1')





#  ------------------------------------------------------------------------

#
# Alternator
#
# Allows strings to be alternated.  See docs...
#
# @param  [String]  (as many parameters as needed)
# @return	[String]
#
_alternator = 0

exports.alternator = alternator =  ->

  if func_num_args() is 0
    _alternator = 0
    return ''

  $args = func_get_args()
  return $args[(_alternator++ % $args.length)]



#  ------------------------------------------------------------------------

#
# Repeater function
#
# @param  [String]  # @param  [Integer]  number of repeats
# @return	[String]
#
exports.repeater = repeater = ($data, $num = 1) ->
  return if $num > 0 then str_repeat($data, $num) else ''


#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body

