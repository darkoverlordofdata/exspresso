#+--------------------------------------------------------------------+
#  language_helper.coffee
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
# Exspresso Language Helpers
#
#


#
# Lang
#
# Fetches a language variable and optionally outputs a form label
#
# @param  [String]  the language line
# @param  [String]  the id of the form element
# @return	[String]
#
exports.lang = lang = ($line, $id = '') ->

  $line = exspresso.lang.line($line)

  if $id isnt ''
    $line = '<label for="' + $id + '">' + $line + "</label>"


  return $line

#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body



