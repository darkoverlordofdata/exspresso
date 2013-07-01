#+--------------------------------------------------------------------+
#  Profiler.coffee
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
# Exspresso Profiler Class
#
# Use definition list <DL> semantics
# Twitter Bootstrap css
# Google-code-prettify for SQL highliting
# Displays modaly from a bottom toolbar
#
#
module.exports = class system.lib.Profiler

  util = require('util')

  #
  # @property [Array<String>] list of all available profiler sections
  #
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

  #
  # @property [Boolean] list of profiler sections enabled status
  #
  _benchmarks         : true
  _get                : true
  _memory_usage       : true
  _post               : true
  _uri_string         : true
  _controller_info    : true
  _queries            : true
  _http_headers       : true
  _config             : true


  #
  # @property [String] button ui element to display the profile data
  #
  button : '''<a data-toggle="modal" href="#exspresso_profiler" accesskey="P"
     title="{elapsed_time} ms - {memory_usage} mb">
    <i class="icon-time"></i> </a>&nbsp;
    '''

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
      if ($match = $key.match(/(.+?)_end/i))?
        if @bm.marker[$match[1] + '_end']?  and @bm.marker[$match[1] + '_start']?
          $profile[$match[1]] = @bm.elapsedTime($match[1] + '_start', $key)

    #  Build a table containing the profile data.
    #  Note: At some point we should turn this into a template that can
    #  be modified.  We also might want to make this data available to be logged

    $output = ["\n\n"]
    $output.push '<dl id="ex_profiler_benchmarks">'
    $output.push "\n"
    $output.push '<dt>' + @i18n.line('profiler_benchmarks') + '</dt>'
    $output.push "\n"
    $output.push "\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $key, $val of $profile
      $key = ucwords($key.replace(/[_\-]/gm, ' '))
      $output.push ["<tr><td>", $key, "</td><td>", $val, "&nbsp;ms</td></tr>\n"].join('')

    $output.push "</table></dd>\n"
    $output.push "</dl>"

    $output.join('')

  #
  # Compile Queries
  #
  # @return	[String]
  #
  _compile_queries: () ->

    $dbs = []

    #  Let's determine which databases we are currently connected to
    for $name, $object of @
      if $object? and $object.dbdriver?
        $dbs.push $object

    if $dbs.length is 0
      $output = ["\n\n"]
      $output.push '<dl id="ex_profiler_queries">'
      $output.push "\n"
      $output.push '<dt>' + @i18n.line('profiler_queries') + '</dt>'
      $output.push "\n"
      $output.push "\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"
      $output.push "<tr><td><em>" + @i18n.line('profiler_no_db') + "</em></td></tr>\n"
      $output.push "</table></dd>\n"
      $output.push "</dl>"
      return $output.join('')

    #  Load the text helper so we can highlight the SQL
    @load.helper('text')

    #  Key words we want bolded
    $highlight = ['SELECT', 'DISTINCT', 'FROM', 'WHERE', 'AND', 'INNER JOIN', 'LEFT JOIN', 'JOIN', 'ORDER BY', 'GROUP BY', 'LIMIT', 'INSERT', 'INTO', 'VALUES', 'UPDATE', 'OR ', 'HAVING', 'OFFSET', 'NOT IN', 'IN', 'LIKE', 'NOT LIKE', 'COUNT', 'MAX', 'MIN', 'ON', 'AS', 'AVG', 'SUM', '(', ')']

    $output = ["\n\n"]

    for $db in $dbs
      $output.push '<dl>'
      $output.push "\n"
      $output.push '<dt>'
      $output.push @i18n.line('profiler_database') + '&nbsp;'
      $output.push '</dt>'
      $output.push '<dt>'
      $output.push @i18n.line('profiler_queries') + ':&nbsp; ' + $db.queries.length + '&nbsp;'
      $output.push '</dt>'
      $output.push "\n"
      $output.push "\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      if $db.queries.length is 0
        $output.push "<tr><td><em>" + @i18n.line('profiler_no_queries') + "</em></td></tr>\n"

      else
        for $key, $val of $db.queries
          $time = $db.query_times[$key]+'&nbsp;ms'

          for $bold in $highlight
            $val = $val.replace(RegExp(reg_quote($bold), 'gm'), '<strong>' + $bold + '</strong>')

          $output.push "<tr><td>" + $time + "</td><td><pre class='prettyprint'><code class='lang-sql'>" + $val + "</code></pre></td></tr>\n"

      $output.push "</table></dd>\n"
      $output.push "</dl>"

    $output.join('')

  #
  # Compile GET method data parsed in req.query
  #
  # @return	[String]
  #
  _compile_get: () ->
    $output = ["\n\n"]
    $output.push '<dl id="ex_profiler_get">'
    $output.push "\n"
    $output.push '<dt>' + @i18n.line('profiler_get_data') + '</dt>'
    $output.push "\n"

    if Object.keys(@req.query).length is 0
      $output.push "<dd><em>" + @i18n.line('profiler_no_get') + "</em></dd>"

    else
      $output.push "\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      for $key, $val of @req.query
        if not 'number' is typeof($key)
          $key = "'" + $key + "'"

        $output.push "<tr><td>req.query[" + $key + "] </td><td>"
        if is_array($val)
          $output.push "<pre>" + htmlspecialchars(stripslashes(util.inspect($val))) + "</pre>"

        else
          $output.push htmlspecialchars(stripslashes($val))

        $output.push "</td></tr>\n"


      $output.push "</table></dd>\n"

    $output.push "</dl>"

    $output.join('')

  #
  # Compile POST method data parsed in req.body
  #
  # @return	[String]
  #
  _compile_post: () ->
    $output = ["\n\n"]
    $output.push '<dl id="ex_profiler_post">'
    $output.push "\n"
    $output.push '<dt>' + @i18n.line('profiler_post_data') + '</dt>'
    $output.push "\n"

    if Object.keys(@req.body).length is 0
      $output.push "<dd><em>" + @i18n.line('profiler_no_post') + "</em></dd>"

    else
      $output.push "\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

      for $key, $val of @req.body
        if 'number' isnt typeof($key)
          $key = "'" + $key + "'"


        $output.push "<tr><td>req.body[" + $key + "] </td><td>"
        if is_array($val)
          $output.push "<pre>" + htmlspecialchars(stripslashes(util.inspect($val))) + "</pre>"

        else
          $output.push htmlspecialchars(stripslashes($val))

        $output.push "</td></tr>\n"


      $output.push "</table></dd>\n"

    $output.push "</dl>"

    $output.join('')

  #
  # Show query string
  #
  # @return	[String]
  #
  _compile_uri_string: () ->
    $output = ["\n\n"]
    $output.push '<dl id="ex_profiler_uri_string">'
    $output.push "\n"
    $output.push '<dt>' + @i18n.line('profiler_uri_string') + '</dt>'
    $output.push "\n"

    if @uri.uriString() is ''
      $output.push "<dd><em>" + @i18n.line('profiler_no_uri') + "</em></dd>"

    else
      $output.push "<dd>" + @uri.uriString() + "</dd>"

    $output.push "</dl>"

    $output.join('')

  #
  # Show the controller and function that were called
  #
  # @return	[String]
  #
  _compile_controller_info: () ->
    $output = ["\n\n"]
    $output.push '<dl id="ex_profiler_controller_module">'
    $output.push "\n"
    $output.push '<dt>' + 'MODULE' + '</dt>'
    $output.push "\n"

    $output.push "<dd>" + @module + "</dd>"

    $output.push "</dl>"
    $output.push '<dl id="ex_profiler_controller_info">'
    $output.push "\n"
    $output.push '<dt>' + @i18n.line('profiler_controller_info') + '</dt>'
    $output.push "\n"

    $output.push "<dd>" + @class + "/" + @method + "</dd>"

    $output.push "</dl>"

    $output.join('')

  #
  # Compile memory usage
  #
  # Display total used memory
  #
  # @return	[String]
  #
  _compile_memory_usage: () ->

    $output = ["\n\n"]
    $output.push '<dl id="ex_profiler_memory_usage">'
    $output.push "\n"
    $output.push '<dt>' + @i18n.line('profiler_memory_usage') + '</dt>'
    $output.push "\n"

    $output.push "<dd>" + number_format(process.memoryUsage().heapUsed) + ' bytes</dd>'

    $output.push "</dl>"

    $output.join('')

  #
  # Compile header information
  #
  # Lists HTTP headers
  #
  # @return	[String]
  #
  _compile_http_headers: () ->


    os = require('os')
    protocol = ($secure) -> if $secure then 'https' else 'http'

    $output = ["\n\n"]
    $output.push '<dl id="ex_profiler_http_headers">'
    $output.push "\n"
    $output.push '<dt>' + @i18n.line('profiler_headers') + '</dt>'
    $output.push "\n"

    $output.push "\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $key, $val of @req.headers
      $output.push "<tr><td>" + $key + "</td><td>" + $val + "</td></tr>\n"

    $output.push "<tr><td>remote&nbsp;address </td><td>" + @req.connection.remoteAddress + "</td></tr>\n"
    $output.push "<tr><td>request&nbsp;method</td><td>" + @req.method + "</td></tr>\n"
    $output.push "<tr><td>request&nbsp;start</td><td>" + @req._startTime + "</td></tr>\n"
    $output.push "<tr><td>request&nbsp;uri</td><td>" + @req.url.split('?')[0] + "</td></tr>\n"
    $output.push "<tr><td>host&nbsp;name</td><td>" + @req.headers.host + "</td></tr>\n"
    $output.push "<tr><td>port</td><td>" + @server.port + "</td></tr>\n"
    $output.push "<tr><td>protocol</td><td>" + protocol(@req.connection.encrypted).toUpperCase()+"/"+@req.httpVersion + "</td></tr>\n"
    $output.push "<tr><td>software</td><td>" + @server.version+" (" + os.type() + '/' + os.release() + ") Node.js " + process.version + "</td></tr>\n"


    $output.push "</table></dd>\n"
    $output.push "</dl>"

    $output.join('')

  #
  # Compile config information
  #
  # Lists developer config variables
  #
  # @return	[String]
  #
  _compile_config: () ->
    $output = ["\n\n"]
    $output.push '<dl id="ex_profiler_config">'
    $output.push "\n"
    $output.push '<dt>' + @i18n.line('profiler_config') + '</dt>'
    $output.push "\n"

    $output.push "\n\n<dd><table class='table table-condensed table-bordered table-hover'>\n"

    for $config, $val of @config.config
      if 'object' is typeof($val)
        $val = htmlspecialchars(util.inspect($val))
          .replace(/^\{\s/, "")
          .replace(/\s\}$/, "")
          .replace(/^\[\s/, "")
          .replace(/\s\]$/, "")
          .split(',').sort().join('<br />')

      $output.push "<tr><td>" + $config + "</td><td>" + ($val) + "</td></tr>\n"

    $output.push "</table></dd>\n"
    $output.push "</dl>"

    $output.join('')

  #
  # Run the Profiler
  #
  #   Injects the results into the generated html stream
  #
  # @return	[String]
  #
  run: () ->

    $output = ["""
      <form>
      <div id="exspresso_profiler" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="exspresso_profilerLabel" aria-hidden="true">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3 id="exspresso_profilerLabel">#{ucfirst(ENVIRONMENT)} Profile</h3>
        </div>
        <div id="exspresso_profiler-body" class="modal-body">
          <div class="hero-unit">
            <div class="row">
      """]
    $fields_displayed = 0

    for $section in @_available_sections
      if @['_'+$section] isnt false
        $output.push @["_compile_#{$section}"]()
        $fields_displayed++

    if $fields_displayed is 0
      $output.push '<p>' + @i18n.line('profiler_no_profiles') + '</p>'
    $output.push '''            </div>
                </div>
            </div>
        </div>
        </form>'''

    $output.join('')

