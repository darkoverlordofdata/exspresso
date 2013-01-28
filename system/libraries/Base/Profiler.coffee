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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Profiler Class
#
# This class enables you to display benchmark, query, and other data
# in order to help with debugging and optimization.
#
# Note: At some point it would be good to move all the HTML in this class
# into a set of template files in order to allow customization.
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Libraries
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/general/profiling.html
#
class global.Base_Profiler
  
  Exspresso: null
  
  _available_sections: [
    'benchmarks', 
    'get', 
    'memory_usage', 
    'post', 
    'uri_string', 
    'controller_info', 
    'queries', 
    'http_headers', 
    'config'
    ]

  _enabled_sections: null

  constructor: ($config = {}, @Exspresso) ->

    @_enabled_sections = {}
    @Exspresso.load.language('profiler')

    #  default all sections to display
    for $section in @_available_sections
      if not $config[$section]?
        @_enabled_sections[$section] = true

    @set_sections($config)

  #  --------------------------------------------------------------------
  
  #
  # Set Sections
  #
  # Sets the private _compile_* properties to enable/disable Profiler sections
  #
  # @param	mixed
  # @return	void
  #
  set_sections: ($config) ->

    for $method, $enable of $config
      if in_array($method, @_available_sections)
        @_enabled_sections[$method] = if ($enable isnt false) then true else false

    

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
    for $key, $val of @Exspresso.benchmark.marker
      #  We match the "end" marker so that the list ends
      #  up in the order that it was defined
      $match = preg_match("/(.+?)_end/i", $key)
      if $match?
        if @Exspresso.benchmark.marker[$match[1] + '_end']?  and @Exspresso.benchmark.marker[$match[1] + '_start']?
          $profile[$match[1]] = @Exspresso.benchmark.elapsed_time($match[1] + '_start', $key)
        
      
    
  
    #  Build a table containing the profile data.
    #  Note: At some point we should turn this into a template that can
    #  be modified.  We also might want to make this data available to be logged

    $output = "\n\n"
    $output+='<fieldset id="ci_profiler_benchmarks" style="border:1px solid #900;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
    $output+="\n"
    $output+='<legend style="color:#900;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_benchmarks') + '&nbsp;&nbsp;</legend>'
    $output+="\n"
    $output+="\n\n<table style='width:100%'>\n"

    for $key, $val of $profile
      $key = ucwords(str_replace(['_', '-'], ' ', $key))
      $output+="<tr><td style='padding:5px;width:50%;color:#000;font-weight:bold;background-color:#ddd;'>" + $key + "&nbsp;&nbsp;</td><td style='padding:5px;width:50%;color:#900;font-weight:normal;background-color:#ddd;'>" + $val + "</td></tr>\n"


    $output+="</table>\n"
    $output+="</fieldset>"

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
      $output+='<fieldset id="ci_profiler_queries" style="border:1px solid #0000FF;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
      $output+="\n"
      $output+='<legend style="color:#0000FF;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_queries') + '&nbsp;&nbsp;</legend>'
      $output+="\n"
      $output+="\n\n<table style='border:none; width:100%'>\n"
      $output+="<tr><td style='width:100%;color:#0000FF;font-weight:normal;background-color:#eee;padding:5px'>" + @Exspresso.lang.line('profiler_no_db') + "</td></tr>\n"
      $output+="</table>\n"
      $output+="</fieldset>"
      return $output


    #  Load the text helper so we can highlight the SQL
    @Exspresso.load.helper('text')

    #  Key words we want bolded
    $highlight = ['SELECT', 'DISTINCT', 'FROM', 'WHERE', 'AND', 'LEFT&nbsp;JOIN', 'ORDER&nbsp;BY', 'GROUP&nbsp;BY', 'LIMIT', 'INSERT', 'INTO', 'VALUES', 'UPDATE', 'OR&nbsp;', 'HAVING', 'OFFSET', 'NOT&nbsp;IN', 'IN', 'LIKE', 'NOT&nbsp;LIKE', 'COUNT', 'MAX', 'MIN', 'ON', 'AS', 'AVG', 'SUM', '(', ')']

    $output = "\n\n"

    for $db in $dbs
      $output+='<fieldset style="border:1px solid #0000FF;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
      $output+="\n"
      $output+='<legend style="color:#0000FF;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_database') + ':&nbsp; ' + $db.database + '&nbsp;&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_queries') + ': ' + count($db.queries) + '&nbsp;&nbsp;&nbsp;</legend>'
      $output+="\n"
      $output+="\n\n<table style='width:100%;'>\n"

      if count($db.queries) is 0
        $output+="<tr><td style='width:100%;color:#0000FF;font-weight:normal;background-color:#eee;padding:5px;'>" + @Exspresso.lang.line('profiler_no_queries') + "</td></tr>\n"

      else
        for $key, $val of $db.queries
          $time = number_format($db.query_times[$key], 4)

          #$val = highlight_code($val, ENT_QUOTES)

          for $bold in $highlight
            $val = str_replace($bold, '<strong>' + $bold + '</strong>', $val)

          $output+="<tr><td style='padding:5px; vertical-align: top;width:1%;color:#900;font-weight:normal;background-color:#ddd;'>" + $time + "&nbsp;&nbsp;</td><td style='padding:5px; color:#000;font-weight:normal;background-color:#ddd;'>" + $val + "</td></tr>\n"

      $output+="</table>\n"
      $output+="</fieldset>"

    return $output

  
  #  --------------------------------------------------------------------
  
  #
  # Compile @Exspresso.$_GET Data
  #
  # @return	string
  #
  _compile_get: () ->
    $output = "\n\n"
    $output+='<fieldset id="ci_profiler_get" style="border:1px solid #cd6e00;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
    $output+="\n"
    $output+='<legend style="color:#cd6e00;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_get_data') + '&nbsp;&nbsp;</legend>'
    $output+="\n"

    if count(@Exspresso.$_GET) is 0
      $output+="<div style='color:#cd6e00;font-weight:normal;padding:4px 0 4px 0'>" + @Exspresso.lang.line('profiler_no_get') + "</div>"

    else
      $output+="\n\n<table style='width:100%; border:none'>\n"

      for $key, $val of @Exspresso.$_GET
        if not is_numeric($key)
          $key = "'" + $key + "'"

        $output+="<tr><td style='width:50%;color:#000;background-color:#ddd;padding:5px'>&#36;_GET[" + $key + "]&nbsp;&nbsp; </td><td style='width:50%;padding:5px;color:#cd6e00;font-weight:normal;background-color:#ddd;'>"
        if is_array($val)
          $output+="<pre>" + htmlspecialchars(stripslashes(print_r($val, true))) + "</pre>"

        else
          $output+=htmlspecialchars(stripslashes($val))

        $output+="</td></tr>\n"


      $output+="</table>\n"

    $output+="</fieldset>"

    return $output

  #  --------------------------------------------------------------------
  
  #
  # Compile @Exspresso.$_POST Data
  #
  # @return	string
  #
  _compile_post: () ->
    $output = "\n\n"
    $output+='<fieldset id="ci_profiler_post" style="border:1px solid #009900;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
    $output+="\n"
    $output+='<legend style="color:#009900;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_post_data') + '&nbsp;&nbsp;</legend>'
    $output+="\n"

    if count(@Exspresso.$_POST) is 0
      $output+="<div style='color:#009900;font-weight:normal;padding:4px 0 4px 0'>" + @Exspresso.lang.line('profiler_no_post') + "</div>"

    else
      $output+="\n\n<table style='width:100%'>\n"

      for $key, $val of @Exspresso.$_POST
        if not is_numeric($key)
          $key = "'" + $key + "'"


        $output+="<tr><td style='width:50%;padding:5px;color:#000;background-color:#ddd;'>&#36;_POST[" + $key + "]&nbsp;&nbsp; </td><td style='width:50%;padding:5px;color:#009900;font-weight:normal;background-color:#ddd;'>"
        if is_array($val)
          $output+="<pre>" + htmlspecialchars(stripslashes(print_r($val, true))) + "</pre>"

        else
          $output+=htmlspecialchars(stripslashes($val))

        $output+="</td></tr>\n"


      $output+="</table>\n"

    $output+="</fieldset>"

    return $output

  #  --------------------------------------------------------------------
  
  #
  # Show query string
  #
  # @return	string
  #
  _compile_uri_string: () ->
    $output = "\n\n"
    $output+='<fieldset id="ci_profiler_uri_string" style="border:1px solid #000;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
    $output+="\n"
    $output+='<legend style="color:#000;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_uri_string') + '&nbsp;&nbsp;</legend>'
    $output+="\n"

    if @Exspresso.uri.uri_string() is ''
      $output+="<div style='color:#000;font-weight:normal;padding:4px 0 4px 0'>" + @Exspresso.lang.line('profiler_no_uri') + "</div>"

    else
      $output+="<div style='color:#000;font-weight:normal;padding:4px 0 4px 0'>" + @Exspresso.uri.uri_string() + "</div>"

    $output+="</fieldset>"

    return $output

  #  --------------------------------------------------------------------
  
  #
  # Show the controller and function that were called
  #
  # @return	string
  #
  _compile_controller_info: () ->
    $output = "\n\n"
    $output+='<fieldset id="ci_profiler_controller_info" style="border:1px solid #995300;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
    $output+="\n"
    $output+='<legend style="color:#995300;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_controller_info') + '&nbsp;&nbsp;</legend>'
    $output+="\n"

    $output+="<div style='color:#995300;font-weight:normal;padding:4px 0 4px 0'>" + @Exspresso.router.fetch_class() + "/" + @Exspresso.router.fetch_method() + "</div>"

    $output+="</fieldset>"

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
    $output+='<fieldset id="ci_profiler_memory_usage" style="border:1px solid #5a0099;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
    $output+="\n"
    $output+='<legend style="color:#5a0099;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_memory_usage') + '&nbsp;&nbsp;</legend>'
    $output+="\n"

    if function_exists('memory_get_usage') and ($usage = memory_get_usage()) isnt ''
      $output+="<div style='color:#5a0099;font-weight:normal;padding:4px 0 4px 0'>" + number_format($usage) + ' bytes</div>'

    else
      $output+="<div style='color:#5a0099;font-weight:normal;padding:4px 0 4px 0'>" + @Exspresso.lang.line('profiler_no_memory_usage') + "</div>"

    $output+="</fieldset>"

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
    $output+='<fieldset id="ci_profiler_http_headers" style="border:1px solid #000;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
    $output+="\n"
    $output+='<legend style="color:#000;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_headers') + '&nbsp;&nbsp;</legend>'
    $output+="\n"

    $output+="\n\n<table style='width:100%'>\n"

    for $header in ['HTTP_ACCEPT', 'HTTP_USER_AGENT', 'HTTP_CONNECTION', 'SERVER_PORT', 'SERVER_NAME', 'REMOTE_ADDR', 'SERVER_SOFTWARE', 'HTTP_ACCEPT_LANGUAGE', 'SCRIPT_NAME', 'REQUEST_METHOD', ' HTTP_HOST', 'REMOTE_HOST', 'CONTENT_TYPE', 'SERVER_PROTOCOL', 'QUERY_STRING', 'HTTP_ACCEPT_ENCODING', 'HTTP_X_FORWARDED_FOR']
      $val = if (@Exspresso.$_SERVER[$header]? ) then @Exspresso.$_SERVER[$header] else ''
      $output+="<tr><td style='vertical-align: top;width:50%;padding:5px;color:#900;background-color:#ddd;'>" + $header + "&nbsp;&nbsp;</td><td style='width:50%;padding:5px;color:#000;background-color:#ddd;'>" + $val + "</td></tr>\n"

    $output+="</table>\n"
    $output+="</fieldset>"

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
    $output+='<fieldset id="ci_profiler_config" style="border:1px solid #000;padding:6px 10px 10px 10px;margin:20px 0 20px 0;background-color:#eee">'
    $output+="\n"
    $output+='<legend style="color:#000;">&nbsp;&nbsp;' + @Exspresso.lang.line('profiler_config') + '&nbsp;&nbsp;</legend>'
    $output+="\n"

    $output+="\n\n<table style='width:100%'>\n"

    for $config, $val of @Exspresso.config.config
      if is_array($val)
        $val = print_r($val, true)

      $output+="<tr><td style='padding:5px; vertical-align: top;color:#900;background-color:#ddd;'>" + $config + "&nbsp;&nbsp;</td><td style='padding:5px; color:#000;background-color:#ddd;'>" + htmlspecialchars($val) + "</td></tr>\n"

    $output+="</table>\n"
    $output+="</fieldset>"

    return $output

  #  --------------------------------------------------------------------
  
  #
  # Run the Profiler
  #
  # @return	string
  #
  run: () ->
    $output = "<div id='exspresso_profiler' style='clear:both;background-color:#fff;padding:10px;'>"
    $fields_displayed = 0

    for $section, $enabled of @_enabled_sections
      if $enabled isnt false
        $func = "_compile_#{$section}"
        $output+=@[$func]()
        $fields_displayed++

    if $fields_displayed is 0
      $output+='<p style="border:1px solid #5a0099;padding:10px;margin:20px 0;background-color:#eee">' + @Exspresso.lang.line('profiler_no_profiles') + '</p>'

    $output+='</div>'

    return $output


#  END Base_Profiler class
module.exports = Base_Profiler
#  End of file Profiler.php 
#  Location: ./system/libraries/Base/Profiler.php