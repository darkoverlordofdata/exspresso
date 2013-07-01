#+--------------------------------------------------------------------+
#  form_helper.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# Exspresso Form Helpers
#

#
# Form Declaration
#
# Creates the opening portion of the form.
#
# @param  [String]  the URI segments of the form destination
# @param  [Array]  a key/value pair of attributes
# @param  [Array]  a key/value pair hidden data
# @return	[String]
#
exports.form_open = form_open = ($action = '', $attributes = '', $hidden = {}) ->

  if $attributes is ''
    $attributes = 'method="post"'

  #  If an action is not a full URL then turn it into one
  #if $action and strpos($action, '://') is false
  #  $action = @config.siteUrl($action)


  #  If no action is provided then set to the current url
  $action or ($action = @config.siteUrl(@uri.uriString()))

  $form = '<form action="' + $action + '"'

  $form+=_attributes_to_string($attributes, true)

  $form+='>'

  #  CSRF
  if @config.item('csrf_protection') is true
    $hidden[@security.getCsrfTokenName()] = @security.getCsrfHash()

  if is_array($hidden) and Object.keys($hidden).length > 0
    {format} = require('util')
    $form+=format("\n<div class=\"hidden\">%s</div>", form_hidden($hidden))

  return $form

#
# Form Declaration - Multipart type
#
# Creates the opening portion of the form, but with "multipart/form-data".
#
# @param  [String]  the URI segments of the form destination
# @param  [Array]  a key/value pair of attributes
# @param  [Array]  a key/value pair hidden data
# @return	[String]
#
exports.form_open_multipart = form_open_multipart = ($action, $attributes = {}, $hidden = {}) ->
  if 'string' is typeof($attributes)
    $attributes+=' enctype="multipart/form-data"'

  else
    $attributes['enctype'] = 'multipart/form-data'


  return form_open($action, $attributes, $hidden)
    
#
# Hidden Input Field
#
# Generates hidden fields.  You can pass a simple key/value string or an associative
# array with multiple values.
#
# @param  [Mixed]
# @param  [String]
# @return	[String]
#
exports.form_hidden = form_hidden = ($name, $value = '', $form = "\n") ->

  if is_array($name)
    for $key, $val of $name
      $form += form_hidden($key, $val, $form)

    return $form


  if not is_array($value)
    $form+='<input type="hidden" name="' + $name + '" value="' + form_prep($value, $name) + '" />' + "\n"

  else
    for $k, $v of $value
      $form += form_hidden($name + '[' + $k + ']', $v, $form)

  return $form

#
# Text Input Field
#
# @param  [Mixed]
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.form_input = form_input = ($data = '', $value = '', $extra = '') ->
  $defaults =
    type:   'text'
    name:   if not is_array($data) then $data else ''
    value:  $value

  return "<input " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + " />"

#
# Password Field
#
# Identical to the input function but adds the "password" type
#
# @param  [Mixed]
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.form_password = form_password = ($data = '', $value = '', $extra = '') ->
  if not is_array($data)
    $data = name:$data


  $data['type'] = 'password'
  return form_input($data, $value, $extra)

#
# Upload Field
#
# Identical to the input function but adds the "file" type
#
# @param  [Mixed]
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.form_upload = form_upload = ($data = '', $value = '', $extra = '') ->
  if not is_array($data)
    $data = name:$data


  $data['type'] = 'file'
  return form_input($data, $value, $extra)

#
# Textarea field
#
# @param  [Mixed]
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.form_textarea = form_textarea = ($data = '', $value = '', $extra = '') ->
  $defaults =
    name:if not is_array($data) then $data else ''
    cols:'90'
    rows:'12'

  if not is_array($data) or  not $data['value']?
    $val = $value

  else
    $val = $data['value']
    delete $data['value']#  textareas don't use the value attribute


  $name = if (is_array($data)) then $data['name'] else $data
  return "<textarea " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + ">" + form_prep($val, $name) + "</textarea>"

#
# Multi-select menu
#
# @param  [String]
# @param  [Array]
# @param  [Mixed]
# @param  [String]
# @return	type
#
exports.form_multiselect = form_multiselect = ($name = '', $options = {}, $selected = {}, $extra = '') ->
  if $extra.indexOf('multiple') is -1
    $extra+=' multiple="multiple"'


  return form_dropdown($name, $options, $selected, $extra)

#
# Drop-down Menu
#
# @param  [String]
# @param  [Array]
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.form_dropdown = form_dropdown = ($name = '', $options = {}, $selected = [], $extra = '') ->
  if not Array.isArray($selected)
    $selected = [$selected]


  #  If no selected state was submitted we will attempt to set it automatically
  if $selected.length is 0
    #  If the form name appears in the @req.body array we have a winner!
    if @req.body[$name]?
      $selected = @req.body[$name]



  #if $extra isnt '' then $extra = ' ' + $extra
  #$multiple = if (count($selected) > 1 and $extra.indexOf('multiple') is -1) then ' multiple="multiple"' else ''
  $multiple = if ($selected.length > 1 and $extra.indexOf('multiple') is -1) then ' multiple="multiple"' else ''
  $form = '<select name="' + $name + '"' + _parse_extra($extra) + $multiple + ">\n"

  for $key, $val of $options
    $key = ''+$key

    if is_array($val) and Object.keys($val).length > 0
      $form+='<optgroup label="' + $key + '">' + "\n"

      for $optgroup_key, $optgroup_val of $val
        $sel = if ($selected.indexOf($optgroup_key) isnt -1) then ' selected="selected"' else ''

        $form+='<option value="' + $optgroup_key + '"' + $sel + '>' + ''+$optgroup_val + "</option>\n"


      $form+='</optgroup>' + "\n"

    else
      $sel = if ($selected.indexOf($key) isnt -1) then ' selected="selected"' else ''

      $form+='<option value="' + $key + '"' + $sel + '>' + ''+$val + "</option>\n"

  $form+='</select>'

  return $form

#
# Checkbox Field
#
# @param  [Mixed]
# @param  [String]
# @return	[Boolean]
# @param  [String]
# @return	[String]
#
exports.form_checkbox = form_checkbox = ($data = '', $value = '', $checked = false, $extra = '') ->
  $defaults =
    type:   'checkbox'
    name:   if not is_array($data) then $data else ''
    value:  $value

  if is_array($data) and $data['checked']?
    $checked = $data['checked']

    if $checked is false
      delete $data['checked']

    else
      $data['checked'] = 'checked'

  if $checked is true
    $defaults['checked'] = 'checked'

  else
    delete $defaults['checked']

  return "<input " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + " />"

#
# Radio Button
#
# @param  [Mixed]
# @param  [String]
# @return	[Boolean]
# @param  [String]
# @return	[String]
#
exports.form_radio = form_radio = ($data = '', $value = '', $checked = false, $extra = '') ->
  if not is_array($data)
    $data = name:$data


  $data['type'] = 'radio'
  return form_checkbox($data, $value, $checked, $extra)

#
# Submit Button
#
# @param  [Mixed]
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.form_submit = form_submit = ($data = '', $value = '', $extra = '') ->
  $defaults =
    type:   'submit'
    name:   if not is_array($data) then $data else ''
    value:  $value

  return "<input " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + " />"

#
# Reset Button
#
# @param  [Mixed]
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.form_reset = form_reset = ($data = '', $value = '', $extra = '') ->
  $defaults =
    type:   'reset'
    name:   if not is_array($data) then $data else ''
    value:  $value

  return "<input " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + " />"
    
#
# Form Button
#
# @param  [Mixed]
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.form_button = form_button = ($data = '', $content = '', $extra = '') ->
  $defaults =
    name:   if not is_array($data) then $data else ''
    type:   'button'

  if is_array($data) and $data['content']?
    $content = $data['content']
    delete $data['content']#  content is not an attribute


  return "<button " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + ">" + $content + "</button>"
    
#
# Form Label Tag
#
# @param  [String]  The text to appear onscreen
# @param  [String]  The id the label applies to
# @param  [String]  Additional attributes
# @return	[String]
#
exports.form_label = form_label = ($label_text = '', $id = '', $attributes = {}) ->

  $label = '<label'

  if $id isnt ''
    $label+=" for=\"#{$id}\""


  if is_array($attributes) and Object.keys($attributes).length > 0
    for $key, $val of $attributes
      $label+=' ' + $key + '="' + $val + '"'



  $label+=">#{$label_text}</label>"

  return $label
    
#
# Fieldset Tag
#
# Used to produce <fieldset><legend>text</legend>.  To close fieldset
# use form_fieldset_close()
#
# @param  [String]  The legend text
# @param  [String]  Additional attributes
# @return	[String]
#
exports.form_fieldset = form_fieldset = ($legend_text = '', $attributes = {}) ->
  $fieldset = "<fieldset"

  $fieldset+=_attributes_to_string($attributes, false)

  $fieldset+=">\n"

  if $legend_text isnt ''
    $fieldset+="<legend>$legend_text</legend>\n"


  return $fieldset

#
# Fieldset Close Tag
#
# @param  [String]
# @return	[String]
#
exports.form_fieldset_close = form_fieldset_close = ($extra = '') ->
  return "</fieldset>" + $extra

#
# Form Close Tag
#
# @param  [String]
# @return	[String]
#
exports.form_close = form_close = ($extra = '') ->
  return "</form>" + $extra
    
#
# Form Prep
#
# Formats text so that it can be safely placed in a form field in the event it has HTML tags.
#
# @param  [String]
# @return	[String]
#
exports.form_prep = form_prep = ($str = '', $field_name = '') ->

  #  if the field name is an array we do this recursively
  if is_array($str)
    for $key, $val of $str
      $str[$key] = form_prep($val)
    return $str

  if $str is ''
    return ''

  $str = htmlspecialchars(''+$str)

  return $str

#
# Form Value
#
# Grabs a value from the POST array for the specified field so you can
# re-populate an input field or textarea.  If Form Validation
# is active it retrieves the info from the validation class
#
# @param  [String]
# @return [Mixed]
#
exports.set_value = set_value = ($field = '', $default = '') ->

  if false is ($validation = @_get_validation_object())
    if not @req.body[$field]?
      return $default

    return form_prep(@req.body[$field], $field)

  return form_prep(@[$validation].setValue($field, $default), $field)

#
# Set Select
#
# Let's you set the selected value of a <select> menu via data in the POST array.
# If Form Validation is active it retrieves the info from the validation class
#
# @param  [String]
# @param  [String]
# @return	[Boolean]
# @return	[String]
#
exports.set_select = set_select = ($field = '', $value = '', $default = false) ->

  if false is ($validation = @_get_validation_object())
    if not @req.body[$field]?
      if Object.keys(@req.body).length is 0 and $default is true
        return ' selected="selected"'
      return ''

    $field = @req.body[$field]

    if Array.isArray($field)
      if $field.indexOf($value) is -1
        return ''

    else
      if ($field is '' or $value is '') or ($field isnt $value)
        return ''

    return ' selected="selected"'

  return $validation.setSelect($field, $value, $default)

#
# Set Checkbox
#
# Let's you set the selected value of a checkbox via the value in the POST array.
# If Form Validation is active it retrieves the info from the validation class
#
# @param  [String]
# @param  [String]
# @return	[Boolean]
# @return	[String]
#
exports.set_checkbox = set_checkbox = ($field = '', $value = '', $default = false) ->

  if false is ($validation = @_get_validation_object())
    if not @req.body[$field]?
      if Object.keys(@req.body).length is 0 and $default is true
        return ' checked="checked"'
      return ''

    $field = @req.body[$field]

    if Array.isArray($field)
      if $field.indexOf($value) is -1
        return ''

    else
      if ($field is '' or $value is '') or ($field isnt $value)
        return ''

    return ' checked="checked"'

  return $validation.setCheckbox($field, $value, $default)

#
# Set Radio
#
# Let's you set the selected value of a radio field via info in the POST array.
# If Form Validation is active it retrieves the info from the validation class
#
# @param  [String]
# @param  [String]
# @return	[Boolean]
# @return	[String]
#
exports.set_radio = set_radio = ($field = '', $value = '', $default = false) ->

  if false is ($validation = @_get_validation_object())
    if not @req.body[$field]?
      if Object.keys(@req.body).length is 0 and $default is true
        return ' checked="checked"'
      return ''

    $field = @req.body[$field]

    if Array.isArray($field)
      if $field.indexOf($value) is -1
        return ''

    else
      if ($field is '' or $value is '') or ($field isnt $value)
        return ''

    return ' checked="checked"'

  return $validation.setRadio($field, $value, $default)

#
# Form Error
#
# Returns the error for a specific form field.  This is a helper for the
# form validation class.
#
# @param  [String]
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.form_error = form_error = ($field = '', $prefix = '', $suffix = '') ->

  if false is ($validation = @_get_validation_object()) then ''
  else @[$validation].error($field, $prefix, $suffix)

#
# Validation Error String
#
# Returns all the errors associated with a form submission.  This is a helper
# function for the form validation class.
#
# @param  [String]
# @param  [String]
# @return	[String]
#
exports.validation_errors = validation_errors = ($prefix = '', $suffix = '') ->

  if false is ($validation = @_get_validation_object()) then ''
  else @[$validation].errorString($prefix, $suffix)

#
# Parse the form attributes
#
# Helper function used by some of the form helpers
#
# @private
# @param  [Array]
# @param  [Array]
# @return	[String]
#
exports._parse_form_attributes = _parse_form_attributes = ($attributes, $default) ->
  if is_array($attributes)
    for $key, $val of $default
      if $attributes[$key]?
        $default[$key] = $attributes[$key]
        delete $attributes[$key]

    if Object.keys($attributes).length > 0
      $default[$key] = $val for $key, $val of $attributes

  $att = ''

  for $key, $val of $default
    if $key is 'value'
      $val = form_prep($val, $default['name'])

    $att+=$key + '="' + $val + '" '

  return $att

#
# Attributes To String
#
# Helper function used by some of the form helpers
#
# @private
# @param  [Mixed]
# @return	[Boolean]
# @return	[String]
#
exports._attributes_to_string = _attributes_to_string = ($attributes, $formtag = false) ->
  if 'string' is typeof($attributes) and $attributes.length > 0
    if $formtag is true and $attributes.indexOf('method=') is -1
      $attributes+=' method="post"'


    if $formtag is true and $attributes.indexOf('accept-charset=') is -1
      $attributes+=' accept-charset="' + config_item('charset').toLowerCase() + '"'


    return ' ' + $attributes


  #if is_object($attributes) and count($attributes) > 0
  #  $attributes = $attributes


  if is_array($attributes) and Object.keys($attributes).length > 0
    $atts = ''

    if not $attributes['method']?  and $formtag is true
      $atts+=' method="post"'


    if not $attributes['accept-charset']?  and $formtag is true
      $atts+=' accept-charset="' + config_item('charset') + '"'


    for $key, $val of $attributes
      $atts+=' ' + $key + '="' + $val + '"'


    return $atts
      
#
# Validation Object
#
# Determines what the form validation class was instantiated as, fetches
# the object and returns it.
#
# @private
# @return [Mixed]
#
exports._get_validation_object = _get_validation_object =  ->
  $object = @load.getObject('validation')
  if $object?
    if @[$object]? then return $object
  false

#
# parse extra
#
# @private
# @return	[String]
#
_parse_extra = ($extra = '') ->

  if typeof $extra is 'string' then return ' '+$extra
  if is_array($extra) then return ' '+_parse_form_attributes($extra, {})
  return ''

