#+--------------------------------------------------------------------+
#  ion_auth.coffee
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
#| -------------------------------------------------------------------------
#| Database Type
#| -------------------------------------------------------------------------
#| If set to TRUE, Ion Auth will use MongoDB as its database backend.
#|
#| If you use MongoDB there are two external dependencies that have to be
#| integrated with your project:
#|   CodeIgniter MongoDB Active Record Library - http://github.com/alexbilbie/codeigniter-mongodb-library/tree/v2
#|   CodeIgniter MongoDB Session Library - http://github.com/sepehr/ci-mongodb-session
#
exports['use_mongodb'] = false

#
#| -------------------------------------------------------------------------
#| MongoDB Collection.
#| -------------------------------------------------------------------------
#| Setup the mongodb docs using the following command:
#| $ mongorestore sql/mongo
#|
#
exports['collections']['users'] = 'users'
exports['collections']['groups'] = 'groups'
exports['collections']['login_attempts'] = 'login_attempts'

#
#| -------------------------------------------------------------------------
#| Tables.
#| -------------------------------------------------------------------------
#| Database table names.
#
exports['tables']['users'] = 'users'
exports['tables']['groups'] = 'groups'
exports['tables']['users_groups'] = 'users_groups'
exports['tables']['login_attempts'] = 'login_attempts'

#
#| Users table column and Group table column you want to join WITH.
#|
#| Joins from users.id
#| Joins from groups.id
#
exports['join']['users'] = 'user_id'
exports['join']['groups'] = 'group_id'

#
#| -------------------------------------------------------------------------
#| Hash Method (sha1 or bcrypt)
#| -------------------------------------------------------------------------
#| Bcrypt is available in PHP 5.3+
#|
#| IMPORTANT: Based on the recommendation by many professionals, it is highly recommended to use
#| bcrypt instead of sha1.
#|
#| NOTE: If you use bcrypt you will need to increase your password column character limit to (80)
#|
#| Below there is "default_rounds" setting.  This defines how strong the encryption will be,
#| but remember the more rounds you set the longer it will take to hash (CPU usage) So adjust
#| this based on your server hardware.
#|
#| If you are using Bcrypt the Admin password field also needs to be changed in order login as admin:
#| $2a$07$SeBknntpZror9uyftVopmu61qg0ms8Qv1yV6FG.kQOSM.9QhmTo36
#|
#| Becareful how high you set max_rounds, I would do your own testing on how long it takes
#| to encrypt with x rounds.
#
exports['hash_method'] = 'sha1'#  IMPORTANT: Make sure this is set to either sha1 or bcrypt
exports['default_rounds'] = 8 #  This does not apply if random_rounds is set to true
exports['random_rounds'] = false
exports['min_rounds'] = 5
exports['max_rounds'] = 9

#
#| -------------------------------------------------------------------------
#| Authentication options.
#| -------------------------------------------------------------------------
#| maximum_login_attempts: This maximum is not enforced by the library, but is
#| used by $this->ion_auth->is_max_login_attempts_exceeded().
#| The controller should check this function and act
#| appropriately. If this variable set to 0, there is no maximum.
#
exports['site_title'] = "Example.com"#  Site Title, example.com
exports['admin_email'] = "admin@example.com"#  Admin Email, admin@example.com
exports['default_group'] = 'members'#  Default group, use name
exports['admin_group'] = 'admin'#  Default administrators group, use name
exports['identity'] = 'email'#  A database column which is used to login with
exports['min_password_length'] = 8 #  Minimum Required Length of Password
exports['max_password_length'] = 20 #  Maximum Allowed Length of Password
exports['email_activation'] = false#  Email Activation for registration
exports['manual_activation'] = false#  Manual Activation for registration
exports['remember_users'] = true#  Allow users to be remembered and enable auto-login
exports['user_expire'] = 86500 #  How long to remember the user (seconds). Set to zero for no expiration
exports['user_extend_on_login'] = false#  Extend the users cookies everytime they auto-login
exports['track_login_attempts'] = false#  Track the number of failed login attempts for each user or ip.
exports['maximum_login_attempts'] = 3 #  The maximum number of failed login attempts.
exports['lockout_time'] = 600 #  The number of seconds to lockout an account due to exceeded attempts
exports['forgot_password_expiration'] = 0 #  The number of seconds after which a forgot password request will expire. If set to 0, forgot password requests will not expire.


#
#| -------------------------------------------------------------------------
#| Email options.
#| -------------------------------------------------------------------------
#| email_config:
#| 	  'file' = Use the default CI config or use from a config file
#| 	  array  = Manually set your email config settings
#
exports['use_ci_email'] = false#  Send Email using the builtin CI email class, if false it will return the code and the identity
exports['email_config'] =
  'mailtype':'html',


#
#| -------------------------------------------------------------------------
#| Email templates.
#| -------------------------------------------------------------------------
#| Folder where email templates are stored.
#| Default: auth/
#
exports['email_templates'] = 'auth/email/'

#
#| -------------------------------------------------------------------------
#| Activate Account Email Template
#| -------------------------------------------------------------------------
#| Default: activate.tplcoffee
#
exports['email_activate'] = 'activate.tpl.coffee'

#
#| -------------------------------------------------------------------------
#| Forgot Password Email Template
#| -------------------------------------------------------------------------
#| Default: forgot_password.tplcoffee
#
exports['email_forgot_password'] = 'forgot_password.tpl.coffee'

#
#| -------------------------------------------------------------------------
#| Forgot Password Complete Email Template
#| -------------------------------------------------------------------------
#| Default: new_password.tplcoffee
#
exports['email_forgot_password_complete'] = 'new_password.tpl.coffee'

#
#| -------------------------------------------------------------------------
#| Salt options
#| -------------------------------------------------------------------------
#| salt_length Default: 10
#|
#| store_salt: Should the salt be stored in the database?
#| This will change your password encryption algorithm,
#| default password, 'password', changes to
#| fbaa5e216d163a02ae630ab1a43372635dd374c0 with default salt.
#
exports['salt_length'] = 10
exports['store_salt'] = false

#
#| -------------------------------------------------------------------------
#| Message Delimiters.
#| -------------------------------------------------------------------------
#
exports['message_start_delimiter'] = '<p>'#  Message start delimiter
exports['message_end_delimiter'] = '</p>'#  Message end delimiter
exports['error_start_delimiter'] = '<p>'#  Error mesage start delimiter
exports['error_end_delimiter'] = '</p>'#  Error mesage end delimiter

#  End of file ion_auth.coffee
#  Location: ./application/config/ion_auth.coffee
