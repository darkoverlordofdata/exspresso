#+--------------------------------------------------------------------+
#  ExspressoProfiler.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#
#
# Exspresso Profiler Class
#
# Use definition list <DL> semantics
# Twitter Bootstrap css
# Google-code-prettify for SQL highliting
# Displays modaly from a bottom toolbar
#
#
class system.lib.Profiler

  _benchmarks         : true
  _get                : true
  _memory_usage       : true
  _post               : true
  _uri_string         : true
  _controller_info    : true
  _queries            : true
  _http_headers       : true
  _config             : true

  _available_sections: [
    'benchmarks'
    'get'
    'memory_usage'
    'post'
    'uri_string'
    'controller_info'
    'queries'
    'http_headers'
    'config'
  ]

  _server_headers: [
    'CONTENT_TYPE'
    'DOCUMENT_ROOT'
    'HTTP_ACCEPT'
    'HTTP_ACCEPT_CHARSET'
    'HTTP_ACCEPT_ENCODING'
    'HTTP_ACCEPT_LANGUAGE'
    'HTTP_CLIENT_IP'
    'HTTP_CONNECTION'
    'HTTP_HOST'
    'HTTP_REFERER'
    'HTTP_USER_AGENT'
    'HTTP_X_CLIENT_IP'
    'HTTP_X_CLUSTER_CLIENT_IP'
    'HTTP_X_FORWARDED_FOR'
    'PATH_INFO'
    'QUERY_STRING'
    'REMOTE_ADDR'
    'REMOTE_HOST'
    'REQUEST_METHOD'
    'REQUEST_TIME'
    'REQUEST_URI'
    'SERVER_ADDR'
    'SERVER_NAME'
    'SERVER_PORT'
    'SERVER_PROTOCOL'
    'SERVER_SOFTWARE'
    'SCRIPT_NAME'
  ]


  constructor: ($controller, $config = {}) ->

    # Initialize the config preferences
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    log_message 'debug', "Profiler Class Initialized"

    @load.language('profiler')


  #
  # Compile Benchmarks
  #
  # This function cycles through the entire array of mark points and
  # matches any two points that are named identically (ending in "_start"
  # and "_end" respectively).  It then compiles the execution times for
  # all points and returns it as an array
  #
  # @return	array
  #
  _compile_benchmarks: () ->

    $profile = {}
    for $key, $val of @bm.marker
      #  We match the "end" marker so that the list ends
      #  up in the order that it was defined
      if ($match = preg_match("/(.+?)_end/i", $key))?
        if @bm.marker[$match[1] + '_end']?  and @bm.marker[$match[1] + '_start']?
          $profile[$match[1]] = @bm.elapsedTime($match[1] + '_start', $key)

    #  Build a table containing the profile data.
    #  Note: At some point we should turn this into a template that can
    #  be modified.  We also might want to make this data available to be logged

    $output = "\n\n"
    $output+='<dl id="ex_profiler_benchmarks">'
    $output+="\n"
    $output+='<dt>' + @i18n.line('profiler_benchmarks') + '</dt>'
    $output+="\n"
    $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $key, $val of $profile
      $key = ucwords(str_replace(['_', '-'], ' ', $key))
      $output+="<tr><td>" + $key + "</td><td>" + $val + "&nbsp;ms</td></tr>\n"


    $output+="</table></dd>\n"
    $output+="</dl>"

    return $output

  #
  # Compile Queries
  #
  # @return	string
  #
  _compile_queries: () ->

    $dbs = []

    #  Let's determine which databases are currently connected to
    for $name, $object of @
      if $object? and $object.dbdriver?
        $dbs.push $object

    if count($dbs) is 0
      $output = "\n\n"
      $output+='<dl id="ex_profiler_queries">'
      $output+="\n"
      $output+='<dt>' + @i18n.line('profiler_queries') + '</dt>'
      $output+="\n"
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"
      $output+="<tr><td><em>" + @i18n.line('profiler_no_db') + "</em></td></tr>\n"
      $output+="</table></dd>\n"
      $output+="</dl>"
      return $output

    #  Load the text helper so we can highlight the SQL
    @load.helper('text')

    #  Key words we want bolded
    $highlight = ['SELECT', 'DISTINCT', 'FROM', 'WHERE', 'AND', 'INNER JOIN', 'LEFT JOIN', 'ORDER BY', 'GROUP BY', 'LIMIT', 'INSERT', 'INTO', 'VALUES', 'UPDATE', 'OR ', 'HAVING', 'OFFSET', 'NOT IN', 'IN', 'LIKE', 'NOT LIKE', 'COUNT', 'MAX', 'MIN', 'ON', 'AS', 'AVG', 'SUM', '(', ')']

    $output = "\n\n"

    for $db in $dbs
      $output+='<dl>'
      $output+="\n"
      $output+='<dt>' + @i18n.line('profiler_database') + ':&nbsp; ' + $db.database + '&nbsp;' + @i18n.line('profiler_queries') + ': ' + count($db.queries) + '&nbsp;</dt>'
      $output+="\n"
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      if count($db.queries) is 0
        $output+="<tr><td><em>" + @i18n.line('profiler_no_queries') + "</em></td></tr>\n"

      else
        for $key, $val of $db.queries
          $time = $db.query_times[$key]+'&nbsp;ms'

          #$val = highlight_code($val, ENT_QUOTES)

          for $bold in $highlight
            $val = str_replace($bold, '<strong>' + $bold + '</strong>', $val)

          $output+="<tr><td>" + $time + "</td><td><pre class='prettyprint'><code class='lang-sql'>" + $val + "</code></pre></td></tr>\n"

      $output+="</table></dd>\n"
      $output+="</dl>"

    return $output

  #
  # Compile @$_GET Data
  #
  # @return	string
  #
  _compile_get: () ->
    $output = "\n\n"
    $output+='<dl id="ex_profiler_get">'
    $output+="\n"
    $output+='<dt>' + @i18n.line('profiler_get_data') + '</dt>'
    $output+="\n"

    if count(@$_GET) is 0
      $output+="<dd><em>" + @i18n.line('profiler_no_get') + "</em></dd>"

    else
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      for $key, $val of @$_GET
        if not is_numeric($key)
          $key = "'" + $key + "'"

        $output+="<tr><td>&#36;_GET[" + $key + "] </td><td>"
        if is_array($val)
          $output+="<pre>" + htmlspecialchars(stripslashes(print_r($val, true))) + "</pre>"

        else
          $output+=htmlspecialchars(stripslashes($val))

        $output+="</td></tr>\n"


      $output+="</table></dd>\n"

    $output+="</dl>"

    return $output

  #
  # Compile @$_POST Data
  #
  # @return	string
  #
  _compile_post: () ->
    $output = "\n\n"
    $output+='<dl id="ex_profiler_post">'
    $output+="\n"
    $output+='<dt>' + @i18n.line('profiler_post_data') + '</dt>'
    $output+="\n"

    if count(@$_POST) is 0
      $output+="<dd><em>" + @i18n.line('profiler_no_post') + "</em></dd>"

    else
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      for $key, $val of @$_POST
        if not is_numeric($key)
          $key = "'" + $key + "'"


        $output+="<tr><td>&#36;_POST[" + $key + "] </td><td>"
        if is_array($val)
          $output+="<pre>" + htmlspecialchars(stripslashes(print_r($val, true))) + "</pre>"

        else
          $output+=htmlspecialchars(stripslashes($val))

        $output+="</td></tr>\n"


      $output+="</table></dd>\n"

    $output+="</dl>"

    return $output

  #
  # Show query string
  #
  # @return	string
  #
  _compile_uri_string: () ->
    $output = "\n\n"
    $output+='<dl id="ex_profiler_uri_string">'
    $output+="\n"
    $output+='<dt>' + @i18n.line('profiler_uri_string') + '</dt>'
    $output+="\n"

    if @uri.uriString() is ''
      $output+="<dd><em>" + @i18n.line('profiler_no_uri') + "</em></dd>"

    else
      $output+="<dd>" + @uri.uriString() + "</dd>"

    $output+="</dl>"

    return $output

  #
  # Show the controller and function that were called
  #
  # @return	string
  #
  _compile_controller_info: () ->
    $output = "\n\n"
    $output+='<dl id="ex_profiler_controller_module">'
    $output+="\n"
    $output+='<dt>' + 'MODULE' + '</dt>'
    $output+="\n"

    $output+="<dd>" + @module + "</dd>"

    $output+="</dl>"
    $output+='<dl id="ex_profiler_controller_info">'
    $output+="\n"
    $output+='<dt>' + @i18n.line('profiler_controller_info') + '</dt>'
    $output+="\n"

    $output+="<dd>" + @class + "/" + @method + "</dd>"

    $output+="</dl>"

    return $output

  #
  # Compile memory usage
  #
  # Display total used memory
  #
  # @return	string
  #
  _compile_memory_usage: () ->
    $output = "\n\n"
    $output+='<dl id="ex_profiler_memory_usage">'
    $output+="\n"
    $output+='<dt>' + @i18n.line('profiler_memory_usage') + '</dt>'
    $output+="\n"

    if function_exists('memory_get_usage') and ($usage = memory_get_usage()) isnt ''
      $output+="<dd>" + number_format($usage) + ' bytes</dd>'

    else
      $output+="<dd><em>" + @i18n.line('profiler_no_memory_usage') + "</em></dd>"

    $output+="</dl>"

    return $output

  #
  # Compile header information
  #
  # Lists HTTP headers
  #
  # @return	string
  #
  _compile_http_headers: () ->
    $output = "\n\n"
    $output+='<dl id="ex_profiler_http_headers">'
    $output+="\n"
    $output+='<dt>' + @i18n.line('profiler_headers') + '</dt>'
    $output+="\n"

    $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $header in @_server_headers
      $val = if (@$_SERVER[$header]? ) then @$_SERVER[$header] else ''
      $output+="<tr><td>" + $header + "</td><td>" + $val + "</td></tr>\n"

    $output+="</table></dd>\n"
    $output+="</dl>"

    return $output

  #
  # Compile config information
  #
  # Lists developer config variables
  #
  # @return	string
  #
  _compile_config: () ->
    $output = "\n\n"
    $output+='<dl id="ex_profiler_config">'
    $output+="\n"
    $output+='<dt>' + @i18n.line('profiler_config') + '</dt>'
    $output+="\n"

    $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $config, $val of @config.config
      if is_array($val)
        $val = print_r($val, true)

      $output+="<tr><td>" + $config + "</td><td>" + htmlspecialchars($val) + "</td></tr>\n"

    $output+="</table></dd>\n"
    $output+="</dl>"

    return $output

  #
  # Run the Profiler
  #
  #   Injects the results into the generated html stream
  #
  # @param string
  # @return	string
  #
  run: () ->

    $elapsed = @bm.elapsedTime('total_execution_time_start', 'total_execution_time_end')
    $memory = if ( not function_exists('memory_get_usage')) then '0' else round(memory_get_usage() / 1024 / 1024, 2) + 'MB'
    $output = """
      <footer id="footer">
        <div class="container">
          <div class="credit">
            <span class="pull-left muted">
              <a data-toggle="modal" href="#exspresso_profiler">
                <i class="icon-time"></i> #{$elapsed} ms - #{$memory}</a>
            </span>
            <span class="pull-right">powered by &nbsp;
              <a href="https://npmjs.org/package/exspresso">e x s p r e s s o</a>
            </span>
          </div>
        </div>
      </footer>

      <form>
      <div id="exspresso_profiler" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="exspresso_profilerLabel" aria-hidden="true">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3 id="exspresso_profilerLabel">#{ucfirst(ENVIRONMENT)} Profile</h3>
        </div>
        <div id="exspresso_profiler-body" class="modal-body">
          <div class="hero-unit">
            <div class="row">
      """
    $fields_displayed = 0

    for $section in @_available_sections
      if @['_'+$section] isnt false
        $output+=@["_compile_#{$section}"]()
        $fields_displayed++

    if $fields_displayed is 0
      $output+='<p>' + @i18n.line('profiler_no_profiles') + '</p>'
    $output+='''            </div>
                </div>
            </div>
        </div>
        </form>'''

    return $output

module.exports = system.lib.Profiler

#  END ExspressoProfiler class

#  End of file Profiler.coffee
#  Location: .system/lib/Profiler.coffee