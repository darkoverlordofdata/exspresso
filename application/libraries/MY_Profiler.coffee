#+--------------------------------------------------------------------+
#  Profiler.coffee
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
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter Profiler Class
#
# This class enables you to display benchmark, query, and other data
# in order to help with debugging and optimization.
#
# Note: At some point it would be good to move all the HTML in this class
# into a set of template files in order to allow customization.
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Libraries
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/general/profiling.html
#
class global.MY_Profiler extends CI_Profiler

  #  --------------------------------------------------------------------
  
  #
  # Run the Profiler
  #
  # @return	string
  #
  run: () ->

    $output = """
      <footer id="footer">
        <div class="container">
          <div class="credit">
            <span class="pull-left muted">
              <i class="icon-time"></i>
              <a data-toggle="modal" href="#codeigniter_profiler" class="btn btn-link btn-mini"> Profiler</a>
            </span>
            <span class="pull-right">powered by &nbsp;
              <a href="https://npmjs.org/package/exspresso">e x s p r e s s o</a>
            </span>
          </div>
        </div>
      </footer>

      <div id="codeigniter_profiler" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="codeigniter_profilerLabel" aria-hidden="true">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3 id="codeigniter_profilerLabel">#{ucfirst(ENVIRONMENT)} Profile</h3>
        </div>
        <div id="codeigniter_profiler-body" class="modal-body">
          <div class="hero-unit">
            <div class="row">
    """

    $fields_displayed = 0

    for $section, $enabled of @_enabled_sections
      if $enabled isnt false
        $func = "_compile_#{$section}"
        $output+=@[$func]()
        $fields_displayed++

    if $fields_displayed is 0
      $output+='<p style="border:1px solid #5a0099;padding:10px;margin:20px 0;background-color:#eee">' + @CI.lang.line('profiler_no_profiles') + '</p>'

    $output+='''            </div>
                </div>
            </div>
        </div>'''


    return $output

module.exports = MY_Profiler

#  END MY_Profiler class

#  End of file Profiler.php 
#  Location: ./application/libraries/MY_Profiler.php