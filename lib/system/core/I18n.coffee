#+--------------------------------------------------------------------+
#  I18n.coffee
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
# @author		  darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright	Copyright (c) 2011 Wiredesignz
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see 		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#
# Localization package loader
#
#
class system.core.I18n


  Modules = require(SYSPATH+'core/Modules.coffee')

  #
  # @property [Object] cache of loaded i18n strings
  #
  _language: null
  #
  # @property [Array] list of loaded i18n files
  #
  _is_loaded: null

  #
  # Constructor
  #
  # @param  [system.core.Config]  config  The application configuratin
  #
  constructor : ($config) ->

    @_language = {}
    @_is_loaded = []
    defineProperties @,
      config:   {writeable: false, value: $config}

    log_message 'debug', "I18n Class Initialized"

  #
  # Load a module language file
  #
  # @param  [String]  langfile  the name of the language file to be loaded. Can be an array
  # @param  [String]  lang  the language ISO 639-1 code(de, en, etc.)
  # @param  [String]  module  the module parsed from the uri
  # @return [Object] a hash of key/values for the language
  #
  load: ($langfile, $lang = '', $module = '', $return = false) ->

    if is_array($langfile)
      for $_lang in $langfile
        @load($_lang)
      return @_language

    $deft_lang = @config.item('language')
    $code = if ($lang is '') then $deft_lang else $lang

    if in_array($langfile + '.json', @_is_loaded, true)
      return @_language

    [$path, $_langfile] = Modules::find($langfile+'.json', $module, 'i18n/' + $code + '/')
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
  # Load an application language file
  #
  # @param  [String]  langfile  the name of the language file to be loaded. Can be an array
  # @param  [String]  lang  the language ISO 639-1 code(de, en, etc.)
  # @return [Object] a hash of key/values for the language
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
    for $package_path in exspresso.load.getPackagePaths(true)
      if file_exists($package_path + 'i18n/' + $code + '/' + $langfile)
        $lang = require($package_path + 'i18n/' + $code + '/' + $langfile)
        $found = true
        break

    if $found isnt true
      show_error('Unable to load the requested language file: i18n/' + $code + '/' + $langfile)

    if not $lang?
      log_message('error', 'Language file contains no data: i18n/' + $code + '/' + $langfile)
      return

    if $return is true
      return $lang

    @_is_loaded.push $langfile
    @_language = array_merge(@_language, $lang)

    log_message('debug', 'Language file loaded: i18n/%s/%s', $code, $langfile)
    return true


  #
  # Fetch a single line of text from the language array
  #
  # @param  [String]  line  the language line
  # @return  [String]
  #
  line : ($line = '') ->
    $line = if ($line is '' or  not @_language[$line]? ) then false else @_language[$line]

    #  Because killer robots like unicorns!
    if $line is false
      log_message('error', 'Could not find the language line "' + $line + '"')


    return $line

#  END ExspressoLang Class
module.exports = system.core.I18n
#  End of file I18n.coffee
#  Location: ./system/core/I18n.coffee