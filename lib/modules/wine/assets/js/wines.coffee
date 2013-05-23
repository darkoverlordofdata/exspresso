
rootURL = Exspresso_base_url+"/api/wines"
currentWine = null

# Nothing to delete in initial application state
$('#btnDelete').hide()

# Register listeners
$('#btnSearch').click ->
  search $('#searchKey').val()
  return false

# Trigger search when pressing 'Return' on search key input field
$('#searchKey').keypress (e) ->
  if e.which is 13
    search($('#searchKey').val())
    e.preventDefault()
    return false


$('#btnAdd').click ->
  newWine()
  return false


$('#btnSave').click ->
  if $('#wineId').val() is ''
    addWine()
  else
    updateWine()
  return false


$('#btnDelete').click ->
  deleteWine()
  return false


$('#wineList a').live 'click', ->
  findById($(this).data('identity'))


# Replace broken images with generic wine bottle
$("img").error ->
  $(this).attr("src", "pics/generic.jpg")


search = (searchKey) ->
  if searchKey is ''
    findAll()
  else
    findByName(searchKey)


newWine = () ->
  $('#btnDelete').hide()
  currentWine = {}
  renderDetails(currentWine) # Display empty form

findAll = () ->
  console.log 'findAll'
  $.ajax
    type      : 'GET'
    url       : rootURL
    dataType  : "json" # data type of response
    success   : renderList

findByName = (searchKey) ->
  console.log 'findByName: ' + searchKey
  $.ajax
    type      : 'GET'
    url       : rootURL + '/search/' + searchKey
    dataType  : "json"
    success   : renderList


findById = (id) ->
  console.log('findById: ' + id);
  $.ajax
    type      : 'GET'
    url       : rootURL + '/' + id
    dataType  : "json"
    success   : (data) ->
      $('#btnDelete').show()
      console.log 'findById success: ' + data.name
      currentWine = data
      renderDetails(currentWine)


addWine = () ->
  console.log 'addWine'
  $.ajax
    type        : 'POST'
    contentType : 'application/json'
    url         : rootURL
    dataType    : "json"
    data        : formToJSON()
    success     : (data, textStatus, jqXHR) ->
      alert 'Wine created successfully'
      $('#btnDelete').show()
      $('#wineId').val(data.id)
    error       : (jqXHR, textStatus, errorThrown) ->
      alert 'addWine error: ' + textStatus


updateWine = () ->
  console.log 'updateWine'
  $.ajax
    type        : 'PUT'
    contentType : 'application/json'
    url         : rootURL + '/' + $('#wineId').val()
    dataType    : "json"
    data        : formToJSON()
    success     : (data, textStatus, jqXHR) ->
      alert 'Wine updated successfully'
    error       : (jqXHR, textStatus, errorThrown) ->
      alert 'updateWine error: ' + textStatus


deleteWine = () ->
  console.log 'deleteWine'
  $.ajax
    type    : 'DELETE'
    url     : rootURL + '/' + $('#wineId').val()
    success : (data, textStatus, jqXHR) ->
      alert 'Wine deleted successfully'
    error   : (jqXHR, textStatus, errorThrown) ->
      alert 'deleteWine error'


renderList = (data) ->

  # JAX-RS serializes an empty list as null, and a 'collection of one' as an object (not an 'array of one')
  list = if data is null then [] else if data instanceof Array then data else [data]

  $('#wineList li').remove()
  $.each list, (index, wine) ->
    $('#wineList').append '<li><a href="#" data-identity="' + wine.id + '">'+wine.name+'</a></li>'


renderDetails = (wine) ->
  $('#wineId').val wine.id
  $('#name').val wine.name
  $('#grapes').val wine.grapes
  $('#country').val wine.country
  $('#region').val wine.region
  $('#year').val wine.year
  $('#pic').attr 'src', 'pics/' + wine.picture
  $('#description').val wine.description


# Helper function to serialize all the form fields into a JSON string
formToJSON = () ->
  JSON.stringify
    "id"          : $('#wineId').val()
    "name"        : $('#name').val()
    "grapes"      : $('#grapes').val()
    "country"     : $('#country').val()
    "region"      : $('#region').val()
    "year"        : $('#year').val()
    "picture"     : currentWine.picture
    "description" : $('#description').val()

# Retrieve wine list when application starts
findAll()

