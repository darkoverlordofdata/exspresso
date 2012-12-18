#+--------------------------------------------------------------------+
#  captcha_helper.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee
#
#
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter CAPTCHA Helper
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/xml_helper.html
#

#  ------------------------------------------------------------------------

#
# Create CAPTCHA
#
# @access	public
# @param	array	array of data for the CAPTCHA
# @param	string	path to create the image in
# @param	string	URL to the CAPTCHA image folder
# @param	string	server path to font
# @return	string
#
if not function_exists('create_captcha')
  exports.create_captcha = create_captcha = ($data = '', $img_path = '', $img_url = '', $font_path = '') ->
    $defaults =
      word:       ''
      img_path:   ''
      img_url:    ''
      img_width:  '150'
      img_height: '30'
      font_path:  ''
      expiration: 7200
    
    for $key, $val of $defaults
      if not is_array($data)
        if not $key?  or $key is ''
          $key = $val
      else
        $key = if not $data[$key]? then $val else $data[$key]

    if $img_path is '' or $img_url is ''
      return false

    if not is_dir($img_path)
      return false

    if not is_writable($img_path)
      return false

    if not extension_loaded('gd')
      return false
      
    
    #  -----------------------------------
    #  Remove old images
    #  -----------------------------------
    
    [$usec, $sec] = explode(" ", microtime())
    $now = ($usec + $sec)
    
    $current_dir = opendir($img_path)
    
    while ($filename = readdir($current_dir))
      if $filename isnt "." and $filename isnt ".." and $filename isnt "index.html"
        $name = str_replace(".jpg", "", $filename)
      
        if ($name + $expiration) < $now
          unlink($img_path + $filename)
        
    closedir($current_dir)
    
    #  -----------------------------------
    #  Do we have a "word" yet?
    #  -----------------------------------
    
    if $word is ''
      $pool = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
      
      $str = ''
      for $i in [0..7]
        $str+=substr($pool, mt_rand(0, strlen($pool) - 1), 1)

      $word = $str
      
    
    #  -----------------------------------
    #  Determine angle and position
    #  -----------------------------------
    
    $length = strlen($word)
    $angle = if ($length>=6) then rand( - ($length - 6), ($length - 6)) else 0
    $x_axis = rand(6, (360 / $length) - 16)
    $y_axis = if ($angle>=0) then rand($img_height, $img_width) else rand(6, $img_height)
    
    #  -----------------------------------
    #  Create image
    #  -----------------------------------
    
    #  PHP.net recommends imagecreatetruecolor(), but it isn't always available
    if function_exists('imagecreatetruecolor')
      $im = imagecreatetruecolor($img_width, $img_height)
      
    else 
      $im = imagecreate($img_width, $img_height)
      
    
    #  -----------------------------------
    #   Assign colors
    #  -----------------------------------
    
    $bg_color = imagecolorallocate($im, 255, 255, 255)
    $border_color = imagecolorallocate($im, 153, 102, 102)
    $text_color = imagecolorallocate($im, 204, 153, 153)
    $grid_color = imagecolorallocate($im, 255, 182, 182)
    $shadow_color = imagecolorallocate($im, 255, 240, 240)
    
    #  -----------------------------------
    #   Create the rectangle
    #  -----------------------------------
    
    ImageFilledRectangle($im, 0, 0, $img_width, $img_height, $bg_color)
    
    #  -----------------------------------
    #   Create the spiral pattern
    #  -----------------------------------
    
    $theta = 1
    $thetac = 7
    $radius = 16
    $circles = 20
    $points = 32
    
    for $i in [0 .. ($circles * $points) - 1]
      $theta = $theta + $thetac
      $rad = $radius * ($i / $points)
      $x = ($rad * cos($theta)) + $x_axis
      $y = ($rad * sin($theta)) + $y_axis
      $theta = $theta + $thetac
      $rad1 = $radius * (($i + 1) / $points)
      $x1 = ($rad1 * cos($theta)) + $x_axis
      $y1 = ($rad1 * sin($theta)) + $y_axis
      imageline($im, $x, $y, $x1, $y1, $grid_color)
      $theta = $theta - $thetac

    #  -----------------------------------
    #   Write the text
    #  -----------------------------------
    
    $use_font = if ($font_path isnt '' and file_exists($font_path) and function_exists('imagettftext')) then true else false
    
    if $use_font is false
      $font_size = 5
      $x = rand(0, $img_width / ($length / 3))
      $y = 0
      
    else 
      $font_size = 16
      $x = rand(0, $img_width / ($length / 1.5))
      $y = $font_size + 2
      
    
    for $i in [0 .. strlen($word)-1]
      if $use_font is false
        $y = rand(0, $img_height / 2)
        imagestring($im, $font_size, $x, $y, substr($word, $i, 1), $text_color)
        $x+=($font_size * 2)

      else
        $y = rand($img_height / 2, $img_height - 3)
        imagettftext($im, $font_size, $angle, $x, $y, $text_color, $font_path, substr($word, $i, 1))
        $x+=$font_size
      

    
    #  -----------------------------------
    #   Create the border
    #  -----------------------------------
    
    imagerectangle($im, 0, 0, $img_width - 1, $img_height - 1, $border_color)
    
    #  -----------------------------------
    #   Generate the image
    #  -----------------------------------
    
    $img_name = $now + '.jpg'
    
    ImageJPEG($im, $img_path + $img_name)
    
    $img = "<img src=\"$img_url$img_name\" width=\"$img_width\" height=\"$img_height\" style=\"border:0;\" alt=\" \" />"
    
    ImageDestroy($im)
    
    return 'word':$word, 'time':$now, 'image':$img
    
  

#  ------------------------------------------------------------------------

#  End of file captcha_helper.php 
#  Location: ./system/heleprs/captcha_helper.php 