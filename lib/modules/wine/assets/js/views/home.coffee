class window.HomeView extends Backbone.View

  initialize: () ->
    @render()
  

  render: () ->
    $(@el).html @template()
    @
