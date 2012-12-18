#+--------------------------------------------------------------------+
#  db_lang.coffee
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
# This file was ported from php to coffee-script using php2coffee
#
#

exports['db_invalid_connection_str'] = 'Unable to determine the database settings based on the connection string you submitted.'
exports['db_unable_to_connect'] = 'Unable to connect to your database server using the provided settings.'
exports['db_unable_to_select'] = 'Unable to select the specified database: %s'
exports['db_unable_to_create'] = 'Unable to create the specified database: %s'
exports['db_invalid_query'] = 'The query you submitted is not valid.'
exports['db_must_set_table'] = 'You must set the database table to be used with your query.'
exports['db_must_use_set'] = 'You must use the "set" method to update an entry.'
exports['db_must_use_index'] = 'You must specify an index to match on for batch updates.'
exports['db_batch_missing_index'] = 'One or more rows submitted for batch updating is missing the specified index.'
exports['db_must_use_where'] = 'Updates are not allowed unless they contain a "where" clause.'
exports['db_del_must_use_where'] = 'Deletes are not allowed unless they contain a "where" or "like" clause.'
exports['db_field_param_missing'] = 'To fetch fields requires the name of the table as a parameter.'
exports['db_unsupported_function'] = 'This feature is not available for the database you are using.'
exports['db_transaction_failure'] = 'Transaction failure: Rollback performed.'
exports['db_unable_to_drop'] = 'Unable to drop the specified database.'
exports['db_unsuported_feature'] = 'Unsupported feature of the database platform you are using.'
exports['db_unsuported_compression'] = 'The file compression format you chose is not supported by your server.'
exports['db_filepath_error'] = 'Unable to write data to the file path you have submitted.'
exports['db_invalid_cache_path'] = 'The cache path you submitted is not valid or writable.'
exports['db_table_name_required'] = 'A table name is required for that operation.'
exports['db_column_name_required'] = 'A column name is required for that operation.'
exports['db_column_definition_required'] = 'A column definition is required for that operation.'
exports['db_unable_to_set_charset'] = 'Unable to set client connection character set: %s'
exports['db_error_heading'] = 'A Database Error Occurred'

#  End of file db_lang.php 
#  Location: ./system/language/english/db_lang.php 