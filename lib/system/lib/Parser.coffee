#+--------------------------------------------------------------------+
#  Parser.coffee
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
# Parser Class
#
#   lightweight template
#
#
module.exports = class system.lib.Parser
  
  _left         : '{'   # Left delimiter
  _right        : '}'   # Right delimiter
  _lreg         : "\\{" # Escaped left delimiter
  _rreg         : "\\}" # Escaped right delimiter


  constructor: ($controller, $config = {}) ->

    # Initialize the config preferences
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    @setDelimiters @_left, @_right
    log_message 'debug', "Parser Class Initialized"

  #
  #  Parse a template
  #
  # Parses pseudo-variables contained in the specified template view,
  # replacing them with the data in the second param
  #
  # @param  [String]
  # @param  [Array]
  # @param  [Function]
  # @return [Void]
  #
  parse: ($template, $data = {}, $next) ->

    @load.view $template, $data, ($err, $template) =>
      ($next ? @next)(null, @_parse($template, $data, $next?))



  #
  #  Parse a String
  #
  # Parses pseudo-variables contained in the specified string,
  # replacing them with the data in the second param
  #
  # @param  [String]
  # @param  [Array]
  # @return	[Boolean]
  # @return	[String]
  #
  parseString: ($template, $data, $return = false) ->
    @_parse($template, $data, $return)


  #
  #  Parse a template
  #
  # Parses pseudo-variables contained in the specified template,
  # replacing them with the data in the second param
  #
  # @param  [String]
  # @param  [Array]
  # @return	[Boolean]
  # @return	[String]
  #
  _parse: ($template, $data, $return = false) ->
    return '' if $template is ''

    for $key, $val of $data
      if Array.isArray($val)
        $template = @_parse_pair($key, $val, $template)
      else
        $template = @_parse_single($key, ''+$val, $template)

    if $return is false
      @output.appendOutput($template)

    return $template


  #
  #  Set the left/right variable delimiters
  #
  # @param  [String]
  # @param  [String]
  # @return [Void]
  #
  setDelimiters: ($l_delim = '{', $r_delim = '}') ->
    @_left = $l_delim
    @_right = $r_delim
    @_lreg = reg_quote($l_delim)
    @_rreg = reg_quote($r_delim)
    return


  #
  #  Parse a single key/value
  #
  # @private
  # @param  [String]
  # @param  [String]
  # @param  [String]
  # @return	[String]
  #
  _parse_single: ($key, $val, $string) ->
    $string.replace(@_left + $key + @_right, $val)


  #
  #  Parse a tag pair
  #
  # Parses tag pairs:  {some_tag} string... {/some_tag}
  #
  # @private
  # @param  [String]
  # @param  [Array]
  # @param  [String]
  # @return	[String]
  #
  _parse_pair: ($variable, $data, $string) ->
    if false is ($match = @_match_pair($string, $variable))
      return $string

    $str = ''
    for $row in $data
      $temp = $match[1]
      for $key, $val of $row
        if not Array.isArray($val)
          $temp = @_parse_single($key, $val, $temp)
        else
          $temp = @_parse_pair($key, $val, $temp)
      $str+=$temp
    return $string.replace($match[0], $str)


  #
  #  Matches a variable pair
  #
  # @private
  # @param  [String]
  # @param  [String]
  # @return [Mixed]
  #
  _match_pair: ($string, $variable) ->
    $re = @_lreg + $variable + @_rreg + "([\\s\\S]*)" + @_lreg + reg_quote('/') + $variable + @_rreg
    if not ($match = $string.match(RegExp($re,"m")))?
      return false
    return $match


