#+--------------------------------------------------------------------+
#  form_validation_lang.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#


exports['required'] = "The %s field is required."
exports['isset'] = "The %s field must have a value."
exports['valid_email'] = "The %s field must contain a valid email address."
exports['valid_emails'] = "The %s field must contain all valid email addresses."
exports['valid_url'] = "The %s field must contain a valid URL."
exports['valid_ip'] = "The %s field must contain a valid IP."
exports['min_length'] = "The %s field must be at least %s characters in length."
exports['max_length'] = "The %s field can not exceed %s characters in length."
exports['exact_length'] = "The %s field must be exactly %s characters in length."
exports['alpha'] = "The %s field may only contain alphabetical characters."
exports['alpha_numeric'] = "The %s field may only contain alpha-numeric characters."
exports['alpha_dash'] = "The %s field may only contain alpha-numeric characters, underscores, and dashes."
exports['numeric'] = "The %s field must contain only numbers."
exports['is_numeric'] = "The %s field must contain only numeric characters."
exports['integer'] = "The %s field must contain an integer."
exports['regex_match'] = "The %s field is not in the correct format."
exports['matches'] = "The %s field does not match the %s field."
exports['is_natural'] = "The %s field must contain only positive numbers."
exports['is_natural_no_zero'] = "The %s field must contain a number greater than zero."
exports['decimal'] = "The %s field must contain a decimal number."
exports['less_than'] = "The %s field must contain a number less than %s."
exports['greater_than'] = "The %s field must contain a number greater than %s."


#  End of file form_validation_lang.php 
#  Location: ./system/language/english/form_validation_lang.php 