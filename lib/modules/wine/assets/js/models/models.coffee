class window.Wine extends Backbone.Model

  # the api base defined in config/routes.coffee
  urlRoot: "/api/wines"

  idAttribute: "id"

  initialize: () ->
    @validators = {}

    @validators.name = (value) ->
      if value.length > 0 then isValid: true else isValid: false, message: "You must enter a name"
    

    @validators.grapes = (value) ->
      if value.length > 0 then isValid: true else isValid: false, message: "You must enter a grape variety"

      
    @validators.country = (value) ->
      if value.length > 0 then isValid: true else isValid: false, message: "You must enter a country"
    
  

  validateItem: (key) ->
    if (@validators[key]) then @validators[key](@get(key)) else isValid: true
  

  # TODO: Implement Backbone's standard validate() method instead.
  validateAll: () ->

    messages = {}

    for own key, validator in @validators
      check = @validators[key](@get(key))
      if check.isValid is false
        messages[key] = check.message

    if _.size(messages) > 0 then isValid: false, messages: messages else isValid: true

  
  defaults:
    id: null
    name: ""
    grapes: ""
    country: "USA"
    region: "California"
    year: ""
    description: ""
    picture: null


class window.WineCollection extends Backbone.Collection

  model: Wine

  # the api base defined in config/routes.coffee
  url: "/api/wines"

