#+--------------------------------------------------------------------+
#  smiley_helper.coffee
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
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Smiley Helpers
#
#

#  ------------------------------------------------------------------------

#
# Smiley Javascript
#
# Returns the javascript required for the smiley insertion.  Optionally takes
# an array of aliases to loosely couple the smiley array to the view.
#
# @access	public
# @param	mixed	alias name or array of alias->field_id pairs
# @param	string	field_id if alias name was passed in
# @return	array
#
if not function_exists('smiley_js')
  exports.smiley_js = smiley_js = ($alias = '', $field_id = '', $inline = true) ->
    exports.$do_setup = $do_setup ? {}true
    
    $r = ''
    
    if $alias isnt '' and  not is_array($alias)
      $alias = $alias:$field_id
      
    
    if $do_setup is true
      $do_setup = false
      
      $m = {}
      
      if is_array($alias)
        for $name, $id of $alias
          $m.push '"' + $name + '" : "' + $id + '"'
          
        
      
      $m = '{' + implode(',', $m) + '}'
      
      $r+=<<<var smiley_map = #{$m;

function insert_smiley(smiley, field_id) {
var el = document.getElementById(field_id), newStart;

if ( ! el && smiley_map[field_id]) {
el = document.getElementById(smiley_map[field_id]);

if ( ! el)
return false;
}

el.focus();
smiley = " " + smiley;

if ('selectionStart' in el) {
newStart = el.selectionStart + smiley.length;

el.value = el.value.substr(0, el.selectionStart) +
smiley +
el.value.substr(el.selectionEnd, el.value.length);
el.setSelectionRange(newStart, newStart);
}
else if (document.selection) {
document.selection.createRange().text = smiley;
}
}

    
  else 
    if is_array($alias)
      for $name, $id of $alias
        $r+='smiley_map["' + $name + '"] = "' + $id + '";' + "\n"
        
      
    
  
  if $inline
    return '<script type="text/javascript" charset="utf-8">/*<![CDATA[ */' + $r + '// ]]></script>'
    
  else 
    return $r
    
  
}

#  ------------------------------------------------------------------------

#
# Get Clickable Smileys
#
# Returns an array of image tag links that can be clicked to be inserted
# into a form field.
#
# @access	public
# @param	string	the URL to the folder containing the smiley images
# @return	array
#
if not function_exists('get_clickable_smileys')
  exports.get_clickable_smileys = get_clickable_smileys = ($image_url, $alias = '', $smileys = null) ->
    #  For backward compatibility with js_insert_smiley
    
    if is_array($alias)
      $smileys = $alias
      
    
    if not is_array($smileys)
      if false is ($smileys = _get_smiley_array())
        return $smileys
        
      
    
    #  Add a trailing slash to the file path if needed
    $image_url = rtrim($image_url, '/') + '/'
    
    $used = {}
    for $key, $val of $smileys
      #  Keep duplicates from being used, which can happen if the
      #  mapping array contains multiple identical replacements.  For example:
      #  :-) and :) might be replaced with the same image so both smileys
      #  will be in the array.
      if $used[$smileys[$key][0]]? 
        continue
        
      
      $link.push "<a href=\"javascript:void(0);\" onclick=\"insert_smiley('" + $key + "', '" + $alias + "')\"><img src=\"" + $image_url + $smileys[$key][0] + "\" width=\"" + $smileys[$key][1] + "\" height=\"" + $smileys[$key][2] + "\" alt=\"" + $smileys[$key][3] + "\" style=\"border:0;\" /></a>"
      
      $used[$smileys[$key][0]] = true
      
    
    return $link
    
  

#  ------------------------------------------------------------------------

#
# Parse Smileys
#
# Takes a string as input and swaps any contained smileys for the actual image
#
# @access	public
# @param	string	the text to be parsed
# @param	string	the URL to the folder containing the smiley images
# @return	string
#
if not function_exists('parse_smileys')
  exports.parse_smileys = parse_smileys = ($str = '', $image_url = '', $smileys = null) ->
    if $image_url is ''
      return $str
      
    
    if not is_array($smileys)
      if false is ($smileys = _get_smiley_array())
        return $str
        
      
    
    #  Add a trailing slash to the file path if needed
    $image_url = preg_replace("/(.+?)\/*$/", "\\1/", $image_url)
    
    for $key, $val of $smileys
      $str = str_replace($key, "<img src=\"" + $image_url + $smileys[$key][0] + "\" width=\"" + $smileys[$key][1] + "\" height=\"" + $smileys[$key][2] + "\" alt=\"" + $smileys[$key][3] + "\" style=\"border:0;\" />", $str)
      
    
    return $str
    
  

#  ------------------------------------------------------------------------

#
# Get Smiley Array
#
# Fetches the config/smiley.php file
#
# @access	private
# @return	mixed
#
if not function_exists('_get_smiley_array')
  exports._get_smiley_array = _get_smiley_array =  ->
    if defined('ENVIRONMENT') and file_exists(APPPATH + 'config/' + ENVIRONMENT + '/smileys' + EXT)
      require(APPPATH + 'config/' + ENVIRONMENT + '/smileys' + EXT)
      
    else if file_exists(APPPATH + 'config/smileys' + EXT)
      require(APPPATH + 'config/smileys' + EXT)
      
    
    if $smileys?  and is_array($smileys)
      return $smileys
      
    
    return false
    
  

#  ------------------------------------------------------------------------

#
# JS Insert Smiley
#
# Generates the javascript function needed to insert smileys into a form field
#
# DEPRECATED as of version 1.7.2, use smiley_js instead
#
# @access	public
# @param	string	form name
# @param	string	field name
# @return	string
#
if not function_exists('js_insert_smiley')
  exports.js_insert_smiley = js_insert_smiley = ($form_name = '', $form_field = '') ->
    return <<<<script type="text/javascript">
function insert_smiley(smiley)
{
document.#{$form_name}.#{$form_field}.value += " " + smiley;
}
</script>

}


#  End of file smiley_helper.php 
#  Location: ./system/helpers/smiley_helper.php 