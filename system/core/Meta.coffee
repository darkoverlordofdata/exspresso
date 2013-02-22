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
# privately dereference some Object utility members
create                            = Object.create
getPrototypeOf                    = Object.getPrototypeOf
getOwnPropertyDescriptor          = Object.getOwnPropertyDescriptor
getOwnPropertyNames               = Object.getOwnPropertyNames
prototype                         = Object.prototype
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
# publicly dereference some Object utility members
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
    until $proto is prototype
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
# Create a mixin object from a prototype object
# with an optional list of classes to mixin,
# followed by an optional list of arguments to the
# constructor of the first class.
#
# If there are no classes, the list of args is a list
# of additional objects that are simply merged into the
# first object. These objects are expected to be literal
# based, and only the own properties are used
#
#
# @param	object	object to use as the prototype
# @param	array   list of mixin classes, followed by construcor args
# @return	object
#
exports.create_mixin = ($object, $args...) ->

  $properties = {}
  $pos = 0

  # get the mixin class(es)
  while 'function' is typeof ($mixin = $args[$pos])
    # the 1st mixin will also be a constructor
    $class = $mixin if $pos is 0
    $pos++
    for $key, $val of defineClass($mixin)
      $properties[$key] = $val

  # no class was encountered
  if $class?
    # clone the object with all properties
    $this = create($object, $properties)
    # call the constructor
    $class.apply $this, $args[$pos..]
    $this

  else switch $args.length
    when 0
      # simple case -
      #   just clone the object
      create($object)

    when 1
      # optimized case -
      #   merge object with object
      $args[0].__proto__ = $object
      create($args[0])
      
    else
      # optimized case -
      #   merge object with object
      for $i in [1...$args.length]
        $args[$i-1] = $args[$i].__proto__
      $args[$args.length-1].__proto__ = $object
      create($args[0])



#  ------------------------------------------------------------------------
#
# Export module to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body
# End of file Meta.coffee
# Location: .system/core/Meta.coffee