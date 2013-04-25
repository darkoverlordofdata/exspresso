#+--------------------------------------------------------------------+
#  gravatar_helper.coffee
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
# Sekati Exspresso Gravatar Helper
#
# @package		Sekati
# @author		Jason M Horwitz
# @copyright	Copyright (c) 2012, Sekati LLC.
# @license		http://www.opensource.org/licenses/mit-license.php
# @see 		http://sekati.com
# @version		v1.1.1
# @filesource
#
# @usage 		$autoload['helper'] = array('gravatar');
# @example 	gravatar( 'jason@sekati.com' );	 			// returns gravatar img tag
# 				gravatar_profile( 'jason@sekati.com' ); 	// returns URL
# 				gravatar_qr( 'jason@sekati.com' ); 			// returns QR img tag
#

#
# Get either a Gravatar URL or complete image tag for a specified email address.
#
# @param  [String]  	$email The email address
# @param  [String]  	$s Size in pixels, defaults to 80px [ 1 - 512 ]
# @param boolean 	$img True to return a complete IMG tag False for just the URL
# @param  [String]  	$d Default imageset to use [ 404 | mm | identicon | monsterid | wavatar ]
# @param  [String]  	$r Maximum rating (inclusive) [ g | pg | r | x ]
# @param  [Array]  $atts Optional, additional key/value attributes to include in the IMG tag
# @return 			String containing either just a URL or a complete image tag
#
exports.gravatar = gravatar = ($email, $s = 80, $img = true, $d = 'identicon', $r = 'x', $atts = {}) ->
  $url = if @req.connection.encrypted then 'https://secure.' else 'http://www.'
  $url+='gravatar.com/avatar/'
  $url+=md5((trim($email.toLowerCase())))
  $url+="?s=#{$s}&d=#{$d}&r=#{$r}"
  if $img
    $url = '<img src="' + $url + '"'
    for $key, $val of $atts
      $url+=' ' + $key + '="' + $val + '"'
    $url+=' />'

  return $url

  

#
# Get a Gravatar profile URL from a primary gravatar email address.
#
# @param  [String]  	$email The email address
# @return 			String containing the users gravatar profile URL.
#
exports.gravatar_profile = gravatar_profile = ($email) ->
  $url = if req.connection.encrypted then 'https://secure.' else 'http://www.'
  $url+='gravatar.com/'
  $url+=md5(trim($email.toLowerCase()))
  return $url

  

#
# Get either a Gravatar QR Code URL or complete image tag from a primary gravatar email address.
#
# @param  [String]  	$email The email address
# @param  [String]  	$s Size in pixels, defaults to 80px [ 1 - 512 ]
# @param boolean 	$img True to return a complete IMG tag False for just the URL
# @param  [Array]  $atts Optional, additional key/value attributes to include in the IMG tag
# @return 			String containing either just a URL or a complete image tag
#
exports.gravatar_qr = gravatar_qr = ($email, $s = 80, $img = true, $atts = {}) ->
  $url = gravatar_profile($email)
  $url+=".qr?s=#{$s}"
  if $img
    $url = '<img src="' + $url + '"'
    for $key, $val of $atts
      $url+=' ' + $key + '="' + $val + '"'
    $url+=' />'

  return $url

