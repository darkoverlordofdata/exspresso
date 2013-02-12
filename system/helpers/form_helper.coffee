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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Form Helpers
#
# @package		Exspresso
# @subpackage	Helpers
# @category	Helpers
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/helpers/form_helper.html
#

#  ------------------------------------------------------------------------

#
# Form Declaration
#
# Creates the opening portion of the form.
#
# @access	public
# @param	string	the URI segments of the form destination
# @param	array	a key/value pair of attributes
# @param	array	a key/value pair hidden data
# @return	string
#
if not function_exists('form_open')
  exports.form_open = form_open = ($action = '', $attributes = '', $hidden = {}) ->
    
    if $attributes is ''
      $attributes = 'method="post"'


    #  If an action is not a full URL then turn it into one
    #if $action and strpos($action, '://') is false
    #  $action = @config.site_url($action)


    #  If no action is provided then set to the current url
    $action or ($action = @config.site_url(@uri.uri_string()))

    $form = '<form action="' + $action + '"'

    $form+=_attributes_to_string($attributes, true)
    
    $form+='>'

    #  CSRF
    if @config.item('csrf_protection') is true
      $hidden[@security.get_csrf_token_name()] = @security.get_csrf_hash()

    if is_array($hidden) and count($hidden) > 0
      {format} = require('util')
      $form+=format("\n<div class=\"hidden\">%s</div>", form_hidden($hidden))

    return $form
    
  

#  ------------------------------------------------------------------------

#
# Form Declaration - Multipart type
#
# Creates the opening portion of the form, but with "multipart/form-data".
#
# @access	public
# @param	string	the URI segments of the form destination
# @param	array	a key/value pair of attributes
# @param	array	a key/value pair hidden data
# @return	string
#
if not function_exists('form_open_multipart')
  exports.form_open_multipart = form_open_multipart = ($action, $attributes = {}, $hidden = {}) ->
    if is_string($attributes)
      $attributes+=' enctype="multipart/form-data"'
      
    else 
      $attributes['enctype'] = 'multipart/form-data'
      
    
    return form_open($action, $attributes, $hidden)
    
  

#  ------------------------------------------------------------------------

#
# Hidden Input Field
#
# Generates hidden fields.  You can pass a simple key/value string or an associative
# array with multiple values.
#
# @access	public
# @param	mixed
# @param	string
# @return	string
#
if not function_exists('form_hidden')
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
    
  

#  ------------------------------------------------------------------------

#
# Text Input Field
#
# @access	public
# @param	mixed
# @param	string
# @param	string
# @return	string
#
if not function_exists('form_input')
  exports.form_input = form_input = ($data = '', $value = '', $extra = '') ->
    $defaults =
      type:   'text'
      name:   if not is_array($data) then $data else ''
      value:  $value
    
    return "<input " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + " />"



#  ------------------------------------------------------------------------

#
# Password Field
#
# Identical to the input function but adds the "password" type
#
# @access	public
# @param	mixed
# @param	string
# @param	string
# @return	string
#
if not function_exists('form_password')
  exports.form_password = form_password = ($data = '', $value = '', $extra = '') ->
    if not is_array($data)
      $data = 'name':$data
      
    
    $data['type'] = 'password'
    return form_input($data, $value, $extra)
    
  

#  ------------------------------------------------------------------------

#
# Upload Field
#
# Identical to the input function but adds the "file" type
#
# @access	public
# @param	mixed
# @param	string
# @param	string
# @return	string
#
if not function_exists('form_upload')
  exports.form_upload = form_upload = ($data = '', $value = '', $extra = '') ->
    if not is_array($data)
      $data = 'name':$data
      
    
    $data['type'] = 'file'
    return form_input($data, $value, $extra)
    
  

#  ------------------------------------------------------------------------

#
# Textarea field
#
# @access	public
# @param	mixed
# @param	string
# @param	string
# @return	string
#
if not function_exists('form_textarea')
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
    
  

#  ------------------------------------------------------------------------

#
# Multi-select menu
#
# @access	public
# @param	string
# @param	array
# @param	mixed
# @param	string
# @return	type
#
if not function_exists('form_multiselect')
  exports.form_multiselect = form_multiselect = ($name = '', $options = {}, $selected = {}, $extra = '') ->
    if not strpos($extra, 'multiple')
      $extra+=' multiple="multiple"'
      
    
    return form_dropdown($name, $options, $selected, $extra)
    
  

#  --------------------------------------------------------------------

#
# Drop-down Menu
#
# @access	public
# @param	string
# @param	array
# @param	string
# @param	string
# @return	string
#
if not function_exists('form_dropdown')
  exports.form_dropdown = form_dropdown = ($name = '', $options = {}, $selected = {}, $extra = '') ->
    if not Array.isArray($selected)
      $selected = [$selected]
      
    
    #  If no selected state was submitted we will attempt to set it automatically
    if count($selected) is 0
      #  If the form name appears in the @$_POST array we have a winner!
      if @$_POST[$name]?
        $selected = @$_POST[$name]

      
    
    #if $extra isnt '' then $extra = ' ' + $extra
    $multiple = if (count($selected) > 1 and strpos($extra, 'multiple') is false) then ' multiple="multiple"' else ''
    $form = '<select name="' + $name + '"' + _parse_extra($extra) + $multiple + ">\n"
    for $key, $val of $options
      $key = ''+$key

      if is_array($val) and count($val) > 0
        $form+='<optgroup label="' + $key + '">' + "\n"

        for $optgroup_key, $optgroup_val of $val
          $sel = if (in_array($optgroup_key, $selected)) then ' selected="selected"' else ''

          $form+='<option value="' + $optgroup_key + '"' + $sel + '>' + ''+$optgroup_val + "</option>\n"


        $form+='</optgroup>' + "\n"

      else
        $sel = if ($selected.indexOf($key) isnt -1) then ' selected="selected"' else ''

        $form+='<option value="' + $key + '"' + $sel + '>' + ''+$val + "</option>\n"

    $form+='</select>'
    
    return $form
    
  

#  ------------------------------------------------------------------------

#
# Checkbox Field
#
# @access	public
# @param	mixed
# @param	string
# @param	bool
# @param	string
# @return	string
#
if not function_exists('form_checkbox')
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

  

#  ------------------------------------------------------------------------

#
# Radio Button
#
# @access	public
# @param	mixed
# @param	string
# @param	bool
# @param	string
# @return	string
#
if not function_exists('form_radio')
  exports.form_radio = form_radio = ($data = '', $value = '', $checked = false, $extra = '') ->
    if not is_array($data)
      $data = 'name':$data
      
    
    $data['type'] = 'radio'
    return form_checkbox($data, $value, $checked, $extra)
    
  

#  ------------------------------------------------------------------------

#
# Submit Button
#
# @access	public
# @param	mixed
# @param	string
# @param	string
# @return	string
#
if not function_exists('form_submit')
  exports.form_submit = form_submit = ($data = '', $value = '', $extra = '') ->
    $defaults =
      type:   'submit'
      name:   if not is_array($data) then $data else ''
      value:  $value
    
    return "<input " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + " />"
    
  

#  ------------------------------------------------------------------------

#
# Reset Button
#
# @access	public
# @param	mixed
# @param	string
# @param	string
# @return	string
#
if not function_exists('form_reset')
  exports.form_reset = form_reset = ($data = '', $value = '', $extra = '') ->
    $defaults =
      type:   'reset'
      name:   if not is_array($data) then $data else ''
      value:  $value
    
    return "<input " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + " />"
    
  

#  ------------------------------------------------------------------------

#
# Form Button
#
# @access	public
# @param	mixed
# @param	string
# @param	string
# @return	string
#
if not function_exists('form_button')
  exports.form_button = form_button = ($data = '', $content = '', $extra = '') ->
    $defaults =
      name:   if not is_array($data) then $data else ''
      type:   'button'
    
    if is_array($data) and $data['content']? 
      $content = $data['content']
      delete $data['content']#  content is not an attribute
      
    
    return "<button " + _parse_form_attributes($data, $defaults) + _parse_extra($extra) + ">" + $content + "</button>"
    
  

#  ------------------------------------------------------------------------

#
# Form Label Tag
#
# @access	public
# @param	string	The text to appear onscreen
# @param	string	The id the label applies to
# @param	string	Additional attributes
# @return	string
#
if not function_exists('form_label')
  exports.form_label = form_label = ($label_text = '', $id = '', $attributes = {}) ->
    
    $label = '<label'
    
    if $id isnt ''
      $label+=" for=\"#{$id}\""
      
    
    if is_array($attributes) and count($attributes) > 0
      for $key, $val of $attributes
        $label+=' ' + $key + '="' + $val + '"'
        
      
    
    $label+=">#{$label_text}</label>"
    
    return $label
    
  

#  ------------------------------------------------------------------------
#
# Fieldset Tag
#
# Used to produce <fieldset><legend>text</legend>.  To close fieldset
# use form_fieldset_close()
#
# @access	public
# @param	string	The legend text
# @param	string	Additional attributes
# @return	string
#
if not function_exists('form_fieldset')
  exports.form_fieldset = form_fieldset = ($legend_text = '', $attributes = {}) ->
    $fieldset = "<fieldset"
    
    $fieldset+=_attributes_to_string($attributes, false)
    
    $fieldset+=">\n"
    
    if $legend_text isnt ''
      $fieldset+="<legend>$legend_text</legend>\n"
      
    
    return $fieldset
    
  

#  ------------------------------------------------------------------------

#
# Fieldset Close Tag
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('form_fieldset_close')
  exports.form_fieldset_close = form_fieldset_close = ($extra = '') ->
    return "</fieldset>" + $extra
    
  

#  ------------------------------------------------------------------------

#
# Form Close Tag
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('form_close')
  exports.form_close = form_close = ($extra = '') ->
    return "</form>" + $extra
    
  

#  ------------------------------------------------------------------------

#
# Form Prep
#
# Formats text so that it can be safely placed in a form field in the event it has HTML tags.
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('form_prep')
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
    
  

#  ------------------------------------------------------------------------

#
# Form Value
#
# Grabs a value from the POST array for the specified field so you can
# re-populate an input field or textarea.  If Form Validation
# is active it retrieves the info from the validation class
#
# @access	public
# @param	string
# @return	mixed
#
if not function_exists('set_value')
  exports.set_value = set_value = ($field = '', $default = '') ->
    if false is ($OBJ = @_get_validation_object())
      
      if not @$_POST[$field]
        return $default

      return form_prep(@$_POST[$field], $field)

    return form_prep($OBJ.set_value($field, $default), $field)
    
  

#  ------------------------------------------------------------------------

#
# Set Select
#
# Let's you set the selected value of a <select> menu via data in the POST array.
# If Form Validation is active it retrieves the info from the validation class
#
# @access	public
# @param	string
# @param	string
# @param	bool
# @return	string
#
if not function_exists('set_select')
  exports.set_select = set_select = ($field = '', $value = '', $default = false) ->
    $OBJ = @_get_validation_object()

    
    if $OBJ is false
      if not @$_POST[$field]
        if count(@$_POST) is 0 and $default is true
          return ' selected="selected"'
          
        return ''

      $field = @$_POST[$field]
      
      if is_array($field)
        if not in_array($value, $field)
          return ''

      else 
        if ($field is '' or $value is '') or ($field isnt $value)
          return ''

      return ' selected="selected"'

    return $OBJ.set_select($field, $value, $default)
    
  

#  ------------------------------------------------------------------------

#
# Set Checkbox
#
# Let's you set the selected value of a checkbox via the value in the POST array.
# If Form Validation is active it retrieves the info from the validation class
#
# @access	public
# @param	string
# @param	string
# @param	bool
# @return	string
#
if not function_exists('set_checkbox')
  exports.set_checkbox = set_checkbox = ($field = '', $value = '', $default = false) ->
    $OBJ = @_get_validation_object()

    if $OBJ is false
      if not @$_POST[$field]
        if count(@$_POST) is 0 and $default is true
          return ' checked="checked"'
          
        return ''

      $field = @$_POST[$field]
      
      if is_array($field)
        if not in_array($value, $field)
          return ''

      else 
        if ($field is '' or $value is '') or ($field isnt $value)
          return ''

      return ' checked="checked"'

    return $OBJ.set_checkbox($field, $value, $default)
    
  

#  ------------------------------------------------------------------------

#
# Set Radio
#
# Let's you set the selected value of a radio field via info in the POST array.
# If Form Validation is active it retrieves the info from the validation class
#
# @access	public
# @param	string
# @param	string
# @param	bool
# @return	string
#
if not function_exists('set_radio')
  exports.set_radio = set_radio = ($field = '', $value = '', $default = false) ->
    $OBJ = @_get_validation_object()

    if $OBJ is false
      if not @$_POST[$field]
        if count(@$_POST) is 0 and $default is true
          return ' checked="checked"'
          
        return ''

      $field = @$_POST[$field]
      
      if is_array($field)
        if not in_array($value, $field)
          return ''

      else 
        if ($field is '' or $value is '') or ($field isnt $value)
          return ''

      return ' checked="checked"'

    return $OBJ.set_radio($field, $value, $default)
    
  

#  ------------------------------------------------------------------------

#
# Form Error
#
# Returns the error for a specific form field.  This is a helper for the
# form validation class.
#
# @access	public
# @param	string
# @param	string
# @param	string
# @return	string
#
if not function_exists('form_error')
  exports.form_error = form_error = ($field = '', $prefix = '', $suffix = '') ->
    if false is ($OBJ = @_get_validation_object())
      return ''
    return $OBJ.error($field, $prefix, $suffix)
    
  

#  ------------------------------------------------------------------------

#
# Validation Error String
#
# Returns all the errors associated with a form submission.  This is a helper
# function for the form validation class.
#
# @access	public
# @param	string
# @param	string
# @return	string
#
if not function_exists('validation_errors')
  exports.validation_errors = validation_errors = ($prefix = '', $suffix = '') ->

    if false is ($OBJ = @_get_validation_object())
      return ''

    log_message 'debug', 'validation_errors %s', $OBJ.error_string($prefix, $suffix)
    return $OBJ.error_string($prefix, $suffix)
    
  

#  ------------------------------------------------------------------------

#
# Parse the form attributes
#
# Helper function used by some of the form helpers
#
# @access	private
# @param	array
# @param	array
# @return	string
#
if not function_exists('_parse_form_attributes')
  exports._parse_form_attributes = _parse_form_attributes = ($attributes, $default) ->
    if is_array($attributes)
      for $key, $val of $default
        if $attributes[$key]? 
          $default[$key] = $attributes[$key]
          delete $attributes[$key]

      if count($attributes) > 0
        $default = array_merge($default, $attributes)

    $att = ''
    
    for $key, $val of $default
      if $key is 'value'
        $val = form_prep($val, $default['name'])

      $att+=$key + '="' + $val + '" '

    return $att
    
  

#  ------------------------------------------------------------------------

#
# Attributes To String
#
# Helper function used by some of the form helpers
#
# @access	private
# @param	mixed
# @param	bool
# @return	string
#
if not function_exists('_attributes_to_string')
  exports._attributes_to_string = _attributes_to_string = ($attributes, $formtag = false) ->
    if is_string($attributes) and strlen($attributes) > 0
      if $formtag is true and strpos($attributes, 'method=') is false
        $attributes+=' method="post"'
        
      
      if $formtag is true and strpos($attributes, 'accept-charset=') is false
        $attributes+=' accept-charset="' + strtolower(config_item('charset')) + '"'
        
      
      return ' ' + $attributes
      
    
    #if is_object($attributes) and count($attributes) > 0
    #  $attributes = $attributes
      
    
    if is_array($attributes) and count($attributes) > 0
      $atts = ''
      
      if not $attributes['method']?  and $formtag is true
        $atts+=' method="post"'
        
      
      if not $attributes['accept-charset']?  and $formtag is true
        $atts+=' accept-charset="' + strtolower(config_item('charset')) + '"'
        
      
      for $key, $val of $attributes
        $atts+=' ' + $key + '="' + $val + '"'
        
      
      return $atts
      
    
  

#  ------------------------------------------------------------------------

#
# Validation Object
#
# Determines what the form validation class was instantiated as, fetches
# the object and returns it.
#
# @access	private
# @return	mixed
#
if not function_exists('_get_validation_object')
  exports._get_validation_object = _get_validation_object =  ->
    
    #  We set this as a variable since we're returning by reference
    $return = false

    if not @load._ex_classes?  or  not @load._ex_classes['form_validation']?
      return $return

    $object = @load._ex_classes['form_validation']
    
    if not @[$object]?  or  not is_object(@[$object])
      return $return

    return @[$object]


#  ------------------------------------------------------------------------

#
# parse extra
#
# @access	private
# @return	string
#
_parse_extra = ($extra = '') ->

  if typeof $extra is 'string' then return ' '+$extra
  if is_array($extra) then return ' '+_parse_form_attributes($extra, {})
  return ''


#  End of file form_helper.php 
#  Location: ./system/helpers/form_helper.php 