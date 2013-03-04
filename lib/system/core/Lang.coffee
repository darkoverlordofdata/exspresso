#+--------------------------------------------------------------------+
#  Lang.coffee
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
# @package		Exspresso
# @author		  darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright	Copyright (c) 2011 Wiredesignz
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

Modules = require(BASEPATH+'core/Modules.coffee')

class system.core.Lang

  _language         : null  # cache of loaded l10n strings
  _is_loaded        : null  # list of loaded l10n files

  #
  # Constructor
  #
  # @access  public
  # @param object   ExspressoConfig
  #
  constructor : (@CFG) ->
    @_language = {}
    @_is_loaded = []
    log_message 'debug', "Language Class Initialized"

  #
  # Load a module language file
  #
  # @access	public
  # @param	mixed	the name of the language file to be loaded. Can be an array
  # @param	string	the language (english, etc.)
  # @return	mixed
  #
  load: ($langfile, $lang = '', $module = '', $return = false) ->

    if is_array($langfile)
      for $_lang in $langfile
        @load($_lang)
      return @_language

    $deft_lang = @CFG.item('language')
    $idiom = if ($lang is '') then $deft_lang else $lang

    if in_array($langfile + '_lang' + EXT, @_is_loaded, true)
      return @_language

    [$path, $_langfile] = Modules.find($langfile + '_lang', $module, 'language/' + $idiom + '/')
    if $path is false
      if $lang = @_application_load($langfile, $lang, $return)
        return $lang
    else
      if $lang = Modules.loadFile($_langfile, $path, 'lang')
        if $return then return $lang
    @_language = array_merge(@_language, $lang)
    @_is_loaded.push $langfile + '_lang' + EXT

    return @_language

  #
  # Load a language file
  #
  # @access  public
  # @param  mixed  the name of the language file to be loaded. Can be an array
  # @param  string  the language (english, etc.)
  # @return  mixed
  #
  _application_load: ($langfile = '', $idiom = '', $return = false) ->
    $langfile = str_replace(EXT, '', $langfile)

    $langfile = str_replace('_lang.', '', $langfile) + '_lang'

    $langfile+=EXT

    if in_array($langfile, @_is_loaded, true)
      return

    $config = get_config()

    if $idiom is ''
      $deft_lang = if not $config['language']? then 'english' else $config['language']
      $idiom = if $deft_lang is '' then 'english' else $deft_lang

    #  Determine where the language file is and load it
    $found = false
    for $package_path in Exspresso.load.getPackagePaths(true)
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

    @_is_loaded.push $langfile
    @_language = array_merge(@_language, $lang)

    log_message('debug', 'Language file loaded: language/%s/%s', $idiom, $langfile)
    return true


  #
  # Fetch a single line of text from the language array
  #
  # @access  public
  # @param  string  $line  the language line
  # @return  string
  #
  line : ($line = '') ->
    $line = if ($line is '' or  not @_language[$line]? ) then false else @_language[$line]

    #  Because killer robots like unicorns!
    if $line is false
      log_message('error', 'Could not find the language line "' + $line + '"')


    return $line

#  END ExspressoLang Class
module.exports = system.core.Lang
#  End of file Lang.php 
#  Location: ./system/core/Lang.coffee