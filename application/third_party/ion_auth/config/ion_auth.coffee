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
# Name:  Ion Auth Config
#
# Author: Ben Edmunds
# 		  ben.edmunds@gmail.com
#         @benedmunds
#
# Added Awesomeness: Phil Sturgeon
#
# Location: http://github.com/benedmunds/ion_auth/
#
# Created:  10.01.2009
#
# Description:  Modified auth system based on redux_auth with extensive customization.  This is basically what Redux Auth 2 should be.
# Original Author name has been kept but that does not mean that the method has not been modified.
#
#
# Bcrypt Implementation
# by: Jason Howard
# 	 jasondhoward@gmail.com
# 	 vzio.com
#
#

#
# Tables.
#*/
exports['tables']['groups'] = 'groups'
exports['tables']['users'] = 'users'
exports['tables']['users_groups'] = 'users_groups'


#
# Hash Method  (sha1 or bcrypt)
#
# Bcrypt is available in PHP 5.3+
#
# IMPORTANT: Based on the recommendation by many professionals, it is highly recommended to use
# 		    bcrypt instead of sha1.
#
#
# NOTE: 	If you use bcrypt you will need to increase your password column character limit
# 		    to (80)
#
# Below there is "default_rounds" setting.  This defines how strong the encryption will be,
# but remember the more rounds you set the longer it will take to hash (CPU usage) So adjust
# this based on your server hardware.
#
# If you are using Bcrypt the Admin password field also needs to be changed in order login as admin:
# $2a$07$SeBknntpZror9uyftVopmu61qg0ms8Qv1yV6FG.kQOSM.9QhmTo36
#
#

exports['hash_method'] = 'sha1'#  IMPORTANT: Make sure this is set to either sha1 or bcrypt

#
# Default rounds used for Bcrypt only
#
exports['default_rounds'] = 8 #  This does not apply if random_rounds is set to true

#
#
# Random Rounds encrypts each new user's password using random rounds
#
#
# Becareful how high you set max_rounds, I would do your own testing on how long it takes
# to encrypt with x rounds.
#
#
exports['random_rounds'] = false
exports['min_rounds'] = 5
exports['max_rounds'] = 9



#
# Site Title, example.com
#
exports['site_title'] = "Example.com"

#
# Admin Email, admin@example.com
#
exports['admin_email'] = "admin@example.com"

#
# Default group, use name
#
exports['default_group'] = 'members'

#
# Default administrators group, use name
#
exports['admin_group'] = 'admin'

#
# Users table column and Group table column you want to join WITH.
# Joins from users.id
# Joins from groups.id
#*/
exports['join']['users'] = 'user_id'
exports['join']['groups'] = 'group_id'

#
# A database column which is used to
# login with.
#*/
exports['identity'] = 'email'

#
# Minimum Required Length of Password
#*/
exports['min_password_length'] = 8

#
# Maximum Allowed Length of Password
#*/
exports['max_password_length'] = 20

#
# Email Activation for registration
#*/
exports['email_activation'] = false

#
# Manual Activation for registration
#*/
exports['manual_activation'] = false

#
# Allow users to be remembered and enable auto-login
#*/
exports['remember_users'] = true

#
# How long to remember the user (seconds)
#*/
exports['user_expire'] = 86500

#
# Extend the users cookies everytime they auto-login
#*/
exports['user_extend_on_login'] = false

#
# Send Email using the builtin CI email class
# if false it will return the code and the identity
#*/
exports['use_ci_email'] = false

#
# Email config -
# 	'file' = use the default CI config or use from a config file
# 	array = manually set your email config settings
#*/
exports['email_config'] = 
  'mailtype':'html', 
  

#
# Folder where email templates are stored.
# Default : auth/
#*/
exports['email_templates'] = 'auth/email/'

#
# Activate Account Email Template
# Default : activate.tpl.eco
#*/
exports['email_activate'] = 'activate.tpl.eco'

#
# Forgot Password Email Template
# Default : forgot_password.tpl.eco
#*/
exports['email_forgot_password'] = 'forgot_password.tpl.eco'

#
# Forgot Password Complete Email Template
# Default : new_password.tpl.eco
#*/
exports['email_forgot_password_complete'] = 'new_password.tpl.eco'

#
# Salt Length
#*/
exports['salt_length'] = 10

#
# Should the salt be stored in the database?
# This will change your password encryption algorithm,
# default password, 'password', changes to
# fbaa5e216d163a02ae630ab1a43372635dd374c0 with default salt.
#*/
exports['store_salt'] = false

#
# The number of seconds after which a forgot password request will
# expire. If set to 0, forgot password requests will not expire.
#*/
exports['forgot_password_expiration'] = 0

#
# Message Start Delimiter
#*/
exports['message_start_delimiter'] = '<p>'

#
# Message End Delimiter
#*/
exports['message_end_delimiter'] = '</p>'

#
# Error Start Delimiter
#*/
exports['error_start_delimiter'] = '<p>'

#
# Error End Delimiter
#*/
exports['error_end_delimiter'] = '</p>'

#  End of file ion_auth.php 
#  Location: ./system/application/config/ion_auth.php 
