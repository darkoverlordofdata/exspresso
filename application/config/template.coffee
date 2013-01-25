#+--------------------------------------------------------------------+
## template.coffee
#+--------------------------------------------------------------------+
## Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
##
## This file is a part of Exspresso
##
## Exspresso is free software you can copy, modify, and distribute
## it under the terms of the MIT License
##
#+--------------------------------------------------------------------+
#
#	template config
#
#
#
#
#--------------------------------------------------------------------------
# Layout
#--------------------------------------------------------------------------
#
# Layout to use by default
#
# Can be overriden with @template.set_layout 'foo'
#
#   Default: 'layout'
#
#

exports['layout'] = 'layout'

#--------------------------------------------------------------------------
# Theme
#--------------------------------------------------------------------------
#
# Theme to use by default
#
# Can be overriden with @template.set_theme 'bar'
#
#   Default: 'default'
#
#

exports['theme'] = 'default'

#
#--------------------------------------------------------------------------
# Theme Locations
#--------------------------------------------------------------------------
#
# Locations to look for themes
#
#	Default: [APPPATH+'themes/']
#
#

exports['theme_locations'] = [
  APPPATH+'themes/'
]

#--------------------------------------------------------------------------
# Doctype
#--------------------------------------------------------------------------
#
# Doctype to use by default
#
# Can be overriden with @template.set_doctype 'html4-trans'
#
#   Default: 'html5'
#
#

exports['doctype'] = 'html5'



# End of file template.coffee
# Location: .application/config/template.coffee