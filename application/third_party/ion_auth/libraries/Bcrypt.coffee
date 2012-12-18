#+--------------------------------------------------------------------+
#  Bcrypt.coffee
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

bcrypt = require('bcrypt')

class global.Bcrypt

  rounds: 0

  constructor: ($params = 'rounds':7) ->
    @rounds = $params['rounds']

  hash: ($input) ->
    bcrypt.hashSync($input, bcrypt.genSaltSync(@rounds))

  verify: ($input, $existingHash) ->
    bcrypt.compareSync($input, $existingHash)
  

module.exports = Bcrypt


# *** End of BCrypt.php **********
