#+--------------------------------------------------------------------+
#  profiler_lang.coffee
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

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')



exports['profiler_database'] = 'DATABASE'
exports['profiler_controller_info'] = 'CLASS/METHOD'
exports['profiler_benchmarks'] = 'BENCHMARKS'
exports['profiler_queries'] = 'QUERIES'
exports['profiler_get_data'] = 'GET DATA'
exports['profiler_post_data'] = 'POST DATA'
exports['profiler_uri_string'] = 'URI STRING'
exports['profiler_memory_usage'] = 'MEMORY USAGE'
exports['profiler_config'] = 'CONFIG VARIABLES'
exports['profiler_headers'] = 'HTTP HEADERS'
exports['profiler_no_db'] = 'Database driver is not currently loaded'
exports['profiler_no_queries'] = 'No queries were run'
exports['profiler_no_post'] = 'No POST data exists'
exports['profiler_no_get'] = 'No GET data exists'
exports['profiler_no_uri'] = 'No URI data exists'
exports['profiler_no_memory'] = 'Memory Usage Unavailable'
exports['profiler_no_profiles'] = 'No Profile data - all Profiler sections have been disabled.'

#  End of file profiler_lang.php 
#  Location: ./system/language/english/profiler_lang.php 