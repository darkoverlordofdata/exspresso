#+--------------------------------------------------------------------+
#| welcome.coffee
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
#	Blog
#
require APPPATH+'core/AdminController.coffee'

class Blog extends application.core.AdminController

  #
  # Index
  #
  # list blog entries
  #
  # @return [Void]
  #
  index: () ->

    @db.select 'blog.id, users.name AS author, category.name AS category, blog.status, blog.created_on, blog.updated_on, blog.title'
    @db.from 'blog'
    @db.join 'users', 'users.uid = blog.author_id', 'inner'
    @db.join 'category', 'category.id = blog.category_id', 'inner'
    @db.get ($err, $blog) =>

      #
      # Display a list of articles
      #
      @template.view 'blog_list', $err ||
        entries: $blog.result()


  #
  # Show
  #
  # display blog entry
  #
  # @param  [String]  id  blog record id
  # @return [Void]
  #
  show: ($id) ->

    @db.from 'blog'
    @db.where 'id', $id
    @db.get ($err, $blog) =>

      #
      # Display a single article
      #
      @template.view 'blog_show', $err ||
        blog: $blog.row()


  #
  # Edit
  #
  # Edit the blog entry
  #
  # @param  [String]  id  blog record id
  # @return [Void]
  #
  edit: ($id) ->

    @db.from 'blog'
    @db.where 'id', $id
    @db.get ($err, $blog) =>

      #
      # Edit the article
      #
      @template.view 'blog_edit', $err ||
        blog: $blog.row()


  #
  # Delete
  #
  # Delete the blog entry
  #
  # @param  [String]  id  blog record id
  # @return [Void]
  #
  del: ($id) ->

    @db.where 'id', $id
    @db.delete 'blog', ($err) =>

      #
      # Show the status of the delete operation
      #
      if $err?
        @session.setFlashdata('error', $err.message)
      else
        @session.setFlashdata('info', 'Blog entry %s deleted', $id)

      @redirect '/blog'


  #
  # New
  #
  # Edit a new blog entry
  #
  # @return [Void]
  #
  new: () ->

    #
    # Present an empty article
    #
    @template.view 'blog_new'

  #
  # Create
  #
  # Create the new blog entry
  #
  # @return [Void]
  #
  create: () ->

    $now = String(new Date())
    $data =
      author_id: @user.uid
      category_id: 1
      status: 1
      created_on: $now
      updated_on: $now
      title: @input.post('title')
      body: @input.post('blog')

    @db.insert 'blog', $data, ($err) =>

      #
      # Add the article to the database
      #
      if $err? # can't insert, try again?
        @session.setFlashdata('error', $err.message)
        return @redirect '/blog/new'

      @db.insertId ($err, $id) =>

        #
        # get the ID
        #
        if $err? # can't get the id, display the whole list
          @session.setFlashdata('error', $err.message)
          return @redirect '/blog'

        #
        # Show the id that was created
        #
        @session.setFlashdata('info', 'Blog entry %s created', $id)
        @redirect '/blog/edit/'+$id


  #
  # Save
  #
  # saves a blog entry
  #
  # @return [Void]
  #
  save: () ->

    $id = @input.post('id')
    $body = @input.post('blog')

    @db.where 'id', $id
    @db.update 'blog', {body: $body}, ($err) =>

      #
      # Show the status of the update operation
      #
      if $err?
        @session.setFlashdata('error', $err.message)
      else
        @session.setFlashdata('info', 'Blog entry %s saved', $id)

      @redirect '/blog/edit/'+$id



#
# Export the class:
#
module.exports = Blog

# End of file Blog.coffee
# Location: .modules/blog/controllers/Blog.coffee
