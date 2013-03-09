#+--------------------------------------------------------------------+
#  Typography.coffee
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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Typography Class
#
#
# @access		private
# @category	Helpers
# @author		darkoverlordofdata
# @see 		http://darkoverlordofdata.com/user_guide/helpers/
#
class system.lib.Typography
  
  #  Block level elements that should not be wrapped inside <p> tags
  block_elements: 'address|blockquote|div|dl|fieldset|form|h\d|hr|noscript|object|ol|p|pre|script|table|ul'
  
  #  Elements that should not have <p> and <br /> tags within them.
  skip_elements: 'p|pre|ol|ul|dl|object|table|h\d'
  
  #  Tags we want the parser to completely ignore when splitting the string.
  inline_elements: 'a|abbr|acronym|b|bdo|big|br|button|cite|code|del|dfn|em|i|img|ins|input|label|map|kbd|q|samp|select|small|span|strong|sub|sup|textarea|tt|var'
  
  #  array of block level elements that require inner content to be within another block level element
  inner_block_required: ['blockquote']
  
  #  the last block element parsed
  last_block_element: ''
  
  #  whether or not to protect quotes within { curly braces }
  protect_braced_quotes: false
  
  #
  # Auto Typography
  #
  # This function converts text, making it typographically correct:
  #	- Converts double spaces into paragraphs.
  #	- Converts single line breaks into <br /> tags
  #	- Converts single and double quotes into correctly facing curly quote entities.
  #	- Converts three dots into ellipsis.
  #	- Converts double dashes into em-dashes.
  #  - Converts two spaces into entities
  #
    # @param  [String]    # @return	[Boolean]	whether to reduce more then two consecutive newlines to two
  # @return	[String]
  #
  autoTypography : ($str, $reduce_linebreaks = false) ->
    if $str is ''
      return ''
      
    
    #  Standardize Newlines to make matching easier
    if strpos($str, "\r") isnt false
      $str = str_replace(["\r\n", "\r"], "\n", $str)
      
    
    #  Reduce line breaks.  If there are more than two consecutive linebreaks
    #  we'll compress them down to a maximum of two since there's no benefit to more.
    if $reduce_linebreaks is true
      $str = preg_replace("/\\n\\n+/", "\n\n", $str)
      
    
    #  HTML comment tags don't conform to patterns of normal tags, so pull them out separately, only if needed
    $html_comments = []
    if strpos($str, '<!--') isnt false
      $matches = preg_match_all("#(<!\-\-.*?\-\->)#s", $str)
      if $matches.length > 0
        for $i in [0..$matches[0].length-1]
          $html_comments.push $matches[0][$i]
          $str = str_replace($matches[0][$i], '{@HC' + $i + '}', $str)

    
    #  match and yank <pre> tags if they exist.  It's cheaper to do this separately since most content will
    #  not contain <pre> tags, and it keeps the PCRE patterns below simpler and faster
    if strpos($str, '<pre') isnt false
      $str = preg_replace_callback("#<pre.*?>.*?</pre>#si", [@, '_protect_characters'], $str)
      
    
    #  Convert quotes within tags to temporary markers.
    $str = preg_replace_callback("#<.+?>#si", [@, '_protect_characters'], $str)
    
    #  Do the same with braces if necessary
    if @protect_braced_quotes is true
      $str = preg_replace_callback("#\\{.+?\\}#si", [@, '_protect_characters'], $str)
      
    
    #  Convert "ignore" tags to temporary marker.  The parser splits out the string at every tag
    #  it encounters.  Certain inline tags, like image tags, links, span tags, etc. will be
    #  adversely affected if they are split out so we'll convert the opening bracket < temporarily to: {@TAG}
    $str = preg_replace("#<(/*)(" + @inline_elements + ")([ >])#i", "{@TAG}$1$2$3", $str)
    
    #  Split the string at every tag.  This expression creates an array with this prototype:
    # 
    # 	[array]
    # 	{
    # 		[0] = <opening tag>
    # 		[1] = Content...
    # 		[2] = <closing tag>
    # 		Etc...
    # 	}
    $chunks = preg_split('/(<(?:[^<>]+(?:"[^"]*"|\\\'[^\\\']*\\\')?)+>)/', $str,  - 1, PREG_SPLIT_DELIM_CAPTURE or PREG_SPLIT_NO_EMPTY)
    
    #  Build our finalized string.  We cycle through the array, skipping tags, and processing the contained text
    $str = ''
    $process = true
    $paragraph = false
    $current_chunk = 0
    $total_chunks = count($chunks)
    
    for $chunk in $chunks
      $current_chunk++
      
      #  Are we dealing with a tag? If so, we'll skip the processing for this cycle.
      #  Well also set the "process" flag which allows us to skip <pre> tags and a few other things.
      if ($match = preg_match("#<(/*)(" + @block_elements + ").*?>#", $chunk))?
        if preg_match("#" + @skip_elements + "#", $match[2]).length > 0
          $process = if ($match[1] is '/') then true else false

        if $match[1] is ''
          @last_block_element = $match[2]

        $str+=$chunk
        continue
        
      if $process is false
        $str+=$chunk
        continue

      #   Force a newline to make sure end tags get processed by _format_newlines()
      if $current_chunk is $total_chunks
        $chunk+="\n"

      #   Convert Newlines into <p> and <br /> tags
      $str+=@_format_newlines($chunk)
      
    
    #  No opening block level tag?  Add it if needed.
    if not preg_match("/^\\s*<(?:" + @block_elements + ")/i", $str)
      $str = preg_replace("/^(.*?)<(" + @block_elements + ")/i", '<p>$1</p><$2', $str)
      
    
    #  Convert quotes, elipsis, em-dashes, non-breaking spaces, and ampersands
    $str = @format_characters($str)
    
    #  restore HTML comments
    for $i in [0..$html_comments.length-1]
      #  remove surrounding paragraph tags, but only if there's an opening paragraph tag
      #  otherwise HTML comments at the ends of paragraphs will have the closing tag removed
      #  if '<p>{@HC1}' then replace <p>{@HC1}</p> with the comment, else replace only {@HC1} with the comment
      $str = preg_replace('#(?(?=<p>\\{@HC' + $i + '\\})<p>\\{@HC' + $i + '\\}(\\s*</p>)|\\{@HC' + $i + '\\})#s', $html_comments[$i], $str)

    #  Final clean up
    $table = 
      
      #  If the user submitted their own paragraph tags within the text
      #  we will retain them instead of using our tags.
      '/(<p[^>*?]>)<p>/':   '$1' #  <?php BBEdit syntax coloring bug fix
      
      #  Reduce multiple instances of opening/closing paragraph tags to a single one
      '#(</p>)+#':          '</p>'
      '/(<p>\\W*<p>)+/':    '<p>'
      
      #  Clean up stray paragraph tags that appear before block level elements
      #"#<p></p><(#{@block_elements})#":  '<$1'
      
      #  Clean up stray non-breaking spaces preceeding block elements
      #"#(&nbsp;\\s*)+<(#{@block_elements})#": '  <$2'
      
      #  Replace the temporary markers we added earlier
      '/\\{@TAG\\}/': '<',
      '/\\{@DQ\\}/':  '"',
      '/\\{@SQ\\}/':  "'",
      '/\\{@DD\\}/':  '--',
      '/\\{@NBS\\}/': '  ',
      
      #  An unintended consequence of the _format_newlines function is that
      #  some of the newlines get truncated, resulting in <p> tags
      #  starting immediately after <block> tags on the same line.
      #  This forces a newline after such occurrences, which looks much nicer.
      "/><p>\\n/":  ">\n<p>",
      
      #  Similarly, there might be cases where a closing </block> will follow
      #  a closing </p> tag, so we'll correct it by adding a newline in between
      "#</p></#":   "</p>\n</"

    $table["#<p></p><(#{@block_elements})#"] = '<$1'
    $table["#(&nbsp;\\s*)+<(#{@block_elements})#"] = '  <$2'
    
    #  Do we need to reduce empty lines?
    if $reduce_linebreaks is true
      $table['#<p>\n*</p>#'] = ''
      
    else 
      #  If we have empty paragraph tags we add a non-breaking space
      #  otherwise most browsers won't treat them as true paragraphs
      $table['#<p></p>#'] = '<p>&nbsp;</p>'
      
    
    return preg_replace(array_keys($table), $table, $str)
    
    
  
  #
  # Format Characters
  #
  # This function mainly converts double and single quotes
  # to curly entities, but it also converts em-dashes,
  # double spaces, and ampersands
  #
    # @param  [String]    # @return	[String]
  #
  exports.$table = $table ? {}
  formatCharacters : ($str) ->

    if not $table? 
      $table = 
        #  nested smart quotes, opening and closing
        #  note that rules for grammar (English) allow only for two levels deep
        #  and that single quotes are _supposed_ to always be on the outside
        #  but we'll accommodate both
        #  Note that in all cases, whitespace is the primary determining factor
        #  on which direction to curl, with non-word characters like punctuation
        #  being a secondary factor only after whitespace is addressed.
        '/\\\'"(\\s|$)/':       '&#8217;&#8221;$1',
        '/(^|\\s|<p>)\\\'"/':   '$1&#8216;&#8220;',
        '/\\\'"(\\W)/':         '&#8217;&#8221;$1',
        '/(\\W)\\\'"/':         '$1&#8216;&#8220;',
        '/"\\\'(\\s|$)/':       '&#8221;&#8217;$1',
        '/(^|\\s|<p>)"\\\'/':   '$1&#8220;&#8216;',
        '/"\\\'(\\W)/':         '&#8221;&#8217;$1',
        '/(\\W)"\\\'/':         '$1&#8220;&#8216;',
        
        #  single quote smart quotes
        '/\\\'(\\s|$)/':        '&#8217;$1',
        '/(^|\\s|<p>)\\\'/':    '$1&#8216;',
        '/\\\'(\\W)/':          '&#8217;$1',
        '/(\\W)\\\'/':          '$1&#8216;',
        
        #  double quote smart quotes
        '/"(\\s|$)/':           '&#8221;$1',
        '/(^|\\s|<p>)"/':       '$1&#8220;',
        '/"(\\W)/':             '&#8221;$1',
        '/(\\W)"/':             '$1&#8220;',
        
        #  apostrophes
        "/(\\w)'(\\w)/":        '$1&#8217;$2',
        
        #  Em dash and ellipses dots
        '/\\s?\\-\\-\\s?/':     '&#8212;',
        '/(\\w)\\.{3}/':        '$1&#8230;',
        
        #  double space after sentences
        '/(\\W)  /':            '$1&nbsp; ',
        
        #  ampersands, if not a character entity
        '/&(?!#?[a-zA-Z0-9]{2,};)/':'&amp;'


    return preg_replace(array_keys($table), $table, $str)
    
  
  #
  # Format Newlines
  #
  # Converts newline characters into either <p> tags or <br />
  #
    # @param  [String]    # @return	[String]
  #
  _format_newlines : ($str) ->
    if $str is ''
      return $str
      
    
    if strpos($str, "\n") is false and  not in_array(@last_block_element, @inner_block_required)
      return $str
      
    
    #  Convert two consecutive newlines to paragraphs
    $str = str_replace("\n\n", "</p>\n\n<p>", $str)
    
    #  Convert single spaces to <br /> tags
    $str = preg_replace("/([^\\n])(\\n)([^\\n])/", "$1<br />$2$3", $str)
    
    #  Wrap the whole enchilada in enclosing paragraphs
    if $str isnt "\n"
      #  We trim off the right-side new line so that the closing </p> tag
      #  will be positioned immediately following the string, matching
      #  the behavior of the opening <p> tag
      $str = '<p>' + rtrim($str) + '</p>'
      
    
    #  Remove empty paragraphs if they are on the first line, as this
    #  is a potential unintended consequence of the previous code
    $str = preg_replace("/<p><\\/p>(.*)/", "$1", $str, 1)
    
    return $str
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Protect Characters
  #
  # Protects special characters from being formatted later
  # We don't want quotes converted within tags so we'll temporarily convert them to {@DQ} and {@SQ}
  # and we don't want double dashes converted to emdash entities, so they are marked with {@DD}
  # likewise double spaces are converted to {@NBS} to prevent entity conversion
  #
    # @param  [Array]  # @return	[String]
  #
  _protect_characters : ($match) ->
    return str_replace(["'", '"', '--', '  '], ['{@SQ}', '{@DQ}', '{@DD}', '{@NBS}'], $match[0])
    
  
  #
  # Convert newlines to HTML line breaks except within PRE tags
  #
    # @param  [String]    # @return	[String]
  #
  nl2brExceptPre : ($str) ->
    $ex = explode("pre>", $str)
    $ct = $ex.length-1
    
    $newstr = ""
    for $s, $i of $ex
      if ($i2) is 0
        $newstr+=nl2br($s)

      else
        $newstr+=$s

      if $ct isnt $i then $newstr+="pre>"

    return $newstr
    
  


module.exports = system.lib.Typography
#  END Typography Class

#  End of file Typography.coffee
#  Location: .system/lib/Typography.coffee