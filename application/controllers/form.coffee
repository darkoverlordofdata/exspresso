#+--------------------------------------------------------------------+
#| form.coffee
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
#	form - controller
#
#
#   @see user_guide/libraries/form_validation.html
#
class Form extends CI_Controller

  constructor: ->

    super()
    @load.library 'form_validation'
    @form_validation.set_error_delimiters "<div class='alert alert-error'><p><b>Error:</b>&nbsp;", "</p></div>"


  index: ->

    @form_validation.set_rules 'username', 'Username', 'required|callback_username_check'
    @form_validation.set_rules 'password', 'Password', 'required'
    @form_validation.set_rules 'passconf', 'Password Confirmation', 'required'
    @form_validation.set_rules 'email', 'Email', 'required'
    if @form_validation.run() is false
      @load.view 'myform'
    else
      @load.view 'formsuccess'

  username_check: ($str) =>

    if $str is 'test'
      @form_validation.set_message 'username_check', 'The %s field can not be the word "test".'
      false
    else
      true


module.exports = Form

# End of file form.coffee
# Location: ./form.coffee