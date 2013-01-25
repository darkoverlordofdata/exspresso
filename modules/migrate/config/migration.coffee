#+--------------------------------------------------------------------+
#| migration.coffee.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the MIT License
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



#
#--------------------------------------------------------------------------
# Migrations DB
#--------------------------------------------------------------------------
#
# Database group name to use
# If not set, migrations will use the default database settings.
#
#
exports['migration_db'] = ''

# End of file migration.coffee
# Location: ./application/modules/migrate/config/migration.coffee