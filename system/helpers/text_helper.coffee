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
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

# ------------------------------------------------------------------------

#
#  Exspresso Text Helpers
# 
#  @package    Exspresso
#  @subpackage  Helpers
#  @category  Helpers
#  @author    darkoverlordofdata
#  @link    http://darkoverlordofdata.com/user_guide/helpers/text_helper.html
#

# ------------------------------------------------------------------------

#
#  Word Limiter
# 
#  Limits a string to X number of words.
# 
#  @access  public
#  @param  string
#  @param  integer
#  @param  string  the end character. Usually an ellipsis
#  @return  string
#
if ( not function_exists('word_limiter'))

  exports.word_limiter = word_limiter = ($str, $limit = 100, $end_char = '&#8230;') ->

    if trim($str) is ''
      return $str

    $matches = preg_match('/^\\s*+(?:\\S++\\s*+)1,'+$limit+'/', $str)

    if strlen($str) is strlen($matches[0])
      $end_char = ''

    return rtrim($matches[0])+$end_char



# ------------------------------------------------------------------------

#
#  Character Limiter
#
#  Limits the string based on the character count.  Preserves complete words
#  so the character count may not be exactly as specified.
#
#  @access  public
#  @param  string
#  @param  integer
#  @param  string  the end character. Usually an ellipsis
#  @return  string
#
if ( not function_exists('character_limiter'))

  exports.character_limiter = character_limiter = ($str, $n = 500, $end_char = '&#8230;') ->

    if strlen($str) < $n
      return $str

    $str = preg_replace("/\\s+/", ' ', str_replace(["\r\n", "\r", "\n"], ' ', $str))

    if strlen($str) <= $n
      return $str

    $out = ""
    for $val in explode(' ', trim($str)) 
      $out += $val+' '
      if strlen($out) >= $n
        $out = trim($out)
        return if strlen($out) is strlen($str) then $out else $out+$end_char


# ------------------------------------------------------------------------

#
#  High ASCII to Entities
#
#  Converts High ascii text and MS Word special characters to character entities
#
#  @access  public
#  @param  string
#  @return  string
#
if ( not function_exists('ascii_to_entities'))

  exports.ascii_to_entities = ascii_to_entities = ($str) ->

    $count  = 1
    $out  = ''
    $temp  = []

    for $char in $str

      $ordinal = $char.charCodeAt(0)
      if $ordinal < 128

        #
        #  If the $temp array has a value but we have moved on, then it seems only
        #  fair that we output that entity and restart $temp before continuing. -Paul
        #
        if count($temp) is 1
          $out  += '&#'+array_shift($temp)+';'
          $count = 1

        $out += $char

      else

        if count($temp) is 0
          $count = if $ordinal < 224 then 2 else 3

        $temp.push $ordinal

        if $temp.length is $count

          $number = if $count is 3 then (($temp['0'] % 16) *  4096) + (($temp['1'] % 64) *  64) + ($temp['2'] % 64) else (($temp['0'] % 32) * 64) + ($temp['1'] % 64)
          $out += '&#'+$number+';'
          $count = 1
          $temp = []

    return $out



# ------------------------------------------------------------------------

#
#  Entities to ASCII
#
#  Converts character entities back to ASCII
#
#  @access  public
#  @param  string
#  @param  bool
#  @return  string
#
if ( not function_exists('entities_to_ascii'))

  exports.entities_to_ascii = entities_to_ascii = ($str, $all = true) ->

    $matches = preg_match_all('/\\&#(\\d+)\\;/', $str)
    if $matches.length > 0

      for $i in [0..$matches['0'].length-1]

        $digits = $matches['1'][$i]
        $out = ''
        if $digits < 128

          $out += String.fromCharCode($digits)

        else if $digits < 2048

          $out += String.fromCharCode(192 + (($digits - ($digits % 64)) / 64))
          $out += String.fromCharCode(128 + ($digits % 64))

        else

          $out += String.fromCharCode(224 + (($digits - ($digits % 4096)) / 4096))
          $out += String.fromCharCode(128 + ((($digits % 4096) - ($digits % 64)) / 64))
          $out += String.fromCharCode(128 + ($digits % 64))

        $str = str_replace($matches['0'][$i], $out, $str)

    if ($all)

      $str = str_replace(["&amp;", "&lt;", "&gt;", "&quot;", "&apos;", "&#45;"],
                ["&","<",">","\"", "'", "-"], $str)


    return $str



# ------------------------------------------------------------------------

#
#  Word Censoring Function
#
#  Supply a string and an array of disallowed words and any
#  matched words will be converted to #### or to the replacement
#  word you've submitted.
#
#  @access  public
#  @param  string  the text string
#  @param  string  the array of censoered words
#  @param  string  the optional replacement value
#  @return  string
#
if ( not function_exists('word_censor'))

  exports.word_censor = word_censor = ($str, $censored, $replacement = '') ->

    if not is_array($censored)
      return $str

    $str = ' '+$str+' '

    # \w, \b and a few others do not match on a unicode character
    # set for performance reasons. As a result words like über
    # will not match on a word boundary. Instead, we'll assume that
    # a bad word will be bookeneded by any of these characters.
    $delim = '[-_\'\"`(){}<>\[\]|!?@#%&,.:;^~*+=\/ 0-9\n\r\t]'

    for $badword in $censored

      if ($replacement isnt '')

        $str = preg_replace("/(#{$delim})("+str_replace('\*', '\w*?', preg_quote($badword, '/'))+")(#{$delim})/i", "$1#{$replacement}$3", $str)

      else

        $str = preg_replace("/(#{$delim})("+str_replace('\*', '\w*?', preg_quote($badword, '/'))+")(#{$delim})/ie", "'$1'+str_repeat('#', strlen('$2'))+'$3'", $str);

    return trim($str)

# ------------------------------------------------------------------------

#
#  Code Highlighter - use google-code-prettify on the client
#
#  Colorizes code strings
#
#  @access  public
#  @param  string  the text string
#  @return  string
#
if ( not function_exists('highlight_code'))

  exports.highlight_code = highlight_code = ($str) ->

    # All the magic happens here, babynot
    #$str = highlight_string($str, true)

    return $str



# ------------------------------------------------------------------------

#
#  Phrase Highlighter
#
#  Highlights a phrase within a text string
#
#  @access  public
#  @param  string  the text string
#  @param  string  the phrase you'd like to highlight
#  @param  string  the openging tag to precede the phrase with
#  @param  string  the closing tag to end the phrase with
#  @return  string
#
if ( not function_exists('highlight_phrase'))

  exports.highlight_phrase = highlight_phrase = ($str, $phrase, $tag_open = '<strong>', $tag_close = '</strong>') ->

    if $str is ''
      return ''

    if $phrase isnt ''
      return preg_replace('/('+preg_quote($phrase, '/')+')/i', $tag_open+"$1"+$tag_close, $str)

    return $str



# ------------------------------------------------------------------------

#
#  Convert Accented Foreign Characters to ASCII
#
#  @access  public
#  @param  string  the text string
#  @return  string
#
if ( not function_exists('convert_accented_characters'))

  exports.convert_accented_characters = convert_accented_characters = ($str) ->

    if (defined('ENVIRONMENT') AND is_file(APPPATH+'config/'+ENVIRONMENT+'/foreign_chars'+EXT))

      $foreign_characters = require(APPPATH+'config/'+ENVIRONMENT+'/foreign_chars'+EXT)

    else if (is_file(APPPATH+'config/foreign_chars'+EXT))

      $foreign_characters = require(APPPATH+'config/foreign_chars'+EXT)

    if not $foreign_characters?
      return $str

    return preg_replace(array_keys($foreign_characters), array_values($foreign_characters), $str)



# ------------------------------------------------------------------------

#
#  Word Wrap
#
#  Wraps text at the specified character.  Maintains the integrity of words.
#  Anything placed between unwrap/unwrap will not be word wrapped, nor
#  will URLs.
#
#  @access  public
#  @param  string  the text string
#  @param  integer  the number of characters to wrap at
#  @return  string
#
if ( not function_exists('word_wrap'))

  exports.word_wrap = word_wrap = ($str, $charlim = '76') ->

    # Se the character limit
    if not is_numeric($charlim)
      $charlim = 76

    # Reduce multiple spaces
    $str = preg_replace("| +|", " ", $str)

    # Standardize newlines
    if (strpos($str, "\r") isnt false)
      $str = str_replace(["\r\n", "\r"], "\n", $str)

    # If the current word is surrounded by unwrap tags we'll
    # strip the entire chunk and replace it with a marker.
    $unwrap = []
    $matches = preg_match_all("|(\{unwrap\}.+?\{/unwrap\})|s", $str)
    if $matches.length > 0

      for $i in [0..$matches['0'].length-1]

        $unwrap.push $matches['1'][$i]
        $str = str_replace($matches['1'][$i], "{{unwrapped"+$i+"}}", $str)

    # Use PHP's native function to do the initial wordwrap.
    # We set the cut flag to false so that any individual words that are
    # too long get left alone.  In the next step we'll deal with them.
    $str = wordwrap($str, $charlim, "\n", false)

    # Split the string into individual lines of text and cycle through them
    $output = ""
    for line in explode("\n", $str)

      # Is the line within the allowed character count?
      # If so we'll join it to the output and continue
      if strlen($line) <= $charlim
        $output += $line+"\n"
        continue

      $temp = ''
      while strlen($line) > $charlim

        # If the over-length word is a URL we won't wrap it
        if preg_match("!\\[url.+\\]|://|wwww.!", $line)?
          break

        # Trim the word down
        $temp += substr($line, 0, $charlim-1)
        $line = substr($line, $charlim-1)

      # If $temp contains data it means we had to split up an over-length
      # word into smaller chunks so we'll add it back to our current line
      if ($temp isnt '')
        $output += $temp+"\n"+$line

      else
        $output += $line

      $output += "\n"

    # Put our markers back
    if count($unwrap) > 0

      for $key, $val of $unwrap
        $output = str_replace("{{unwrapped"+$key+"}}", $val, $output)

    # Remove the unwrap tags
    $output = str_replace(['{unwrap}', '{/unwrap}'], '', $output)
    return $output



# ------------------------------------------------------------------------

#
#  Ellipsize String
#
#  This function will strip tags from a string, split it at its max_length and ellipsize
#
#  @param  string    string to ellipsize
#  @param  integer    max length of string
#  @param  mixed    int (1|0) or float, .5, .2, etc for position to split
#  @param  string    ellipsis ; Default '...'
#  @return  string    ellipsized string
#
if ( not function_exists('ellipsize'))

  exports.ellipsize = ellipsize = ($str, $max_length, $position = 1, $ellipsis = '&hellip;') ->
  
    # Strip tags
    $str = trim(strip_tags($str))

    # Is the string long enough to ellipsize?
    if strlen($str) <= $max_length
      return $str

    $beg = substr($str, 0, Math.floor($max_length * $position))

    $position = if $position > 1 then 1 else $position

    if $position is 1
      $end = substr($str, 0, -($max_length - strlen($beg)))
    
    else
      $end = substr($str, -($max_length - strlen($beg)))

    return $beg+$ellipsis+$end
  


# End of file text_helper.coffee
# Location: ./system/helpers/text_helper.coffee