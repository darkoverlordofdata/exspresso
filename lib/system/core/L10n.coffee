#+--------------------------------------------------------------------+
#  L10n.coffee
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
# Localization package loader
#
#

Modules = require(BASEPATH+'core/Modules.coffee')

class system.core.L10n

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
    log_message 'debug', "L10n Class Initialized"

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
    $code = if ($lang is '') then $deft_lang else $lang

    if in_array($langfile + '.json', @_is_loaded, true)
      return @_language

    [$path, $_langfile] = Modules::find($langfile+'.json', $module, 'l10n/' + $code + '/')
    if $path is false
      if $lang = @_application_load($langfile, $lang, $return)
        return $lang
    else
      if $lang = Modules::load($_langfile, $path, '.json')
        if $return then return $lang
    @_language = array_merge(@_language, $lang)
    @_is_loaded.push $langfile + '.json'

    return @_language

  #
  # Load a language file
  #
  # @access  public
  # @param  mixed  the name of the language file to be loaded. Can be an array
  # @param  string  ISO 639-1 code
  # @return  mixed
  #
  _application_load: ($langfile = '', $code = '', $return = false) ->

    $langfile = $langfile.replace(EXT, '')+'.json'

    if in_array($langfile, @_is_loaded, true)
      return

    $config = get_config()

    if $code is ''
      $deft_lang = if not $config['language']? then 'en' else $config['language']
      $code = if $deft_lang is '' then 'en' else $deft_lang

    #  Determine where the language file is and load it
    $found = false
    for $package_path in Exspresso.load.getPackagePaths(true)
      if file_exists($package_path + 'l10n/' + $code + '/' + $langfile)
        $lang = require($package_path + 'l10n/' + $code + '/' + $langfile)
        $found = true
        break

    if $found isnt true
      show_error('Unable to load the requested language file: l10n/' + $code + '/' + $langfile)

    if not $lang?
      log_message('error', 'Language file contains no data: l10n/' + $code + '/' + $langfile)
      return

    if $return is true
      return $lang

    @_is_loaded.push $langfile
    @_language = array_merge(@_language, $lang)

    log_message('debug', 'Language file loaded: l10n/%s/%s', $code, $langfile)
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
module.exports = system.core.L10n
#  End of file L10n.coffee
#  Location: ./system/core/L10n.coffee