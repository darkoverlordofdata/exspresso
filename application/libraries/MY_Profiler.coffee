#+--------------------------------------------------------------------+
#  MY_Profiler.coffee
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

#  ------------------------------------------------------------------------

#   Exspresso Profiler Class
#
#     UI updates:
#
#       Use definition list <DL> semantics
#       Twitter Bootstrap css
#       google-code-prettify for SQL highliting
#       display modaly from a bottom toolbar
#
#

class global.MY_Profiler extends CI_Profiler

#  --------------------------------------------------------------------

#
# Auto Profiler
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
    for $key, $val of @CI.benchmark.marker
      #  We match the "end" marker so that the list ends
      #  up in the order that it was defined
      $match = preg_match("/(.+?)_end/i", $key)
      if $match?
        if @CI.benchmark.marker[$match[1] + '_end']?  and @CI.benchmark.marker[$match[1] + '_start']?
          $profile[$match[1]] = @CI.benchmark.elapsed_time($match[1] + '_start', $key)




    #  Build a table containing the profile data.
    #  Note: At some point we should turn this into a template that can
    #  be modified.  We also might want to make this data available to be logged

    $output = "\n\n"
    $output+='<dl id="ci_profiler_benchmarks">'
    $output+="\n"
    $output+='<dt>' + @CI.lang.line('profiler_benchmarks') + '</dt>'
    $output+="\n"
    $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $key, $val of $profile
      $key = ucwords(str_replace(['_', '-'], ' ', $key))
      $output+="<tr><td>" + $key + "</td><td>" + $val + "&nbsp;ms</td></tr>\n"


    $output+="</table></dd>\n"
    $output+="</dl>"

    return $output

  #  --------------------------------------------------------------------

  #
  # Compile Queries
  #
  # @return	string
  #
  _compile_queries: () ->
    $dbs = []

    #  Let's determine which databases are currently connected to
    for $name, $CI_object of get_object_vars(@CI)
      #if is_object($CI_object) # and $CI_object instanceof CI_DB is true
      if $CI_object['dbdriver']?
        $dbs.push $CI_object

    if count($dbs) is 0
      $output = "\n\n"
      $output+='<dl id="ci_profiler_queries">'
      $output+="\n"
      $output+='<dt>' + @CI.lang.line('profiler_queries') + '</dt>'
      $output+="\n"
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"
      $output+="<tr><td><em>" + @CI.lang.line('profiler_no_db') + "</em></td></tr>\n"
      $output+="</table></dd>\n"
      $output+="</dl>"
      return $output


    #  Load the text helper so we can highlight the SQL
    @CI.load.helper('text')

    #  Key words we want bolded
    $highlight = ['SELECT', 'DISTINCT', 'FROM', 'WHERE', 'AND', 'INNER JOIN', 'LEFT JOIN', 'ORDER BY', 'GROUP BY', 'LIMIT', 'INSERT', 'INTO', 'VALUES', 'UPDATE', 'OR ', 'HAVING', 'OFFSET', 'NOT IN', 'IN', 'LIKE', 'NOT LIKE', 'COUNT', 'MAX', 'MIN', 'ON', 'AS', 'AVG', 'SUM', '(', ')']

    $output = "\n\n"

    for $db in $dbs
      $output+='<dl>'
      $output+="\n"
      $output+='<dt>' + @CI.lang.line('profiler_database') + ':&nbsp; ' + $db.database + '&nbsp;' + @CI.lang.line('profiler_queries') + ': ' + count($db.queries) + '&nbsp;</dt>'
      $output+="\n"
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      if count($db.queries) is 0
        $output+="<tr><td><em>" + @CI.lang.line('profiler_no_queries') + "</em></td></tr>\n"

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


  #  --------------------------------------------------------------------

  #
  # Compile $_GET Data
  #
  # @return	string
  #
  _compile_get: () ->
    $output = "\n\n"
    $output+='<dl id="ci_profiler_get">'
    $output+="\n"
    $output+='<dt>' + @CI.lang.line('profiler_get_data') + '</dt>'
    $output+="\n"

    if count($_GET) is 0
      $output+="<dd><em>" + @CI.lang.line('profiler_no_get') + "</em></dd>"

    else
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      for $key, $val of $_GET
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

  #  --------------------------------------------------------------------

  #
  # Compile $_POST Data
  #
  # @return	string
  #
  _compile_post: () ->
    $output = "\n\n"
    $output+='<dl id="ci_profiler_post">'
    $output+="\n"
    $output+='<dt>' + @CI.lang.line('profiler_post_data') + '</dt>'
    $output+="\n"

    if count($_POST) is 0
      $output+="<dd><em>" + @CI.lang.line('profiler_no_post') + "</em></dd>"

    else
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      for $key, $val of $_POST
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

  #  --------------------------------------------------------------------

  #
  # Show query string
  #
  # @return	string
  #
  _compile_uri_string: () ->
    $output = "\n\n"
    $output+='<dl id="ci_profiler_uri_string">'
    $output+="\n"
    $output+='<dt>' + @CI.lang.line('profiler_uri_string') + '</dt>'
    $output+="\n"

    if @CI.uri.uri_string() is ''
      $output+="<dd><em>" + @CI.lang.line('profiler_no_uri') + "</em></dd>"

    else
      $output+="<dd>" + @CI.uri.uri_string() + "</dd>"

    $output+="</dl>"

    return $output

  #  --------------------------------------------------------------------

  #
  # Show the controller and function that were called
  #
  # @return	string
  #
  _compile_controller_info: () ->
    $output = "\n\n"
    $output+='<dl id="ci_profiler_controller_info">'
    $output+="\n"
    $output+='<dt>' + @CI.lang.line('profiler_controller_info') + '</dt>'
    $output+="\n"

    $output+="<dd>" + @CI.router.fetch_class() + "/" + @CI.router.fetch_method() + "</dd>"

    $output+="</dl>"

    return $output

  #  --------------------------------------------------------------------

  #
  # Compile memory usage
  #
  # Display total used memory
  #
  # @return	string
  #
  _compile_memory_usage: () ->
    $output = "\n\n"
    $output+='<dl id="ci_profiler_memory_usage">'
    $output+="\n"
    $output+='<dt>' + @CI.lang.line('profiler_memory_usage') + '</dt>'
    $output+="\n"

    if function_exists('memory_get_usage') and ($usage = memory_get_usage()) isnt ''
      $output+="<dd>" + number_format($usage) + ' bytes</dd>'

    else
      $output+="<dd><em>" + @CI.lang.line('profiler_no_memory_usage') + "</em></dd>"

    $output+="</dl>"

    return $output

  #  --------------------------------------------------------------------

  #
  # Compile header information
  #
  # Lists HTTP headers
  #
  # @return	string
  #
  _compile_http_headers: () ->
    $output = "\n\n"
    $output+='<dl id="ci_profiler_http_headers">'
    $output+="\n"
    $output+='<dt>' + @CI.lang.line('profiler_headers') + '</dt>'
    $output+="\n"

    $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $header in ['HTTP_ACCEPT', 'HTTP_USER_AGENT', 'HTTP_CONNECTION', 'SERVER_PORT', 'SERVER_NAME', 'REMOTE_ADDR', 'SERVER_SOFTWARE', 'HTTP_ACCEPT_LANGUAGE', 'SCRIPT_NAME', 'REQUEST_METHOD', ' HTTP_HOST', 'REMOTE_HOST', 'CONTENT_TYPE', 'SERVER_PROTOCOL', 'QUERY_STRING', 'HTTP_ACCEPT_ENCODING', 'HTTP_X_FORWARDED_FOR']
      $val = if ($_SERVER[$header]? ) then $_SERVER[$header] else ''
      $output+="<tr><td>" + $header + "</td><td>" + $val + "</td></tr>\n"

    $output+="</table></dd>\n"
    $output+="</dl>"

    return $output

  #  --------------------------------------------------------------------

  #
  # Compile config information
  #
  # Lists developer config variables
  #
  # @return	string
  #
  _compile_config: () ->
    $output = "\n\n"
    $output+='<dl id="ci_profiler_config">'
    $output+="\n"
    $output+='<dt>' + @CI.lang.line('profiler_config') + '</dt>'
    $output+="\n"

    $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $config, $val of @CI.config.config
      if is_array($val)
        $val = print_r($val, true)

      $output+="<tr><td>" + $config + "</td><td>" + htmlspecialchars($val) + "</td></tr>\n"

    $output+="</table></dd>\n"
    $output+="</dl>"

    return $output

  #  --------------------------------------------------------------------
  
  #
  # Run the Profiler
  #
  # @return	string
  #
  run: () ->

    $elapsed = @CI.benchmark.elapsed_time('total_execution_time_start', 'total_execution_time_end')
    $output = """
      <footer id="footer">
        <div class="container">
          <div class="credit">
            <span class="pull-left muted">
              <a data-toggle="modal" href="#codeigniter_profiler" class="btn btn-mini" title="Rendered in #{$elapsed} ms">
                <i class="icon-time"></i> Profiler</a>
            </span>
            <span class="pull-right">powered by &nbsp;
              <a href="https://npmjs.org/package/exspresso">e x s p r e s s o</a>
            </span>
          </div>
        </div>
      </footer>

      <form>
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
      $output+='<p>' + @CI.lang.line('profiler_no_profiles') + '</p>'

    $output+='''            </div>
                </div>
            </div>
        </div>
        </form>'''


    return $output

module.exports = MY_Profiler

#  END MY_Profiler class

#  End of file Profiler.php 
#  Location: ./application/libraries/MY_Profiler.php