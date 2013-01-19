#+--------------------------------------------------------------------+
#  Lang.coffee
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
# Modular Extensions - HMVC
#
# Adapted from the CodeIgniter Core Classes
# @link	http://codeigniter.com
#
# Description:
# This library extends the CodeIgniter CI_Language class
# and adds features allowing use of modules and the HMVC design pattern.
#
# Install this file as application/third_party/MX/Lang.php
#
# @copyright	Copyright (c) 2011 Wiredesignz
# @version 	5.4
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
require(dirname(__filename)+'/Modules.coffee')

class global.MX_Lang extends CI_Lang

  #  --------------------------------------------------------------------

  #
  # Load a module language file
  #
  # @access	public
  # @param	mixed	the name of the language file to be loaded. Can be an array
  # @param	string	the language (english, etc.)
  # @return	mixed
  #
  load: ($langfile, $lang = '',$return = false, $add_suffix = true, $alt_path = '') ->

    if is_array($langfile)
      for $_lang in $langfile
        @load($_lang)
      return @language

    $deft_lang = Exspresso.config.item('language')
    $idiom = if ($lang is '') then $deft_lang else $lang

    if in_array($langfile + '_lang' + EXT, @is_loaded, true)
      return @language

    $_module = Exspresso.router.fetch_module()
    [$path, $_langfile] = Modules.find($langfile + '_lang', $_module, 'language/' + $idiom + '/')
    if $path is false
      if $lang = super($langfile, $lang, $return, $add_suffix, $alt_path)
        return $lang
      else
        if $lang = Modules.load_file($_langfile, $path, 'lang')
          if $return then return $lang
        @language = array_merge(@language, $lang)
        @is_loaded.push $langfile + '_lang' + EXT

      return @language

module.exports = MX_Lang

# End of file Lang.coffee
# Location: ./application/libraries/MX/Lang.coffee