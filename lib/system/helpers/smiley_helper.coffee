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
# Exspresso Smiley Helpers
#
#

#
# Smiley Javascript
#
# Returns the javascript required for the smiley insertion.  Optionally takes
# an array of aliases to loosely couple the smiley array to the view.
#
# @param  [Mixed]  alias name or array of alias->field_id pairs
# @param  [String]  field_id if alias name was passed in
# @return	array
#
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

    $r+="""
        var smiley_map = {$m};

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
      """


    else
      if is_array($alias)
        for $name, $id of $alias
          $r+='smiley_map["' + $name + '"] = "' + $id + '";' + "\n"




    if $inline
      return '<script type="text/javascript" charset="utf-8">/*<![CDATA[ */' + $r + '// ]]></script>'

    else
      return $r


#
# Get Clickable Smileys
#
# Returns an array of image tag links that can be clicked to be inserted
# into a form field.
#
# @param  [String]  the URL to the folder containing the smiley images
# @return	array
#
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
# @param  [String]  the text to be parsed
# @param  [String]  the URL to the folder containing the smiley images
# @return	[String]
#
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
# @private
# @return [Mixed]  #
exports._get_smiley_array = _get_smiley_array =  ->
  if file_exists(APPPATH + 'config/' + ENVIRONMENT + '/smileys' + EXT)
    require(APPPATH + 'config/' + ENVIRONMENT + '/smileys' + EXT)

  else if file_exists(APPPATH + 'config/smileys' + EXT)
    require(APPPATH + 'config/smileys' + EXT)


  if $smileys?  and is_array($smileys)
    return $smileys


  return false



