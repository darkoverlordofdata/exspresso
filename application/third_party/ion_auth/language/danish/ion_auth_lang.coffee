#+--------------------------------------------------------------------+
#  ion_auth_lang.coffee
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

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')



exports['account_creation_successful'] = 'Konto oprettet'
exports['account_creation_unsuccessful'] = 'Det var ikke muligt at oprette kontoen'
exports['account_creation_duplicate_email'] = 'Email allerede i brug eller ugyldig'
exports['account_creation_duplicate_username'] = 'Brugernavn allerede i brug eller ugyldigt'
exports['password_change_successful'] = 'Kodeordet er ændret'
exports['password_change_unsuccessful'] = 'Det var ikke muligt at ændre kodeordet'
exports['forgot_password_successful'] = 'Email vedrørende nulstilling af kodeord er afsendt'
exports['forgot_password_unsuccessful'] = 'Det var ikke muligt at nulstille kodeordet'
exports['activate_successful'] = 'Konto aktiveret'
exports['activate_unsuccessful'] = 'Det var ikke muligt at aktivere kontoen'
exports['deactivate_successful'] = 'Konto deaktiveret'
exports['deactivate_unsuccessful'] = 'Det var ikke muligt at deaktivere kontoen'
exports['activation_email_successful'] = 'Email vedrørende aktivering af konto er afsendt'
exports['activation_email_unsuccessful'] = 'Det var ikke muligt at sende email vedrørende aktivering af konto'
exports['login_successful'] = 'Logged ind'
exports['login_unsuccessful'] = 'Ugyldigt login'
exports['login_unsuccessful_not_active'] = 'Kontoen er inaktiv'
exports['logout_successful'] = 'Logged ud'
exports['update_successful'] = 'Kontoen er opdateret'
exports['update_unsuccessful'] = 'Det var ikke muligt at opdatere kontoen'
exports['delete_successful'] = 'Bruger slettet'
exports['delete_unsuccessful'] = 'Det var ikke muligt at slette bruger'
