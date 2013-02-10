#+--------------------------------------------------------------------+
#  Exspresso_Profiler.coffee
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
require BASEPATH+'libraries/Base/Profiler.coffee'
class global.Exspresso_Profiler extends Base_Profiler

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
    for $key, $val of @Exspresso.BM.marker
      #  We match the "end" marker so that the list ends
      #  up in the order that it was defined
      $match = preg_match("/(.+?)_end/i", $key)
      if $match?
        if @Exspresso.BM.marker[$match[1] + '_end']?  and @Exspresso.BM.marker[$match[1] + '_start']?
          $profile[$match[1]] = @Exspresso.BM.elapsed_time($match[1] + '_start', $key)




    #  Build a table containing the profile data.
    #  Note: At some point we should turn this into a template that can
    #  be modified.  We also might want to make this data available to be logged

    $output = "\n\n"
    $output+='<dl id="ex_profiler_benchmarks">'
    $output+="\n"
    $output+='<dt>' + @Exspresso.lang.line('profiler_benchmarks') + '</dt>'
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
    for $name, $Exspresso_object of get_object_vars(@Exspresso)
      #if is_object($Exspresso_object) # and $Exspresso_object instanceof Exspresso_DB is true
      if $Exspresso_object['dbdriver']?
        $dbs.push $Exspresso_object

    if count($dbs) is 0
      $output = "\n\n"
      $output+='<dl id="ex_profiler_queries">'
      $output+="\n"
      $output+='<dt>' + @Exspresso.lang.line('profiler_queries') + '</dt>'
      $output+="\n"
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"
      $output+="<tr><td><em>" + @Exspresso.lang.line('profiler_no_db') + "</em></td></tr>\n"
      $output+="</table></dd>\n"
      $output+="</dl>"
      return $output


    #  Load the text helper so we can highlight the SQL
    @Exspresso.load.helper('text')

    #  Key words we want bolded
    $highlight = ['SELECT', 'DISTINCT', 'FROM', 'WHERE', 'AND', 'INNER JOIN', 'LEFT JOIN', 'ORDER BY', 'GROUP BY', 'LIMIT', 'INSERT', 'INTO', 'VALUES', 'UPDATE', 'OR ', 'HAVING', 'OFFSET', 'NOT IN', 'IN', 'LIKE', 'NOT LIKE', 'COUNT', 'MAX', 'MIN', 'ON', 'AS', 'AVG', 'SUM', '(', ')']

    $output = "\n\n"

    for $db in $dbs
      $output+='<dl>'
      $output+="\n"
      $output+='<dt>' + @Exspresso.lang.line('profiler_database') + ':&nbsp; ' + $db.database + '&nbsp;' + @Exspresso.lang.line('profiler_queries') + ': ' + count($db.queries) + '&nbsp;</dt>'
      $output+="\n"
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      if count($db.queries) is 0
        $output+="<tr><td><em>" + @Exspresso.lang.line('profiler_no_queries') + "</em></td></tr>\n"

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
  # Compile @Exspresso.$_GET Data
  #
  # @return	string
  #
  _compile_get: () ->
    $output = "\n\n"
    $output+='<dl id="ex_profiler_get">'
    $output+="\n"
    $output+='<dt>' + @Exspresso.lang.line('profiler_get_data') + '</dt>'
    $output+="\n"

    if count(@Exspresso.$_GET) is 0
      $output+="<dd><em>" + @Exspresso.lang.line('profiler_no_get') + "</em></dd>"

    else
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      for $key, $val of @Exspresso.$_GET
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
  # Compile @Exspresso.$_POST Data
  #
  # @return	string
  #
  _compile_post: () ->
    $output = "\n\n"
    $output+='<dl id="ex_profiler_post">'
    $output+="\n"
    $output+='<dt>' + @Exspresso.lang.line('profiler_post_data') + '</dt>'
    $output+="\n"

    if count(@Exspresso.$_POST) is 0
      $output+="<dd><em>" + @Exspresso.lang.line('profiler_no_post') + "</em></dd>"

    else
      $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      for $key, $val of @Exspresso.$_POST
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
    $output+='<dl id="ex_profiler_uri_string">'
    $output+="\n"
    $output+='<dt>' + @Exspresso.lang.line('profiler_uri_string') + '</dt>'
    $output+="\n"

    if @Exspresso.uri.uri_string() is ''
      $output+="<dd><em>" + @Exspresso.lang.line('profiler_no_uri') + "</em></dd>"

    else
      $output+="<dd>" + @Exspresso.uri.uri_string() + "</dd>"

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
    $output+='<dl id="ex_profiler_controller_module">'
    $output+="\n"
    $output+='<dt>' + 'MODULE' + '</dt>'
    $output+="\n"

    $output+="<dd>" + @Exspresso.fetch_module() + "</dd>"

    $output+="</dl>"
    $output+='<dl id="ex_profiler_controller_info">'
    $output+="\n"
    $output+='<dt>' + @Exspresso.lang.line('profiler_controller_info') + '</dt>'
    $output+="\n"

    $output+="<dd>" + @Exspresso.fetch_class() + "/" + @Exspresso.fetch_method() + "</dd>"

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
    $output+='<dl id="ex_profiler_memory_usage">'
    $output+="\n"
    $output+='<dt>' + @Exspresso.lang.line('profiler_memory_usage') + '</dt>'
    $output+="\n"

    if function_exists('memory_get_usage') and ($usage = memory_get_usage()) isnt ''
      $output+="<dd>" + number_format($usage) + ' bytes</dd>'

    else
      $output+="<dd><em>" + @Exspresso.lang.line('profiler_no_memory_usage') + "</em></dd>"

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
    $output+='<dl id="ex_profiler_http_headers">'
    $output+="\n"
    $output+='<dt>' + @Exspresso.lang.line('profiler_headers') + '</dt>'
    $output+="\n"

    $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $header in ['HTTP_ACCEPT', 'HTTP_USER_AGENT', 'HTTP_CONNECTION', 'SERVER_PORT', 'SERVER_NAME', 'REMOTE_ADDR', 'SERVER_SOFTWARE', 'HTTP_ACCEPT_LANGUAGE', 'SCRIPT_NAME', 'REQUEST_METHOD', ' HTTP_HOST', 'REMOTE_HOST', 'CONTENT_TYPE', 'SERVER_PROTOCOL', 'QUERY_STRING', 'HTTP_ACCEPT_ENCODING', 'HTTP_X_FORWARDED_FOR']
      $val = if (@Exspresso.$_SERVER[$header]? ) then @Exspresso.$_SERVER[$header] else ''
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
    $output+='<dl id="ex_profiler_config">'
    $output+="\n"
    $output+='<dt>' + @Exspresso.lang.line('profiler_config') + '</dt>'
    $output+="\n"

    $output+="\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $config, $val of @Exspresso.config.config
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

    $elapsed = @Exspresso.BM.elapsed_time('total_execution_time_start', 'total_execution_time_end')
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

    for $section, $enabled of @_enabled_sections
      if $enabled isnt false
        $output+=@["_compile_#{$section}"]()
        $fields_displayed++

    if $fields_displayed is 0
      $output+='<p>' + @Exspresso.lang.line('profiler_no_profiles') + '</p>'

    $output+='''            </div>
                </div>
            </div>
        </div>
        </form>'''

    return $output

module.exports = Exspresso_Profiler

#  END Exspresso_Profiler class

#  End of file Profiler.php 
#  Location: ./application/libraries/Exspresso_Profiler.php