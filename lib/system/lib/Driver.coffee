#+--------------------------------------------------------------------+
#  Driver.coffee
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
# Exspresso Driver Class
#
# This class enables you to create drivers for a Library based on the Driver Library.
# It handles the drivers' access to the parent library
#
#
module.exports = class system.lib.Driver

  #
  # Decorate
  #
  # Decorates the child with the parent driver lib's methods and properties
  #
  # @param  [Object]
  # @return [Void]
  #
  decorate: ($parent) ->

    # Decorate the driver with forwarders to the
    # parent driver lib's methods and properties
    for $name, $fn of $parent
      if $name[0] isnt '_' # skip - protected by convention
        do ($name, $fn) ->
          if typeof $fn is 'function'
            # forward the parent function call
            @[$name] = ($args...) ->
              $fn.apply($parent, $args)
          else
            # forward the parent accessor
            defineProperty @, $name, get:  -> $parent[$name]
            defineProperty @, $name, set: ($newval) -> $parent[$name] = $newval
    @

