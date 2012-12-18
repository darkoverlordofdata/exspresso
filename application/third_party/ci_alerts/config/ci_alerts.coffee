#+--------------------------------------------------------------------+
#  ci_alerts.coffee
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
# ci_alerts
#
# The config file containing HTML for ci_alerts
#
# @license		http://www.apache.org/licenses/LICENSE-2.0  Apache License 2.0
# @author		Mike Funk
# @link		http://mikefunk.com
# @email		mike@mikefunk.com
#
# @file		ci_alerts.php
# @version		1.1.7
# @date		03/09/2012
#

#  --------------------------------------------------------------------------
#
# alert html
#
# The html wrapping around alerts
#
exports['before_all'] = ''
exports['before_each'] = ''
exports['before_error'] = '<div class="alert alert-error fade in"><a class="close" href="#" data-dismiss="alert">&times;</a>'
exports['before_success'] = '<div class="alert alert-success fade in"><a class="close" href="#" data-dismiss="alert">&times;</a>'
exports['before_warning'] = '<div class="alert alert-warning fade in"><a class="close" href="#" data-dismiss="alert">&times;</a>'
exports['before_info'] = ''
exports['before_no_type'] = '<div class="alert alert-info fade in"><a class="close" href="#" data-dismiss="alert">&times;</a>'

exports['after_all'] = ''
exports['after_each'] = '</div><!--alert-->'
exports['after_error'] = ''
exports['after_success'] = ''
exports['after_warning'] = ''
exports['after_info'] = ''
exports['after_no_type'] = ''

#  --------------------------------------------------------------------------
#
# remove_duplicates
#
# Whether to remove duplicate alerts
#
exports['remove_duplicates'] = true

#  --------------------------------------------------------------------------

#  End of file ci_alerts.php 
#  Location: ./ci_authentication/config/ci_alerts.php 