class AppRouter extends Backbone.Router

  routes: 
    ""                  : "home"
    "wines"	            : "list"
    "wines/page/:page"	: "list"
    "wines/add"         : "addWine"
    "wines/:id"         : "wineDetails"
    "about"             : "about"

  initialize: () ->
    @headerView = new HeaderView()
    $('.header').html @headerView.el

  home: (id) ->
    if not @homeView
      @homeView = new HomeView()

    $('#content').html @homeView.el
    @headerView.selectMenuItem 'home-menu'

  list: (page) ->
    p = if page then parseInt(page, 10) else 1
    wineList = new WineCollection()
    wineList.fetch success: ->
      $("#content").html new WineListView(model: wineList, page: p).el

    @headerView.selectMenuItem 'home-menu'


  wineDetails: (id) ->
    wine = new Wine(id: id)
    wine.fetch success: ->
      $("#content").html new WineView(model: wine).el

    @headerView.selectMenuItem()


  addWine: () ->
    wine = new Wine()
    $('#content').html new WineView(model: wine).el
    @headerView.selectMenuItem 'add-menu'


  about: () ->
    if not @aboutView
      @aboutView = new AboutView()

    $('#content').html @aboutView.el
    @headerView.selectMenuItem 'about-menu'



utils.loadTemplate ['HomeView', 'HeaderView', 'WineView', 'WineListItemView', 'AboutView'], ->
  app = new AppRouter()
  Backbone.history.start()
