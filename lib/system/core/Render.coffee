#+--------------------------------------------------------------------+
#  Render.coffee
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
# Exspresso Render Class
#
# Renders the view based on the view file extension
#
#
module.exports = class system.core.Render

  eco             = require('eco')                # Embedded CoffeeScript templates
  marked          = require('marked')             # A markdown parser

  constructor: ->

    log_message 'debug', 'Render Initialized'
  #
  # Enbedded coffee-script
  #
  # @param  [String]  tmp the template
  # @param  [Object]  data  hash of variable to merge into template
  # @return [String] the rendered markup
  #
  eco: ($tmp, $data) ->
    eco.render($tmp, $data)

  #
  # HTML
  #
  # @param  [String]  tmp the template
  # @param  [Object]  data  hash of variable to merge into template
  # @return [String] the rendered markup
  #
  html: ($tmp, $data) ->
    $tmp

  #
  # tpl
  #
  # Expresso template
  #
  # @param  [String]  tmp the template
  # @param  [Object]  data  hash of variable to merge into template
  # @return [String] the rendered markup
  #
  tpl: ($tmp, $data) ->
    $tmp

  #
  # Markdown
  #
  # @param  [String]  tmp the template
  # @param  [Object]  data  hash of variable to merge into template
  # @return [String] the rendered markup
  #
  markdown: ($tmp, $data) ->
    marked($tmp)

  #
  # Markdown
  #
  # @param  [String]  tmp the template
  # @param  [Object]  data  hash of variable to merge into template
  # @return [String] the rendered markup
  #
  md: ($tmp, $data) ->
    marked($tmp)

