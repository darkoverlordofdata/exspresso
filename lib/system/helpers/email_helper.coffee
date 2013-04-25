#+--------------------------------------------------------------------+
#  email_helper.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License

#
# Exspresso Email Helpers
#
#

#
# Validate email address
#
# @return	bool
#
exports.valid_email = valid_email = ($address) ->
  return if ( not preg_match("/^([a-z0-9\\+_\\-]+)(\\.[a-z0-9\\+_\\-]+)*@([a-z0-9\\-]+\\.)+[a-z]{2,6}$/i", $address)?) then false else true


#
# Send an email
#
# @return	bool
#
exports.send_email = send_email = ($recipient, $subject = 'Test email', $message = 'Hello World') ->
  return mail($recipient, $subject, $message)



