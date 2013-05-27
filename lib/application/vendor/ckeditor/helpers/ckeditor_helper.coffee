#+--------------------------------------------------------------------+
#| ckedit_helper.coffee
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
#	CKEditor helpers
#
#
#
#  ------------------------------------------------------------------------

#
# Form Declaration
#
# Creates the opening portion of the form.
#
# @param  [String]  the URI segments of the form destination
# @param  [Array]  a key/value pair of attributes
# @param  [Array]  a key/value pair hidden data
# @return	[String]
#
exports.ckeditor = ckeditor = ($name, $value = "", $config = {}, $events = {}) ->

  CKEditor = require('../CKEditor.coffee')
  $ckeditor = new CKEditor('/ckeditor/')

  $ckeditor.returnOutput = true
  return $ckeditor.editor($name, $value, $config, $events)

