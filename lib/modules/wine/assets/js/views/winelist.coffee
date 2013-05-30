class window.WineListView extends Backbone.View

  initialize: () ->
    @render()

  render: () ->
    wines = @model.models
    len = wines.length
    startPos = (@options.page - 1) * 6
    endPos = Math.min(startPos + 6, len)

    $(@el).html '<ul class="thumbnails"></ul>'

    for i in [startPos...endPos]
      $('.thumbnails', @el).append new WineListItemView(model: wines[i]).render().el

    $(@el).append(new Paginator({model: @model, page: @options.page}).render().el)

    @

class window.WineListItemView extends Backbone.View

  tagName: "li",

  initialize: () ->
    @model.bind "change", @render, @
    @model.bind "destroy", @close, @

    
  render: () ->
    $(@el).html @template(@model.toJSON())
    @
