#+--------------------------------------------------------------------+
#| breadcrumb.coffee
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
#	breadcrumb - Main application
#
#
#
#
#+--------------------------------------------------------------------+
#
#	Compatible with twitter-bootstrap stylesheet
#
#
#	@see http://twitter.github.com/bootstrap/components.html#breadcrumbs
#
#		<ul class="breadcrumb">
#		<li>
#			<a href="#">Home</a> <span class="divider">/</span>
#		</li>
#		<li>
#			<a href="#">Library</a> <span class="divider">/</span>
#		</li>
#		<li class="active">Data</li>
#		</ul>
#+--------------------------------------------------------------------+
#
#
#--------------------------------------------------------------------------
# Path Seperator
#--------------------------------------------------------------------------
#
#
#
exports['path_sep'] = '<span class="divider"> / </span>'

#
#--------------------------------------------------------------------------
# Left Outer
#--------------------------------------------------------------------------
#
#
#
exports['left_outer'] = '<ul class="breadcrumb">'

#
#--------------------------------------------------------------------------
# Right Outer
#--------------------------------------------------------------------------
#
#
#
exports['right_outer']	= '</ul>'

#
#--------------------------------------------------------------------------
# Left Inner
#--------------------------------------------------------------------------
#
#
#
exports['left_inner'] = '<li>'

#
#--------------------------------------------------------------------------
# Right Inner
#--------------------------------------------------------------------------
#
#
#
exports['right_inner']	= '</li>'

#
#--------------------------------------------------------------------------
# Active Class
#--------------------------------------------------------------------------
#
#
#
exports['left_inner_active'] = '<li class="active">'

# End of file breadcrumb.php #
# Location: ./application/config/breadcrumb.php #
