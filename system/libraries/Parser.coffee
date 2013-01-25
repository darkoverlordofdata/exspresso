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
# Parser Class
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Parser
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/parser.html
#
class global.Exspresso_Parser
  
  l_delim: '{'
  r_delim: '}'

  constructor: ($config = {}, @Exspresso) ->

    @[$key] = $val for $key, $val of $config

  #
  #  Parse a template
  #
  # Parses pseudo-variables contained in the specified template view,
  # replacing them with the data in the second param
  #
  # @access	public
  # @param	string
  # @param	array
  # @param	function
  # @return	void
  #
  parse: ($template, $data, $callback) ->

    $fn_err = $callback ? show_error

    @Exspresso.load.view $template, $data, ($err, $template) =>

      if $err then $fn_err $err
      else
        if $callback? then $callback null, @_parse($template, $data, true)
        else
          @_parse($template, $data, false)


  #  --------------------------------------------------------------------
  
  #
  #  Parse a String
  #
  # Parses pseudo-variables contained in the specified string,
  # replacing them with the data in the second param
  #
  # @access	public
  # @param	string
  # @param	array
  # @param	bool
  # @return	string
  #
  parse_string: ($template, $data, $return = false) ->
    @_parse($template, $data, $return)
    
  
  #  --------------------------------------------------------------------
  
  #
  #  Parse a template
  #
  # Parses pseudo-variables contained in the specified template,
  # replacing them with the data in the second param
  #
  # @access	public
  # @param	string
  # @param	array
  # @param	bool
  # @return	string
  #
  _parse: ($template, $data, $return = false) ->
    if $template is ''
      return ''
      
    
    for $key, $val of $data
      if is_array($val)
        $template = @_parse_pair($key, $val, $template)
        
      else 
        $template = @_parse_single($key, ''+$val, $template)

    if $return is false
      @Exspresso.output.append_output($template)
      @Exspresso.output._display()

    return $template
    
  
  #  --------------------------------------------------------------------
  
  #
  #  Set the left/right variable delimiters
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	void
  #
  set_delimiters: ($l = '{', $r = '}') ->
    @l_delim = $l
    @r_delim = $r
    return
    
  
  #  --------------------------------------------------------------------
  
  #
  #  Parse a single key/value
  #
  # @access	private
  # @param	string
  # @param	string
  # @param	string
  # @return	string
  #
  _parse_single: ($key, $val, $string) ->
    return str_replace(@l_delim + $key + @r_delim, $val, $string)
    
  
  #  --------------------------------------------------------------------
  
  #
  #  Parse a tag pair
  #
  # Parses tag pairs:  {some_tag} string... {/some_tag}
  #
  # @access	private
  # @param	string
  # @param	array
  # @param	string
  # @return	string
  #
  _parse_pair: ($variable, $data, $string) ->
    if false is ($match = @_match_pair($string, $variable))
      return $string

    $str = ''
    for $row in $data
      $temp = $match['1']
      for $key, $val of $row
        if not is_array($val)
          $temp = @_parse_single($key, $val, $temp)
          
        else 
          $temp = @_parse_pair($key, $val, $temp)

      $str+=$temp

    return str_replace($match['0'], $str, $string)
    
  
  #  --------------------------------------------------------------------
  
  #
  #  Matches a variable pair
  #
  # @access	private
  # @param	string
  # @param	string
  # @return	mixed
  #
  _match_pair: ($string, $variable) ->
    $match = preg_match("|" + preg_quote(@l_delim) + $variable + preg_quote(@r_delim) + "(.+?)" + preg_quote(@l_delim) + '/' + $variable + preg_quote(@r_delim) + "|s", $string)
    if $match.length is 0
      return false

    return $match
    
  
  

module.exports = Exspresso_Parser
#  END Parser Class

#  End of file Parser.php 
#  Location: ./system/libraries/Parser.php 
