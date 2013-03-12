#+--------------------------------------------------------------------+
#| util.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

exports.is_dir = ($path) -> fs.existsSync($path) and fs.statSync($path).isDirectory()
exports.is_file = ($path) -> fs.existsSync($path) and fs.statSync($path).isFile()

# End of file util.coffee
# Location: ./util.coffee