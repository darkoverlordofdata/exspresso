#+--------------------------------------------------------------------+
#| migration.coffee.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	migration.coffee - Main application
#
#
#
#
#--------------------------------------------------------------------------
# Enable/Disable Migrations
#--------------------------------------------------------------------------
#
# Migrations are disabled by default but should be enabled
# whenever you intend to do a schema migration.
#
#
exports['migration_enabled'] = false


#
#--------------------------------------------------------------------------
# Migrations version
#--------------------------------------------------------------------------
#
# This is used to set migration version that the file system should be on.
# If you run $this->migration->latest() this is the version that schema will
# be upgraded / downgraded to.
#
#
exports['migration_version'] = 0


#
#--------------------------------------------------------------------------
# Migrations Path
#--------------------------------------------------------------------------
#
# Path to your migrations folder.
# Typically, it will be within your application path.
# Also, writing permission is required within the migrations path.
#
#
exports['migration_path'] = APPPATH + 'migrations/'


# End of file migration.coffee.coffee
# Location: ./application/config/migration.coffee.coffee