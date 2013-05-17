#+--------------------------------------------------------------------+
#| Blog.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+

#
#	Blog Module
#
require APPPATH+'core/Module.coffee'

module.exports = class Blog extends application.core.Module

  name          : 'Blog'
  description   : ''
  path          : __dirname
  active        : true

  #
  # Initialize the module
  #
  #   Install if needed
  #   Load the categories
  #
  # @return [Void]
  #
  initialize: () ->
    @controller.load.model 'Blogs'
    @controller.blogs.install() if @controller.install
    @controller.blogs.preload_cache()


