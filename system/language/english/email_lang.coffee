#+--------------------------------------------------------------------+
#  email_lang.coffee
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
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#


exports['email_must_be_array'] = "The email validation method must be passed an array."
exports['email_invalid_address'] = "Invalid email address: %s"
exports['email_attachment_missing'] = "Unable to locate the following email attachment: %s"
exports['email_attachment_unreadable'] = "Unable to open this attachment: %s"
exports['email_no_recipients'] = "You must include recipients: To, Cc, or Bcc"
exports['email_send_failure_phpmail'] = "Unable to send email using PHP mail().  Your server might not be configured to send mail using this method."
exports['email_send_failure_sendmail'] = "Unable to send email using PHP Sendmail.  Your server might not be configured to send mail using this method."
exports['email_send_failure_smtp'] = "Unable to send email using PHP SMTP.  Your server might not be configured to send mail using this method."
exports['email_sent'] = "Your message has been successfully sent using the following protocol: %s"
exports['email_no_socket'] = "Unable to open a socket to Sendmail. Please check settings."
exports['email_no_hostname'] = "You did not specify a SMTP hostname."
exports['email_smtp_error'] = "The following SMTP error was encountered: %s"
exports['email_no_smtp_unpw'] = "Error: You must assign a SMTP username and password."
exports['email_failed_smtp_login'] = "Failed to send AUTH LOGIN command. Error: %s"
exports['email_smtp_auth_un'] = "Failed to authenticate username. Error: %s"
exports['email_smtp_auth_pw'] = "Failed to authenticate password. Error: %s"
exports['email_smtp_data_failure'] = "Unable to send data: %s"
exports['email_exit_status'] = "Exit status code: %s"


#  End of file email_lang.php 
#  Location: ./system/language/english/email_lang.php 