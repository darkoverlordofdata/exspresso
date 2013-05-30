class window.Paginator extends Backbone.View

  className: "pagination pagination-centered"

  initialize: () ->
    @model.bind "reset", @render, @
    @render()

    
  render: () ->

    items = @model.models
    len = items.length
    pageCount = Math.ceil(len / 6)

    $(@el).html '<ul />'

    for i in [0...pageCount]
      $('ul', @el).append("<li" + (if (i + 1) is @options.page then " class='active'" else "") + "><a href='#wines/page/"+(i+1)+"'>" + (i+1) + "</a></li>")


    @
