#+--------------------------------------------------------------------+
#| Common.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Darklite is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	Common - Main application
#
{file_exists} = require('not-php') # load helpers

# config cache
$_config      = []
$_config_item = {}

# class cache
$_classes     = {}
$_is_loaded   = {}


#  ------------------------------------------------------------------------

#
# Class registry
#
# This function acts as a singleton.  If the requested class does not
# exist it is instantiated and set to a static variable.  If it has
# previously been instantiated the variable is returned.
#
# @access	public
# @param	string	the class name being requested
# @param	string	the directory where the class should be found
# @param	string	the class name prefix
# @return	object
#
exports.load_class = load_class = ($class, $directory = 'libraries', $prefix = '') ->

  #  Does the class exist?  If so, we're done...
  if $_classes[$class]?
    return $_classes[$class]


  $name = false

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [BASEPATH, APPPATH]
    if file_exists($path + $directory + '/' + $class + EXT)
      $name = $prefix + $class

      if not exspresso[$name]?
        require $path + $directory + '/' + $class + EXT

      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT)
    $name = config_item('subclass_prefix') + $class

    if not exspresso[$name]?
      require APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT

  #  Did we find the class?
  if $name is false
    console.log 'Unable to locate the specified class: ' + $class + EXT
    process.exit 1


  #  Keep track of what we just loaded
  is_loaded($class)

  $_classes[$class] = new $name()
  return $_classes[$class]


#  --------------------------------------------------------------------
#
# Keeps track of which libraries have been loaded.  This function is
# called by the load_class() function above
#
# @access	public
# @return	array
#
is_loaded = ($class = '') ->

  if $class isnt ''
    $_is_loaded[$class.toLowerCase()] = $class

  return $_is_loaded


#  ------------------------------------------------------------------------

#  ------------------------------------------------------------------------

#
# Loads the main config.php file
#
# This function lets us grab the config file even if the Config class
# hasn't been instantiated yet
#
# @access	private
# @return	array
#
exports.get_config = get_config = ($replace = {}) ->

  if $_config[0]?
    return $_config[0]


  #  Is the config file in the environment folder?
  if not file_exists($file_path = APPPATH + 'config/' + ENVIRONMENT + '/config')
    $file_path = APPPATH + 'config/config'


  #  Fetch the config file
  if not file_exists($file_path)
    console.log 'The configuration file does not exist.'
    process.exit 1


  $config = require($file_path)

  #  Does the $config array exist in the file?
  if not $config?  #or  not is_array($config)
    console.log 'Your config file does not appear to be formatted correctly.'
    process.exit 1


  #  Are any values being dynamically replaced?
  for $val, $key of $replace
    if $config[$key]?
      $config[$key] = $val

  return $_config[0] = $config

#  ------------------------------------------------------------------------

#
# Returns the specified config item
#
# @access	public
# @return	mixed
#
exports.config_item = config_item = ($item) ->

  if not $_config_item[$item]?
    $config = get_config()

    if not $config[$item]?
      return false

    $_config_item[$item] = $config[$item]


  return $_config_item[$item]



# End of file Common.coffee
# Location: ./Common.coffee