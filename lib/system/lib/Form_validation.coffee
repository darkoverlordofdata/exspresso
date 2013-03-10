#+--------------------------------------------------------------------+
#  Form_validation.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Form Validation Class
#
# @package		Exspresso
#
class system.lib.FormValidation

  sprintf = require('util').format


  _field_data       : null
  _config_rules     : null
  _error_array      : null
  _error_messages   : null
  _error_prefix     : '<p>'
  _error_suffix     : '</p>'
  _safe_form_data   : false
  
  
  #
  # Constructor
  #
  constructor: ($controller, $rules = {}) ->

    #  Validation rules can be stored in a config file.
    @_config_rules = $rules
    @_field_datam = {}
    @_error_array = {}
    @_error_messages = {}

    #  Automatically load the form helper
    @load.helper('form')

    #  Set the character encoding in MB.
    if function_exists('mb_internal_encoding')
      mb_internal_encoding(@config.item('charset'))


    log_message('debug', "Form Validation Class Initialized")

  #
  # Set Rules
  #
  # This function takes an array of field names and validation
  # rules as input, validates the info, and stores it
  #
    # @param  [Mixed]  # @param  [String]    # @return [Void]  #
  setRules: ($field, $label = '', $rules = '') ->
    #  No reason to set rules if we have no POST data
    if count(@$_POST) is 0
      return @

    $indexes = []
    #  If an array was passed via the first parameter instead of indidual string
    #  values we cycle through it and recursively call this function.
    if is_array($field)
      for $row in $field
        #  Houston, we have a problem...
        if not $row['field']?  or  not $row['rules']? 
          continue
          
        
        #  If the field label wasn't passed we use the field name
        $label = if not $row['label']? then $row['field'] else $row['label']
        
        #  Here we go!
        @setRules($row['field'], $label, $row['rules'])
        
      return @
      
    
    #  No fields? Nothing to do...
    if not is_string($field) or  not is_string($rules) or $field is ''
      return @
      
    
    #  If the field label wasn't passed we use the field name
    $label = if $label is '' then $field else $label
    
    #  Is the field name an array?  We test for the existence of a bracket "[" in
    #  the field name to determine this.  If it is an array, we break it apart
    #  into its components so that we can fetch the corresponding POST data later
    if strpos($field, '[') isnt false and preg_match_all('/\\[(.*?)\\]/', $field, $matches)
      #  Note: Due to a bug in current() that affects some versions
      #  of PHP we can not pass function call directly into it
      $x = explode('[', $field)
      $indexes.push current($x)
      
      for $i in [0..count($matches['0'])-1]
        if $matches['1'][$i] isnt ''
          $indexes.push $matches['1'][$i]
        

      $is_array = true
      
    else 
      $indexes = []
      $is_array = false
      
    
    #  Build our master array
    @_field_data[$field] = 
      'field':    $field,
      'label':    $label,
      'rules':    $rules,
      'is_array': $is_array,
      'keys':     $indexes,
      'postdata': null,
      'error':    ''

    return @
    
  
  #
  # Set Error Message
  #
  # Lets users set their own error messages on the fly.  Note:  The key
  # name has to match the  function name that it corresponds to.
  #
    # @param  [String]    # @param  [String]    # @return	[String]
  #
  setMessage: ($lang, $val = '') ->
    if not is_array($lang)
      $lang = array($lang, $val)

    @_error_messages = array_merge(@_error_messages, $lang)
    
    return @
    
  
  #
  # Set The Error Delimiter
  #
  # Permits a prefix/suffix to be added to each error message
  #
    # @param  [String]    # @param  [String]    # @return [Void]  #
  setErrorDelimiters: ($prefix = '<p>', $suffix = '</p>') ->
    @_error_prefix = $prefix
    @_error_suffix = $suffix
    
    return @
    
  
  #
  # Get Error Message
  #
  # Gets the error message associated with a particular field
  #
    # @param  [String]  the field name
  # @return [Void]  #
  error: ($field = '', $prefix = '', $suffix = '') ->

    if not @_field_data[$field]? then return ''

    if not @_field_data[$field]['error']?  or @_field_data[$field]['error'] is ''
      return ''

    if $prefix is ''
      $prefix = @_error_prefix

    if $suffix is ''
      $suffix = @_error_suffix

    return $prefix + @_field_data[$field]['error'] + $suffix
    
  
  #
  # Error String
  #
  # Returns the error messages as a string, wrapped in the error delimiters
  #
    # @param  [String]    # @param  [String]    # @return	str
  #
  errorString: ($prefix = '', $suffix = '') ->
    #  No errrors, validation passes!
    if count(@_error_array) is 0
      return ''

    if $prefix is ''
      $prefix = @_error_prefix

    if $suffix is ''
      $suffix = @_error_suffix

    #  Generate the error string
    $str = ''
    for $key, $val of @_error_array
      if $val isnt ''
        $str+=$prefix + $val + $suffix + "\n"

    return $str
    
  
  #
  # Run the Validator
  #
  # This function does all the work.
  #
  # @return	bool
  #
  run: ($group = '') ->
    #  Do we even have any data to process?  Mm?
    if count(@$_POST) is 0
      return false
      
    
    #  Does the _field_data array containing the validation rules exist?
    #  If not, we look to see if they were assigned via a config file
    if count(@_field_data) is 0
      #  No validation rules?  We're done...
      if count(@_config_rules) is 0
        return false
        
      
      #  Is there a validation rule for the particular URI being accessed?
      # $uri = if ($group is '') then trim(@uri.ruri_string(), '/') else $group
      $uri = $group
      if $uri isnt '' and @_config_rules[$uri]? 
        @set_rules(@_config_rules[$uri])
        
      else 
        @set_rules(@_config_rules)
        
      
      #  We're we able to set the rules correctly?
      if count(@_field_data) is 0
        log_message('debug', "Unable to find validation rules")
        return false
        
      
    
    #  Load the language file containing error messages
    @i18n.load('form_validation')
    
    #  Cycle through the rules for each field, match the
    #  corresponding @$_POST item and test for errors
    for $field, $row of @_field_data
      #  Fetch the data from the corresponding @$_POST array and cache it in the _field_data array.
      #  Depending on whether the field name is an array or a string will determine where we get it from.
      
      if $row['is_array'] is true
        @_field_data[$field]['postdata'] = @_reduce_array(@$_POST, $row['keys'])
        
      else 
        if @$_POST[$field]?  and @$_POST[$field] isnt ""
          @_field_data[$field]['postdata'] = @$_POST[$field]

      @_execute($row, explode('|', $row['rules']), @_field_data[$field]['postdata'])

    #  Did we end up with any errors?
    $total_errors = count(@_error_array)

    if $total_errors > 0
      @_safe_form_data = true

    #  Now we need to re-set the POST data with the new, processed data
    @_reset_post_array()

    #  No errors, validation passes!
    if $total_errors is 0
      return true

    #  Validation fails
    return false
    
  
  #
  # Traverse a multidimensional @$_POST array index until the data is found
  #
  # @private
  # @param  [Array]  # @param  [Array]  # @param  [Integer]  # @return [Mixed]  #
  _reduce_array: ($array, $keys, $i = 0) ->
    if is_array($array)
      if $keys[$i]? 
        if $array[$keys[$i]]? 
          $array = @_reduce_array($array[$keys[$i]], $keys, ($i + 1))
          
        else 
          return null
      else
        return $array
    return $array
    
  
  #
  # Re-populate the _POST array with our finalized and processed data
  #
  # @private
  # @return	null
  #
  _reset_post_array :  ->
    for $field, $row of @_field_data
      if not is_null($row['postdata'])
        if $row['is_array'] is false
          if @$_POST[$row['field']]?
            @$_POST[$row['field']] = @prep_for_form($row['postdata'])
            
          
        else 
          #  start with a reference
          $post_ref = @$_POST
          
          #  before we assign values, make a reference to the right POST key
          if count($row['keys']) is 1
            $post_ref = $post_ref[current($row['keys'])]
            
          else 
            for $val in $row['keys']
              $post_ref = $post_ref[$val]
              
            
          
          if is_array($row['postdata'])
            $array = {}
            for $k, $v of $row['postdata']
              $array[$k] = @prep_for_form($v)
              
            
            $post_ref = $array
            
          else 
            $post_ref = @prep_for_form($row['postdata'])
            
          
        
      
    
  
  #
  # Executes the Validation routines
  #
  # @private
  # @param  [Array]  # @param  [Array]  # @param  [Mixed]  # @param  [Integer]  # @return [Mixed]  #
  _execute: ($row, $rules, $postdata = null, $cycles = 0) ->
    #  If the @$_POST data is an array we will run a recursive call
    if is_array($postdata)
      for $key, $val of $postdata
        @_execute($row, $rules, $val, $cycles)
        $cycles++
        
      
      return

    #  --------------------------------------------------------------------
    
    #  If the field is blank, but NOT required, no further tests are necessary
    $next = false
    if in_array('required', $rules) is false and is_null($postdata)
      #  Before we bail out, does the rule contain a callback?
      if ($match = preg_match("/(callback_\\w+)/", implode(' ', $rules)))?
        $next = true
        $rules = '1':$match[1]
        
      else 
        return



    #  --------------------------------------------------------------------
    
    #  Isset Test. Typically this rule will only apply to checkboxes.
    if is_null($postdata) and $next is false
      if in_array('isset', $rules, true) or in_array('required', $rules)
        #  Set the message type
        $type = if (in_array('required', $rules)) then 'required' else 'isset'

        if not @_error_messages[$type]?
          if false is ($line = @i18n.line($type))
            $line = 'The field was not set'
            
          
        else
          $line = @_error_messages[$type]
          
        
        #  Build the error message
        $message = sprintf($line, @_translate_fieldname($row['label']))
        
        #  Save the error message
        @_field_data[$row['field']]['error'] = $message

        if not @_error_array[$row['field']]?
          @_error_array[$row['field']] = $message

      return


    #  --------------------------------------------------------------------
    
    #  Cycle through each rule and run it
    for $rule in $rules
      $_in_array = false
      
      #  We set the $postdata variable with the current data in our master array so that
      #  each cycle of the loop is dealing with the processed data from the last cycle
      if $row['is_array'] is true and is_array(@_field_data[$row['field']]['postdata'])
        #  We shouldn't need this safety, but just in case there isn't an array index
        #  associated with this cycle we'll bail out
        if not @_field_data[$row['field']]['postdata'][$cycles]? 
          continue
          
        
        $postdata = @_field_data[$row['field']]['postdata'][$cycles]
        $_in_array = true
        
      else 
        $postdata = @_field_data[$row['field']]['postdata']


      #  --------------------------------------------------------------------
      
      #  Is the rule a callback?
      $next = false
      if substr($rule, 0, 9) is 'callback_'
        $rule = substr($rule, 9)
        $next = true

      #  Strip the parameter (if exists) from the rule
      #  Rules can contain a parameter: max_length[5]
      $param = false
      if ($match = preg_match("/(.*?)\\[(.*)\\]/", $rule))?
        $rule = $match[1]
        $param = $match[2]

      #  Call the function that corresponds to the rule
      if $next is true
        if not method_exists(@, $rule)
          continue

        #  Run the function and grab the result
        $result = @[$rule]($postdata, $param)
        
        #  Re-assign the result to the master data array
        if $_in_array is true
          @_field_data[$row['field']]['postdata'][$cycles] = if (is_bool($result)) then $postdata else $result
          
        else 
          @_field_data[$row['field']]['postdata'] = if (is_bool($result)) then $postdata else $result
          
        #  If the field isn't required and we just processed a callback we'll move on...
        if not in_array('required', $rules, true) and $result isnt false
          continue

      else
        if not method_exists(@, $rule)
          #  If our own wrapper function doesn't exist we see if a native PHP function does.
          #  Users can use any native PHP function call that has one param.
          if function_exists($rule)
            $result = $rule($postdata)
            
            if $_in_array is true
              @_field_data[$row['field']]['postdata'][$cycles] = if (is_bool($result)) then $postdata else $result
              
            else
              @_field_data[$row['field']]['postdata'] = if (is_bool($result)) then $postdata else $result

          continue

        $result = @[$rule]($postdata, $param)

        if $_in_array is true
          @_field_data[$row['field']]['postdata'][$cycles] = if (is_bool($result)) then $postdata else $result
          
        else 
          @_field_data[$row['field']]['postdata'] = if (is_bool($result)) then $postdata else $result

      #  Did the rule test negatively?  If so, grab the error.
      if $result is false
        if not @_error_messages[$rule]?
          if false is ($line = @i18n.line($rule))
            $line = 'Unable to access an error message corresponding to your field name.'

        else
          $line = @_error_messages[$rule]

        #  Is the parameter we are inserting into the error message the name
        #  of another field?  If so we need to grab its "field label"
        if @_field_data[$param]?  and @_field_data[$param]['label']?
          $param = @_translate_fieldname(@_field_data[$param]['label'])

        #  Build the error message
        $message = sprintf($line, @_translate_fieldname($row['label']), $param)

        #  Save the error message
        @_field_data[$row['field']]['error'] = $message

        if not @_error_array[$row['field']]?
          @_error_array[$row['field']] = $message
          
        return
        
      
    
  
  #
  # Translate a field name
  #
  # @private
  # @param  [String]  the field name
  # @return	[String]
  #
  _translate_fieldname: ($fieldname) ->
    #  Do we need to translate the field name?
    #  We look for the prefix lang: to determine this
    if substr($fieldname, 0, 5) is 'lang:'
      #  Grab the variable
      $line = substr($fieldname, 5)
      
      #  Were we able to translate the field name?  If not we use $line
      if false is ($fieldname = @i18n.line($line))
        return $line
        
      
    
    return $fieldname
    
  
  #
  # Get the value from a form
  #
  # Permits you to repopulate a form field with the value it was submitted
  # with, or, if that value doesn't exist, with the default
  #
    # @param  [String]  the field name
  # @param  [String]    # @return [Void]  #
  set_value: ($field = '', $default = '') ->
    if not @_field_data[$field]? 
      return $default
      
    
    #  If the data is an array output them one at a time.
    #      E.g: form_input('name[]', set_value('name[]');
    if is_array(@_field_data[$field]['postdata'])
      return array_shift(@_field_data[$field]['postdata'])
      
    
    return @_field_data[$field]['postdata']
    
  
  #
  # Set Select
  #
  # Enables pull-down lists to be set to the value the user
  # selected in the event of an error
  #
    # @param  [String]    # @param  [String]    # @return	[String]
  #
  set_select: ($field = '', $value = '', $default = false) ->
    if not @_field_data[$field]?  or  not @_field_data[$field]['postdata']? 
      if $default is true and count(@_field_data) is 0
        return ' selected="selected"'
        
      return ''
      
    
    $field = @_field_data[$field]['postdata']
    
    if is_array($field)
      if not in_array($value, $field)
        return ''
        
      
    else 
      if ($field is '' or $value is '') or ($field isnt $value)
        return ''
        
      
    
    return ' selected="selected"'
    
  
  #
  # Set Radio
  #
  # Enables radio buttons to be set to the value the user
  # selected in the event of an error
  #
    # @param  [String]    # @param  [String]    # @return	[String]
  #
  set_radio: ($field = '', $value = '', $default = false) ->
    if not @_field_data[$field]?  or  not @_field_data[$field]['postdata']? 
      if $default is true and count(@_field_data) is 0
        return ' checked="checked"'
        
      return ''
      
    
    $field = @_field_data[$field]['postdata']
    
    if is_array($field)
      if not in_array($value, $field)
        return ''
        
      
    else 
      if ($field is '' or $value is '') or ($field isnt $value)
        return ''

    return ' checked="checked"'
    
  
  #
  # Set Checkbox
  #
  # Enables checkboxes to be set to the value the user
  # selected in the event of an error
  #
    # @param  [String]    # @param  [String]    # @return	[String]
  #
  set_checkbox: ($field = '', $value = '', $default = false) ->
    if not @_field_data[$field]?  or  not @_field_data[$field]['postdata']? 
      if $default is true and count(@_field_data) is 0
        return ' checked="checked"'
        
      return ''

    $field = @_field_data[$field]['postdata']
    
    if is_array($field)
      if not in_array($value, $field)
        return ''

    else 
      if ($field is '' or $value is '') or ($field isnt $value)
        return ''

    return ' checked="checked"'
    
  
  #
  # Required
  #
    # @param  [String]    # @return	bool
  #
  required: ($str) ->
    if not is_array($str)
      return if trim($str) is '' then false else true
    else
      return if empty($str) then false else true
      
    
  
  #
  # Performs a Regular Expression match test.
  #
    # @param  [String]    # @param	regex
  # @return	bool
  #
  regex_match: ($str, $regex) ->
    if not preg_match($regex, $str)?
      return false
    return true
    
  
  #
  # Match one field to another
  #
    # @param  [String]    # @param	field
  # @return	bool
  #
  matches: ($str, $field) ->
    if not @$_POST[$field]?
      return false

    $field = @$_POST[$field]
    
    return if ($str isnt $field) then false else true
    
  
  #
  # Minimum Length
  #
    # @param  [String]    # @param	value
  # @return	bool
  #
  min_length: ($str, $val) ->
    if preg_match("/[^0-9]/", $val)?
      return false

    if function_exists('mb_strlen')
      return if (mb_strlen($str) < $val) then false else true

    return if (strlen($str) < $val) then false else true
    
  
  #
  # Max Length
  #
    # @param  [String]    # @param	value
  # @return	bool
  #
  max_length: ($str, $val) ->
    if preg_match("/[^0-9]/", $val)?
      return false
      
    
    if function_exists('mb_strlen')
      return if (mb_strlen($str) > $val) then false else true
      
    
    return if (strlen($str) > $val) then false else true
    
  
  #
  # Exact Length
  #
    # @param  [String]    # @param	value
  # @return	bool
  #
  exact_length: ($str, $val) ->
    if preg_match("/[^0-9]/", $val)?
      return false
      
    
    if function_exists('mb_strlen')
      return if (mb_strlen($str) isnt $val) then false else true
      
    
    return if (strlen($str) isnt $val) then false else true
    
  
  #
  # Valid Email
  #
    # @param  [String]    # @return	bool
  #
  valid_email: ($str) ->
    return if ( not preg_match("/^([a-z0-9\\+_\\-]+)(\\.[a-z0-9\\+_\\-]+)*@([a-z0-9\\-]+\\.)+[a-z]{2,6}$/i", $str)?) then false else true
    
  
  #
  # Valid Emails
  #
    # @param  [String]    # @return	bool
  #
  valid_emails: ($str) ->
    if strpos($str, ',') is false
      return @valid_email(trim($str))
      
    
    for $email in explode(',', $str)
      if trim($email) isnt '' and @valid_email(trim($email)) is false
        return false
        
      
    
    return true
    
  
  #
  # Validate IP Address
  #
    # @param  [String]    # @return	[String]
  #
  valid_ip: ($ip) ->
    return @input.valid_ip($ip)
    
  
  #
  # Alpha
  #
    # @param  [String]    # @return	bool
  #
  alpha: ($str) ->
    return if ( not preg_match("/^([a-z])+$/i", $str)?) then false else true
    
  
  #
  # Alpha-numeric
  #
    # @param  [String]    # @return	bool
  #
  alpha_numeric: ($str) ->
    return if ( not preg_match("/^([a-z0-9])+$/i", $str)?) then false else true
    
  
  #
  # Alpha-numeric with underscores and dashes
  #
    # @param  [String]    # @return	bool
  #
  alpha_dash: ($str) ->
    return if ( not preg_match("/^([-a-z0-9_-])+$/i", $str)?) then false else true
    
  
  #
  # Numeric
  #
    # @param  [String]    # @return	bool
  #
  numeric: ($str) ->
    return preg_match('/^[\-+]?[0-9]*\.?[0-9]+$/', $str)
    
    
  
  #
  # Is Numeric
  #
    # @param  [String]    # @return	bool
  #
  is_numeric: ($str) ->
    return if ( not is_numeric($str)) then false else true
    
  
  #
  # Integer
  #
    # @param  [String]    # @return	bool
  #
  integer: ($str) ->
    return preg_match('/^[\\-+]?[0-9]+$/', $str)
    
  
  #
  # Decimal number
  #
    # @param  [String]    # @return	bool
  #
  decimal: ($str) ->
    return preg_match('/^[\\-+]?[0-9]+\\.[0-9]+$/', $str)
    
  
  #
  # Greather than
  #
    # @param  [String]    # @return	bool
  #
  greater_than: ($str, $min) ->
    if not is_numeric($str)
      return false
      
    return $str > $min
    
  
  #
  # Less than
  #
    # @param  [String]    # @return	bool
  #
  less_than: ($str, $max) ->
    if not is_numeric($str)
      return false
      
    return $str < $max
    
  
  #
  # Is a Natural number  (0,1,2,3, etc.)
  #
    # @param  [String]    # @return	bool
  #
  is_natural: ($str) ->
    return preg_match('/^[0-9]+$/', $str)
    
  
  #
  # Is a Natural number, but not a zero  (1,2,3, etc.)
  #
    # @param  [String]    # @return	bool
  #
  is_natural_no_zero: ($str) ->
    if not preg_match('/^[0-9]+$/', $str)
      return false
      
    
    if $str is 0
      return false
      
    
    return true
    
  
  #
  # Valid Base64
  #
  # Tests a string for characters outside of the Base64 alphabet
  # as defined by RFC 2045 http://www.faqs.org/rfcs/rfc2045
  #
    # @param  [String]    # @return	bool
  #
  valid_base64: ($str) ->
    return  not preg_match('/[^a-zA-Z0-9\\/\\+=]/', $str)?
    
  
  #
  # Prep data for form
  #
  # This function allows HTML to be safely shown in a form.
  # Special characters are converted.
  #
    # @param  [String]    # @return	[String]
  #
  prep_for_form: ($data = '') ->
    if is_array($data)
      for $key, $val of $data
        $data[$key] = @prep_for_form($val)
      return $data

    if @_safe_form_data is false or $data is ''
      return $data

    return str_replace(["'", '"', '<', '>'], ["&#39;", "&quot;", '&lt;', '&gt;'], stripslashes($data))
    
  
  #
  # Prep URL
  #
    # @param  [String]    # @return	[String]
  #
  prep_url: ($str = '') ->
    if $str is 'http://' or $str is ''
      return ''

    if substr($str, 0, 7) isnt 'http://' and substr($str, 0, 8) isnt 'https://'
      $str = 'http://' + $str

    return $str
    
  
  #
  # Strip Image Tags
  #
    # @param  [String]    # @return	[String]
  #
  strip_image_tags: ($str) ->
    return @input.strip_image_tags($str)
    
  
  #
  # XSS Clean
  #
    # @param  [String]    # @return	[String]
  #
  xssClean: ($str) ->
    return @security.xssClean($str)
    
  
  #
  # Convert PHP tags to entities
  #
    # @param  [String]    # @return	[String]
  #
  encode_php_tags: ($str) ->
    return str_replace(['<?php', '<?PHP', '<?', '?>'], ['&lt;?php', '&lt;?PHP', '&lt;?', '?&gt;'], $str)
    
  
  

module.exports = system.lib.FormValidation
#  END Form Validation Class

#  End of file FormValidation.php
#  Location: .system/lib/FormValidation.php