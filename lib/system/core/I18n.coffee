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
# I18n loader
#
#
module.exports = class system.core.I18n

  fs = require('fs')

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
  constructor : ($config, $module = '') ->

    @_language = {}
    @_is_loaded = []
    defineProperties @,
      config        : {enumerable: true,  writeable: false, value: $config}
      module        : {enumerable: true,  writeable: false, value: $module}

    log_message 'debug', "I18n Class Initialized"

  #
  # Load a module language file
  #
  # @param  [String]  langfile  the name of the language file to be loaded. Can be an array
  # @param  [String]  code  the language ISO 639-1 code(de, en, etc.)
  # @param  [String]  module  the module parsed from the uri
  # @return [Object] a hash of key/values for the language
  #
  load: ($langfile, $module = @module, $code = '', $return = false) ->

    $langfile = $langfile.replace(EXT, '')+'.json'

    return unless @_is_loaded.indexOf($langfile) is -1

    if $code is ''
      $deft_lang = if not @config.item('language')? then 'en' else @config.item('language')
      $code = if $deft_lang is '' then 'en' else $deft_lang

    #  Determine where the language file is and load it
    $found = false
    for $package_path in @config.getPaths($module, @controller.load.getModulePaths(true))

      if fs.existsSync($package_path + 'i18n/' + $code + '/' + $langfile)
        $lang = require($package_path + 'i18n/' + $code + '/' + $langfile)
        $found = true
        break

    if not $found
      log_message 'error', 'Unable to load the requested i18n file: i18n/' + $code + '/' + $langfile
      return

    if not $lang?
      log_message 'error', 'I18n file contains no data: i18n/' + $code + '/' + $langfile
      return

    if $return is true
      return $lang

    @_is_loaded.push $langfile
    @_language[$key] = $val for $key, $val of $lang

    log_message 'debug', 'I18n file loaded: i18n/%s/%s', $code, $langfile
    return true


  #
  # Fetch a single line of text from the language array
  #
  # @param  [String]  line  the language line
  # @return  [String]
  #
  line : ($line = '') ->
    $line = if ($line is '' or  not @_language[$line]? ) then false else @_language[$line]

    if $line is false
      log_message('error', 'Could not find the i18n line "' + $line + '"')

    $line

