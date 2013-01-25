#+--------------------------------------------------------------------+
#| email.coffee
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
#	email configuration
#
#
#

exports['protocol'] = "smtp "#  mail/sendmail/smtp

exports['_protocols'] = ['smtp'] # emailjs - only supports smtp

exports['smtp_host'] = "smtp.gmail.com" #  SMTP Server.  Example: mail.earthlink.net
exports['smtp_user'] = "" #  SMTP Username
exports['smtp_pass'] = "" #  SMTP Password


# End of file email.coffee
# Location: .application/config/email.coffee