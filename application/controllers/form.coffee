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
#   @see user_guide/libraries/form_validation.html
#
class Form extends CI_Controller

  index: ->

    @load.library 'form_validation'
    @form_validation.set_rules 'username', 'Username', 'required'
    @form_validation.set_rules 'password', 'Password', 'required'
    @form_validation.set_rules 'passconf', 'Password Confirmation', 'required'
    @form_validation.set_rules 'email', 'Email', 'required'

    if @form_validation.run() is false
      @load.view 'myform'
    else
      @load.view 'formsuccess'

module.exports = Form

# End of file form.coffee
# Location: ./form.coffee