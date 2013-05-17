#+--------------------------------------------------------------------+
#  ckeditor.coffee
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
#
# Copyright (c) 2003-2012, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see LICENSE.html or http://ckeditor.com/license
#

#
# \brief CKEditor class that can be used to create editor
# instances in coffee pages on server side.
# @see http://ckeditor.com
#
# Sample usage:
# @code
# <% $CKEditor = new CKEditor() %>
# <%- $CKEditor.editor("editor1", "<p>Initial value.</p>") %>
# @endcode
#
module.exports = class CKEditor

  #
  # import the compatability api
  #
  log_message 'debug', 'CKEditor loading not-php api'
  api = require('not-php')
  eval "#{$name} = api.#{$name}" for $name, $body of api


  #
  # The version of %CKEditor.
  #
  CKEditor.version = '3.6.5'

  #
  # A constant string unique for each release of %CKEditor.
  #
  CKEditor.timestamp = 'C9A85WF'

  #
  # URL to the %CKEditor installation directory (absolute or relative to document root).
  # If not set, CKEditor will try to guess it's path.
  #
  # Example usage:
  # @code
  # $CKEditor.basePath = '/ckeditor/'
  # @endcode
  #
  basePath: ''
  #
  # An array that holds the global %CKEditor configuration.
  # For the list of available options, see http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.config.html
  #
  # Example usage:
  # @code
  # $CKEditor.config['height'] = 400
  # // Use @@ at the beggining of a string to ouput it without surrounding quotes.
  # $CKEditor.config['width'] = '@@screen.width * 0.8'
  # @endcode
  #
  config: {}
  #
  # A boolean variable indicating whether CKEditor has been initialized.
  # Set it to true only if you have already included
  # &lt;script&gt; tag loading ckeditor.js in your website.
  #
  initialized: false
  #
  # Boolean variable indicating whether created code should be printed out or returned by a function.
  #
  # Example 1: get the code creating %CKEditor instance and print it on a page with the "echo" function.
  # @code
  # $CKEditor = new CKEditor()
  # $CKEditor.returnOutput = true
  # $code = $CKEditor.editor("editor1", "<p>Initial value.</p>")
  # ...
  # <p>Editor 1:</p>
  # <%- $code %>
  # @endcode
  #
  returnOutput: false
  #
  # An array with textarea attributes.
  #
  # When %CKEditor is created with the editor() method, a HTML &lt;textarea&gt; element is created,
  # it will be displayed to anyone with JavaScript disabled or with incompatible browser.
  #
  textareaAttributes: rows:'8', cols:'60'
  #
  # A string indicating the creation date of %CKEditor.
  # Do not change it unless you want to force browsers to not use previously cached version of %CKEditor.
  #
  timestamp: "C9A85WF"
  #
  # An array that holds event listeners.
  #
  events: {}
  #
  # An array that holds global event listeners.
  #
  globalEvents: {}

  $returnedEvents = $returnedEvents ? {}  # static
  $initComplete = $initComplete ? {}      # static
  #
  # Main Constructor.
  #
  #  @param $basePath (string) URL to the %CKEditor installation directory (optional).
  #
  constructor : ($basePath = null) ->

    @config = {}
    @events = {}
    @globalEvents = {}
    if not empty($basePath)
      @basePath = $basePath


  #
  # Creates a %CKEditor instance.
  # In incompatible browsers %CKEditor will downgrade to plain HTML &lt;textarea&gt; element.
  #
  # @param $name (string) Name of the %CKEditor instance (this will be also the "name" attribute of textarea element).
  # @param $value (string) Initial value (optional).
  # @param $config (array) The specific configurations to apply to this editor instance (optional).
  # @param $events (array) Event listeners for this editor instance (optional).
  #
  # Example usage:
  # @code
  # $CKEditor = new CKEditor()
  # $CKEditor.editor("field1", "<p>Initial value.</p>")
  # @endcode
  #
  # Advanced example:
  # @code
  # $CKEditor = new CKEditor()
  # $config =
  #   toolbar: [
  #     [ 'Source', '-', 'Bold', 'Italic', 'Underline', 'Strike' ]
  #     [ 'Image', 'Link', 'Unlink', 'Anchor' ]
  #   ]
  # $events['instanceReady'] = """function (ev) {
  #     alert("Loaded: " + ev.editor.name);
  #   }"""
  # $CKEditor.editor("field1", "<p>Initial value.</p>", $config, $events)
  # @endcode
  #
  editor: ($name, $value = "",$config = {},$events = {}) ->

    $attr = ""
    for $key, $val of @textareaAttributes
      $attr+=" " + $key + '="' + str_replace('"', '&quot;', $val) + '"'

    $out = "<textarea name=\"" + $name + "\"" + $attr + ">" + htmlspecialchars($value) + "</textarea>\n"
    if not @initialized
      $out+=@init()

    $_config = @configSettings($config, $events)

    $js = @returnGlobalEvents()
    if not empty($_config) then $js+="CKEDITOR.replace('" + $name + "', " + @jsEncode($_config) + ");"
    else $js+="CKEDITOR.replace('" + $name + "');"

    $out+=@script($js)

    if not @returnOutput
      print $out
      $out = ""

    return $out

  #
  # Replaces a &lt;textarea&gt; with a %CKEditor instance.
  #
  # @param $id (string) The id or name of textarea element.
  # @param $config (array) The specific configurations to apply to this editor instance (optional).
  # @param $events (array) Event listeners for this editor instance (optional).
  #
  # Example 1: adding %CKEditor to &lt;textarea name="article"&gt;&lt;/textarea&gt; element:
  # @code
  # $CKEditor = new CKEditor()
  # $CKEditor.replace("article")
  # @endcode
  #
  replace: ($id, $config = {},$events = {}) ->
    $out = ""
    if not @initialized
      $out+=@init()

    $_config = @configSettings($config, $events)

    $js = @returnGlobalEvents()
    if not empty($_config)
      $js+="CKEDITOR.replace('" + $id + "', " + @jsEncode($_config) + ");"
    else
      $js+="CKEDITOR.replace('" + $id + "');"

    $out+=@script($js)

    if not @returnOutput
      print $out
      $out = ""

    return $out

  #
  # Replace all &lt;textarea&gt; elements available in the document with editor instances.
  #
  # @param $className (string) If set, replace all textareas with class className in the page.
  #
  # Example 1: replace all &lt;textarea&gt; elements in the page.
  # @code
  # $CKEditor = new CKEditor()
  # $CKEditor.replaceAll()
  # @endcode
  #
  # Example 2: replace all &lt;textarea class="myClassName"&gt; elements in the page.
  # @code
  # $CKEditor = new CKEditor()
  # $CKEditor.replaceAll( 'myClassName' )
  # @endcode
  #
  replaceAll: ($className = null) ->
    $out = ""
    if not @initialized
      $out+=@init()

    $_config = @configSettings()

    $js = @returnGlobalEvents()
    if empty($_config)
      if empty($className)
        $js+="CKEDITOR.replaceAll();"

      else
        $js+="CKEDITOR.replaceAll('" + $className + "');"

    else
      $classDetection = ""
      $js+="CKEDITOR.replaceAll( function(textarea, config) {\n"
      if not empty($className)
        $js+="	var classRegex = new RegExp('(?:^| )' + '" + $className + "' + '(?:$| )');\n"
        $js+="	if (!classRegex.test(textarea.className))\n"
        $js+="		return false;\n"

      $js+="	CKEDITOR.tools.extend(config, " + @jsEncode($_config) + ", true);"
      $js+="} );"

    $out+=@script($js)

    if not @returnOutput
      print $out
      $out = ""

    return $out

  #
  # Adds event listener.
  # Events are fired by %CKEditor in various situations.
  #
  # @param $event (string) Event name.
  # @param $javascriptCode (string) Javascript anonymous function or function name.
  #
  # Example usage:
  # @code
  # $CKEditor.addEventHandler('instanceReady', """function (ev) {
  #     alert("Loaded: " + ev.editor.name);
  #   }""")
  # @endcode
  #
  addEventHandler: ($event, $javascriptCode) ->
    if not @events[$event]?
      @events[$event] = []

    #  Avoid duplicates.
    if not in_array($javascriptCode, @events[$event])
      @events[$event].push $javascriptCode


  #
  # Clear registered event handlers.
  # Note: this function will have no effect on already created editor instances.
  #
  # @param $event (string) Event name, if not set all event handlers will be removed (optional).
  #
  clearEventHandlers: ($event = null) ->
    if not empty($event)
      @events[$event] = []

    else
      @events = {}


  #
  # Adds global event listener.
  #
  # @param $event (string) Event name.
  # @param $javascriptCode (string) Javascript anonymous function or function name.
  #
  # Example usage:
  # @code
  # $CKEditor.addGlobalEventHandler('dialogDefinition', """function (ev) {
  #     alert("Loading dialog: " + ev.data.name);
  #   }""")
  # @endcode
  #
  addGlobalEventHandler: ($event, $javascriptCode) ->

    if not @globalEvents[$event]?
      @globalEvents[$event] = {}

    #  Avoid duplicates.
    if not in_array($javascriptCode, @globalEvents[$event])
      @globalEvents[$event].push $javascriptCode


  #
  # Clear registered global event handlers.
  # Note: this function will have no effect if the event handler has been already printed/returned.
  #
  # @param $event (string) Event name, if not set all event handlers will be removed (optional).
  #
  clearGlobalEventHandlers: ($event = null) ->

    if not empty($event)
      @globalEvents[$event] = {}

    else
      @globalEvents = {}

  #
  # Prints javascript code.
  #
  # @param  [String]  $js
  #
  script: ($js) ->
    $out = "<script type=\"text/javascript\">"
    $out+="//<![CDATA[\n"
    $out+=$js
    $out+="\n//]]>"
    $out+="</script>\n"

    return $out

  #
  # Returns the configuration array (global and instance specific settings are merged into one array).
  #
  # @param $config (array) The specific configurations to apply to editor instance.
  # @param $events (array) Event listeners for editor instance.
  #
  configSettings: ($config = {},$events = {}) ->

    $_config = @config
    $_events = @events

    if is_array($config) and  not empty($config)
      $_config = array_merge($_config, $config)


    if is_array($events) and  not empty($events)
      for $eventName, $code of $events
        if not $_events[$eventName]?
          $_events[$eventName] = {}

        if not in_array($code, $_events[$eventName])
          $_events[$eventName].push $code

    if not empty($_events)
      for $eventName, $handlers of $_events
        if empty($handlers)
          continue

        else if count($handlers) is 1
          $_config['on'][$eventName] = '@@' + $handlers[0]

        else
          $_config['on'][$eventName] = '@@function (ev){'
          for $handler, $code of $handlers
            $_config['on'][$eventName]+='(' + $code + ')(ev);'

          $_config['on'][$eventName]+='}'

    return $_config

  #
  # Return global event handlers.
  #
  returnGlobalEvents: () ->

    $out = ""

    if not $returnedEvents?
      $returnedEvents = {}

    if not empty(@globalEvents)
      for $eventName, $handlers of @globalEvents
        for $handler, $code of $handlers
          if not $returnedEvents[$eventName]?
            $returnedEvents[$eventName] = []

          #  Return only new events
          if not in_array($code, $returnedEvents[$eventName])
            $out+=(if $code then "\n" else "") + "CKEDITOR.on('" + $eventName + "', $code);"
            $returnedEvents[$eventName].push $code

    return $out

  #
  # Initializes CKEditor (executed only once).
  #
  init: () ->

    $out = ""

    #if not empty($initComplete)
    #  return ""

    if @initialized
      $initComplete = true
      return ""

    $args = ""
    $ckeditorPath = @ckeditorPath()

    if not empty(@timestamp) and @timestamp isnt "%" + "TIMESTAMP%"
      $args = '?t=' + @timestamp

    #  Skip relative paths...
    if $ckeditorPath.indexOf('..') isnt 0
      $out+=@script("window.CKEDITOR_SYSPATH='" + $ckeditorPath + "';")

    $out+="<script type=\"text/javascript\" src=\"" + $ckeditorPath + 'ckeditor.js' + $args + "\"></script>\n"

    $extraCode = ""
    if @timestamp isnt CKEditor.timestamp
      $extraCode+=(if $extraCode then "\n" else "") + "CKEDITOR.timestamp = '" + @timestamp + "';"

    if $extraCode
      $out+=@script($extraCode)

    $initComplete = @initialized = true
    return $out

  #
  # Return path to ckeditor.js.
  #
  ckeditorPath: () ->

    if not empty(@basePath)
      return @basePath
    return "/ckeditor/"

  #
  # This little function provides a basic JSON support.
  #
  # @param  [Mixed]  $val
  # @return string
  #
  jsEncode: ($val) ->

    if not($val?)
      return 'null'

    if 'boolean' is typeof($val)
      return if $val then 'true' else 'false'

    if 'number' is typeof($val)
      return str_replace(',', '.', ''+$val)

    if is_array($val) or 'object' is typeof($val)
      if Array.isArray($val)
        return '[' + implode(',', array_map([@, 'jsEncode'], $val)) + ']'

      $temp = []
      for $k, $v of $val
        $temp.push @jsEncode("#{$k}") + ':' + @jsEncode($v)

      return '{' + $temp.join(',') + '}'
      #return '{' + implode(',', $temp) + '}'

    #  String otherwise
    if $val.indexOf('@@') is 0 then return substr($val, 2)
    if substr($val.toUpperCase(), 0, 9) is 'CKEDITOR.' then return $val
    return '"' + str_replace(["\\", "/", "\n", "\t", "\r", "\x08", "\x0c", '"'], ['\\\\', '\\/', '\\n', '\\t', '\\r', '\\b', '\\f', '\"'], $val) + '"'

