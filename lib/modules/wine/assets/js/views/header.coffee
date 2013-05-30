class window.HeaderView extends Backbone.View

  initialize: () ->
    @render()

  render: () ->
    $(@el).html @template()
    @

  selectMenuItem: (menuItem) ->
    $('.nav li').removeClass 'active'
    if menuItem
      $('.' + menuItem).addClass('active')

