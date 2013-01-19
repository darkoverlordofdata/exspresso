#+--------------------------------------------------------------------+
#| ckedit_helper.coffee
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
# @access	public
# @param	string	the URI segments of the form destination
# @param	array	a key/value pair of attributes
# @param	array	a key/value pair hidden data
# @return	string
#
if not function_exists('ckeditor')
  exports.ckeditor = ckeditor = ($name, $value = "", $config = {}, $events = {}) ->

    CKEditor = require('../CKEditor.coffee')
    $ckeditor = new CKEditor('/ckeditor/')
    $ckeditor.returnOutput = true
    return $ckeditor.editor($name, $value, $config, $events)

# End of file ckedit_helper.coffee
# Location: .application/helpers/ckedit_helper.coffee