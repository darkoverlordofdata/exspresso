#+--------------------------------------------------------------------+
#| Meta.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	Exspresso Metaprogramming module
#
#   Metaprogramming utils
#

_class = {}    # metadata cache

#
# privately dereference some Object utility functions
create                            = Object.create
getPrototypeOf                    = Object.getPrototypeOf
getOwnPropertyDescriptor          = Object.getOwnPropertyDescriptor
getOwnPropertyNames               = Object.getOwnPropertyNames
#
# Copy Own Properties
#
# Copy all properties from a source or template object
# Getters, setters, read only, and other custom attributes
# are safely copied
#
# @param	object	destination object
# @param	object	source object
# @return	object
#
exports.copyOwnProperties = ($dst, $src) ->
  $properties = {}
  for $key in getOwnPropertyNames($src)
    $properties[$key] = getOwnPropertyDescriptor($src, $key)

  defineProperties $dst, $properties

#
# publicly dereference some Object utility functions
exports.defineProperties          = Object.defineProperties
exports.defineProperty            = Object.defineProperty
exports.freeze                    = Object.freeze
exports.keys                      = Object.keys

#
# Define Getter
#
# @access	public
# @param	object	property definition
# @return	object
#
Function::getter = ($def) ->
  $name = keys($def)[0]
  defineProperty @::, $name, {get: $def[$name]}

#
# Define Setter
#
# @access	public
# @param	object	property definition
# @return	object
#
Function::setter = ($def) ->
  $name = keys($def)[0]
  defineProperty @::, $name, {set: $def[$name]}

#
# Define Class Metadata
#
# Analyze the metadata for a class, then build and cache
# a table of property definitions for that classs.
#
# @param	object	destination object
# @param	object	source object
# @return	object  the cached metadata
#
exports.defineClass = ($class) ->

  $name = $class::constructor.name
  if not _class[$name]?

    $props = {}       # an array to build the object property def
    $chain = []       # an array to list the inheritance chain
    $proto = $class:: # starting point in the chain

    # Build an inheritance list
    while $proto isnt Object::
      $chain.push $proto
      $proto = getPrototypeOf($proto)

    # Reverse list to process overrides in the correct order
    for $proto in $chain.reverse()
      if $proto isnt Object::
        # Build the inherited properties table
        for $key in getOwnPropertyNames($proto)
          $props[$key] = getOwnPropertyDescriptor($proto, $key)

    # cache the class definition
    _class[$name] = $props
  _class[$name]

#
# Create a Mixin
#
# Create a mixin object from a prototype and
# list of classes
#
#
# @param	object	object to use as the prototype
# @param	array   list of mixin classes, followed by construcor args
# @return	object
#
exports.create_mixin = ($object, $args...) ->

  $properties = {}
  $pos = 0
  while 'function' is typeof ($mixin = $args[$pos])
    $pos++
    for $key, $val of defineClass($mixin)
      $properties[$key] = $val

  $this = create($object, $properties)
  $args[0].apply $this, $args[$pos..]
  $this


#
# Mixin from Class
#
# Creates a controller mixin object from a class
#
#
# @param	object	an Exspresso_Controller object
# @param	mixed   class name or object
# @param	object	(optional) config data
# @return	object
#
exports.mixin_class = ($controller, $class, $config) ->

  create_mixin($controller, $class, $controller, $config)


#
# Mixin from View Data
#
# Creates a controller mixin object from view data
#
#
# @param	object	an Exspresso_Controller object
# @param	object	data
# @return	object
#
exports.mixin_view = ($controller, $data) ->

  __PROTO__ = true # Use the non-standard __proto__ property
  if __PROTO__
    $data.__proto__ = $controller
    return $data

  $props = {}       # an array to build the object property def

  # Build the data elements property table
  for $key in getOwnPropertyNames($data)
    $props[$key] = getOwnPropertyDescriptor($data, $key)

  # Now, create the object
  create($controller, $props)


#  ------------------------------------------------------------------------
#
# Export module to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body
# End of file Meta.coffee
# Location: .system/core/Meta.coffee