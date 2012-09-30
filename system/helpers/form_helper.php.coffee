if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter Form Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/form_helper.html
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
	global.form_open = ($action = '', $attributes = '', $hidden = {}) ->
		$CI = get_instance()
		
		if $attributes is ''
			$attributes = 'method="post"'
			
		
		#  If an action is not a full URL then turn it into one
		if $action and strpos($action, '://') is FALSE
			$action = $CI.config.site_url($action)
			
		
		#  If no action is provided then set to the current url
		$action or $action = $CI.config.site_url($CI.uri.uri_string())
		
		$form = '<form action="' + $action + '"'
		
		$form+=_attributes_to_string($attributes, TRUE)
		
		$form+='>'
		
		#  CSRF
		if $CI.config.item('csrf_protection') is TRUE
			$hidden[$CI.security.get_csrf_token_name()] = $CI.security.get_csrf_hash()
			
		
		if is_array($hidden) and count($hidden) > 0
			$form+=sprintf("\n<div class=\"hidden\">%s</div>", form_hidden($hidden))
			
		
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
	global.form_open_multipart = ($action, $attributes = {}, $hidden = {}) ->
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
	global.form_hidden = ($name, $value = '', $recursing = FALSE) ->
		global.$form = global.$form ? {}
		
		if $recursing is FALSE
			$form = "\n"
			
		
		if is_array($name)
			for $val, $key in as
				form_hidden($key, $val, TRUE)
				
			return $form
			
		
		if not is_array($value)
			$form+='<input type="hidden" name="' + $name + '" value="' + form_prep($value, $name) + '" />' + "\n"
			
		else 
			for $v, $k in as
				$k = if (is_int($k)) then '' else $k
				form_hidden($name + '[' + $k + ']', $v, TRUE)
				
			
		
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
	global.form_input = ($data = '', $value = '', $extra = '') ->
		$defaults = 'type':'text', 'name':(( not is_array($data) then $data else ''), 'value':$value)
		
		return "<input " + _parse_form_attributes($data, $defaults) + $extra + " />"
		
	

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
	global.form_password = ($data = '', $value = '', $extra = '') ->
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
	global.form_upload = ($data = '', $value = '', $extra = '') ->
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
	global.form_textarea = ($data = '', $value = '', $extra = '') ->
		$defaults = 'name':(( not is_array($data) then $data else ''), 'cols':'90', 'rows':'12')
		
		if not is_array($data) or  not $data['value']? 
			$val = $value
			
		else 
			$val = $data['value']
			delete $data['value']#  textareas don't use the value attribute
			
		
		$name = if (is_array($data)) then $data['name'] else $data
		return "<textarea " + _parse_form_attributes($data, $defaults) + $extra + ">" + form_prep($val, $name) + "</textarea>"
		
	

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
	global.form_multiselect = ($name = '', $options = {}, $selected = {}, $extra = '') ->
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
	global.form_dropdown = ($name = '', $options = {}, $selected = {}, $extra = '') ->
		if not is_array($selected)
			$selected = [$selected]
			
		
		#  If no selected state was submitted we will attempt to set it automatically
		if count($selected) is 0
			#  If the form name appears in the $_POST array we have a winner!
			if $_POST[$name]? 
				$selected = [$_POST[$name]]
				
			
		
		if $extra isnt '' then $extra = ' ' + $extra$multiple = if (count($selected) > 1 and strpos($extra, 'multiple') is FALSE) then ' multiple="multiple"' else ''$form = '<select name="' + $name + '"' + $extra + $multiple + ">\n"for $val, $key in as
			$key = ''+$key
			
			if is_array($val) and  not empty($val)
				$form+='<optgroup label="' + $key + '">' + "\n"
				
				for $optgroup_val, $optgroup_key in as
					$sel = if (in_array($optgroup_key, $selected)) then ' selected="selected"' else ''
					
					$form+='<option value="' + $optgroup_key + '"' + $sel + '>' + ''+$optgroup_val + "</option>\n"
					
				
				$form+='</optgroup>' + "\n"
				
			else 
				$sel = if (in_array($key, $selected)) then ' selected="selected"' else ''
				
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
	global.form_checkbox = ($data = '', $value = '', $checked = FALSE, $extra = '') ->
		$defaults = 'type':'checkbox', 'name':(( not is_array($data) then $data else ''), 'value':$value)
		
		if is_array($data) and array_key_exists('checked', $data)
			$checked = $data['checked']
			
			if $checked is FALSE
				delete $data['checked']
				
			else 
				$data['checked'] = 'checked'
				
			
		
		if $checked is TRUE
			$defaults['checked'] = 'checked'
			
		else 
			delete $defaults['checked']
			
		
		return "<input " + _parse_form_attributes($data, $defaults) + $extra + " />"
		
	

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
	global.form_radio = ($data = '', $value = '', $checked = FALSE, $extra = '') ->
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
	global.form_submit = ($data = '', $value = '', $extra = '') ->
		$defaults = 'type':'submit', 'name':(( not is_array($data) then $data else ''), 'value':$value)
		
		return "<input " + _parse_form_attributes($data, $defaults) + $extra + " />"
		
	

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
	global.form_reset = ($data = '', $value = '', $extra = '') ->
		$defaults = 'type':'reset', 'name':(( not is_array($data) then $data else ''), 'value':$value)
		
		return "<input " + _parse_form_attributes($data, $defaults) + $extra + " />"
		
	

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
	global.form_button = ($data = '', $content = '', $extra = '') ->
		$defaults = 'name':(( not is_array($data) then $data else ''), 'type':'button')
		
		if is_array($data) and $data['content']? 
			$content = $data['content']
			delete $data['content']#  content is not an attribute
			
		
		return "<button " + _parse_form_attributes($data, $defaults) + $extra + ">" + $content + "</button>"
		
	

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
	global.form_label = ($label_text = '', $id = '', $attributes = {}) ->
		
		$label = '<label'
		
		if $id isnt ''
			$label+= for=\"$id\"
			
		
		if is_array($attributes) and count($attributes) > 0
			for $val, $key in as
				$label+=' ' + $key + '="' + $val + '"'
				
			
		
		$label+=>$label_text</label>
		
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
	global.form_fieldset = ($legend_text = '', $attributes = {}) ->
		$fieldset = "<fieldset"
		
		$fieldset+=_attributes_to_string($attributes, FALSE)
		
		$fieldset+=">\n"
		
		if $legend_text isnt ''
			$fieldset+=<legend>$legend_text</legend>\n
			
		
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
	global.form_fieldset_close = ($extra = '') ->
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
	global.form_close = ($extra = '') ->
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
	global.form_prep = ($str = '', $field_name = '') ->
		global.$prepped_fields = global.$prepped_fields ? {}
		
		#  if the field name is an array we do this recursively
		if is_array($str)
			for $val, $key in as
				$str[$key] = form_prep($val)
				
			
			return $str
			
		
		if $str is ''
			return ''
			
		
		#  we've already prepped a field with this name
		#  @todo need to figure out a way to namespace this so
		#  that we know the *exact* field and not just one with
		#  the same name
		if $prepped_fields[$field_name]? 
			return $str
			
		
		$str = htmlspecialchars($str)
		
		#  In case htmlspecialchars misses these.
		$str = str_replace(["'", '"'], ["&#39;", "&quot;"], $str)
		
		if $field_name isnt ''
			$prepped_fields[$field_name] = $field_name
			
		
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
	global.set_value = ($field = '', $default = '') ->
		if FALSE is ($OBJ = _get_validation_object())
			if not $_POST[$field]? 
				return $default
				
			
			return form_prep($_POST[$field], $field)
			
		
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
	global.set_select = ($field = '', $value = '', $default = FALSE) ->
		$OBJ = _get_validation_object()
		
		if $OBJ is FALSE
			if not $_POST[$field]? 
				if count($_POST) is 0 and $default is TRUE
					return ' selected="selected"'
					
				return ''
				
			
			$field = $_POST[$field]
			
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
	global.set_checkbox = ($field = '', $value = '', $default = FALSE) ->
		$OBJ = _get_validation_object()
		
		if $OBJ is FALSE
			if not $_POST[$field]? 
				if count($_POST) is 0 and $default is TRUE
					return ' checked="checked"'
					
				return ''
				
			
			$field = $_POST[$field]
			
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
	global.set_radio = ($field = '', $value = '', $default = FALSE) ->
		$OBJ = _get_validation_object()
		
		if $OBJ is FALSE
			if not $_POST[$field]? 
				if count($_POST) is 0 and $default is TRUE
					return ' checked="checked"'
					
				return ''
				
			
			$field = $_POST[$field]
			
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
	global.form_error = ($field = '', $prefix = '', $suffix = '') ->
		if FALSE is ($OBJ = _get_validation_object())
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
	global.validation_errors = ($prefix = '', $suffix = '') ->
		if FALSE is ($OBJ = _get_validation_object())
			return ''
			
		
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
	global._parse_form_attributes = ($attributes, $default) ->
		if is_array($attributes)
			for $val, $key in as
				if $attributes[$key]? 
					$default[$key] = $attributes[$key]
					delete $attributes[$key]
					
				
			
			if count($attributes) > 0
				$default = array_merge($default, $attributes)
				
			
		
		$att = ''
		
		for $val, $key in as
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
	global._attributes_to_string = ($attributes, $formtag = FALSE) ->
		if is_string($attributes) and strlen($attributes) > 0
			if $formtag is TRUE and strpos($attributes, 'method=') is FALSE
				$attributes+=' method="post"'
				
			
			if $formtag is TRUE and strpos($attributes, 'accept-charset=') is FALSE
				$attributes+=' accept-charset="' + strtolower(config_item('charset')) + '"'
				
			
			return ' ' + $attributes
			
		
		if is_object($attributes) and count($attributes) > 0
			$attributes = $attributes
			
		
		if is_array($attributes) and count($attributes) > 0
			$atts = ''
			
			if not $attributes['method']?  and $formtag is TRUE
				$atts+=' method="post"'
				
			
			if not $attributes['accept-charset']?  and $formtag is TRUE
				$atts+=' accept-charset="' + strtolower(config_item('charset')) + '"'
				
			
			for $val, $key in as
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
	global._get_validation_object =  ->
		$CI = get_instance()
		
		#  We set this as a variable since we're returning by reference
		$return = FALSE
		
		if not $CI.load._ci_classes?  or  not $CI.load._ci_classes['form_validation']? 
			return $return
			
		
		$object = $CI.load._ci_classes['form_validation']
		
		if not $CI.$object?  or  not is_object($CI.$object)
			return $return
			
		
		return $CI.$object
		
	


#  End of file form_helper.php 
#  Location: ./system/helpers/form_helper.php 