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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		  darkoverlordofdata
# @copyright	Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		MIT License
# @link		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#  ------------------------------------------------------------------------

#
# Language Class
#
#
class global.Base_Lang
  
  language: {}
  is_loaded: []
  
  #
  # Constructor
  #
  # @access  public
  #
  constructor :  ->
    log_message 'debug', "Language Class Initialized"
    
  
  #  --------------------------------------------------------------------
  
  #
  # Load a language file
  #
  # @access  public
  # @param  mixed  the name of the language file to be loaded. Can be an array
  # @param  string  the language (english, etc.)
  # @return  mixed
  #
  load: ($langfile = '', $idiom = '', $return = false, $add_suffix = true, $alt_path = '') ->
    $langfile = str_replace(EXT, '', $langfile)
    
    if $add_suffix is true
      $langfile = str_replace('_lang.', '', $langfile) + '_lang'

    $langfile+=EXT
    
    if in_array($langfile, @is_loaded, true)
      return 

    $config = get_config()
    
    if $idiom is ''
      $deft_lang = if not $config['language']? then 'english' else $config['language']
      $idiom = if $deft_lang is '' then 'english' else $deft_lang

    #  Determine where the language file is and load it
    if $alt_path isnt '' and file_exists($alt_path + 'language/' + $idiom + '/' + $langfile)
      $lang = require($alt_path + 'language/' + $idiom + '/' + $langfile)
    else 
      $found = false
      $CI = Exspresso
      for $package_path in $CI.load.get_package_paths(true)
        if file_exists($package_path + 'language/' + $idiom + '/' + $langfile)
          $lang = require($package_path + 'language/' + $idiom + '/' + $langfile)
          $found = true
          break

      if $found isnt true
        show_error('Unable to load the requested language file: language/' + $idiom + '/' + $langfile)

    if not $lang?
      log_message('error', 'Language file contains no data: language/' + $idiom + '/' + $langfile)
      return 

    if $return is true
      return $lang

    @is_loaded.push $langfile
    @language = array_merge(@language, $lang)

    log_message('debug', 'Language file loaded: language/%s/%s', $idiom, $langfile)
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch a single line of text from the language array
  #
  # @access  public
  # @param  string  $line  the language line
  # @return  string
  #
  line : ($line = '') ->
    $line = if ($line is '' or  not @language[$line]? ) then false else @language[$line]
    
    #  Because killer robots like unicorns!
    if $line is false
      log_message('error', 'Could not find the language line "' + $line + '"')
      
    
    return $line
    
#  END Language Class
module.exports = Base_Lang
#  End of file Lang.php 
#  Location: ./system/core/Lang.php 