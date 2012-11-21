#+--------------------------------------------------------------------+
#| migration_lang.coffee.coffee
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
#	migration_lang.coffee
#
#
#
exports['migration_none_found']			      = "No migrations were found."
exports['migration_not_found']			      = "This migration could not be found."
exports['migration_multiple_version']		  = "This are multiple migrations with the same version number: %d."
exports['migration_class_doesnt_exist']	  = "The migration class \"%s\" could not be found."
exports['migration_missing_up_method']	  = "The migration class \"%s\" is missing an 'up' method."
exports['migration_missing_down_method']	= "The migration class \"%s\" is missing an 'down' method."
exports['migration_invalid_filename']		  = "Migration \"%s\" has an invalid filename."


# End of file migration_lang.coffee.coffee
# Location: ./system/language/english/migration_lang.coffee.coffee