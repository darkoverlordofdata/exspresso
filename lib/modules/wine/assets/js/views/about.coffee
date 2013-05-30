class window.AboutView extends Backbone.View

  initialize:() ->
    @render()

  render:() ->
    $(@el).html @template()
    @
