#+--------------------------------------------------------------------+
#| welcome.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	Blog
#
require APPPATH+'core/AdminController.coffee'

class Blog extends AdminController

  ## --------------------------------------------------------------------

  #
  # Index
  #
  # list blog entries
  #
  #   @access	public
  #   @return	void
  #
  index: () ->

    @template.set_title config_item('site_name'), 'Blog', 'List'

    @db.from 'blog'
    @db.get ($err, $blog) =>

      #if $err then return @template.error $err

      @template.view 'blog_list', $err || entries: $blog.result()


  ## --------------------------------------------------------------------

  #
  # Show
  #
  # display blog entry
  #
  #   @access	public
  #   @return	void
  #
  show: ($id) ->

    @template.set_title config_item('site_name'), 'Blog', 'Show'

    @db.from 'blog'
    @db.where 'id', $id
    @db.get ($err, $blog) =>

      if $err then return @template.error $err

      @template.view 'blog_show', blog: $blog.row()


  ## --------------------------------------------------------------------

  #
  # Edit
  #
  # ckedit blog entry
  #
  #   @access	public
  #   @return	void
  #
  edit: ($id) ->

    @template.set_title config_item('site_name'), 'Blog', 'Edit'

    @db.from 'blog'
    @db.where 'id', $id
    @db.get ($err, $blog) =>

      if $err then return @template.error $err

      @template.view 'blog_edit', blog: $blog.row()


  ## --------------------------------------------------------------------

  #
  # New
  #
  # create new blog entry
  #
  #   @access	public
  #   @return	void
  #
  new: () ->

    @template.set_title config_item('site_name'), 'Blog', 'New'

    @template.view 'blog_new'

  ## --------------------------------------------------------------------

  #
  # Save
  #
  # saves a blog entry
  #
  #   @access	public
  #   @return	void
  #
  save: () ->




    #
# Export the class:
#
module.exports = Blog

# End of file Blog.coffee
# Location: .modules/blog/controllers/Blog.coffee
