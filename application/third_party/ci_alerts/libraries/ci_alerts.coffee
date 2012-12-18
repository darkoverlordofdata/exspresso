#+--------------------------------------------------------------------+
#  ci_alerts.coffee
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
#
# ci_alerts
#
# Tools to alert and set/get flashdata from ci_alerts.
#
# @license		http://www.apache.org/licenses/LICENSE-2.0  Apache License 2.0
# @author		Mike Funk
# @link		http://mikefunk.com
# @email		mike@mikefunk.com
#
# @file		ci_alerts.php
# @version		1.1.7
# @date		03/28/2012
#

#  --------------------------------------------------------------------------

#
# ci_alerts class.
#
class global.ci_alerts

  #  --------------------------------------------------------------------------
  
  #
  # _ci
  #
  # holds the codeigniter superobject.
  #
  # @var mixed
  # @access private
  #
  _ci: null
  
  #  --------------------------------------------------------------------------
  
  #
  # __construct function.
  #
  # @access public
  # @return void
  #
  constructor: ($config = {}, @_ci) ->

    @_ci.load.library('session')
    log_message('debug', 'CI Alerts: Library loaded.')

  #  --------------------------------------------------------------------------
  
  #
  # set function.
  #
  # adds an item to the specified flasydata array.
  #
  # @access public
  # @param string $type
  # @param string $msg
  # @return bool
  #
  set: ($type, $msg) ->

    #  retrive the flashdata, add to the array, set it again
    $arr = @_ci.session.userdata(@_ci.session.flashdata_key + ':new:' + $type)
    if $arr is false or $arr is '' then $arr = []

    #  remove duplicates if configured to do so
    if config_item('remove_duplicates') then $arr = array_unique($arr)

    $arr.push $msg
    @_ci.session.set_flashdata($type, $arr)


  #  --------------------------------------------------------------------------
  
  #
  # get function.
  #
  # gets all items or just items by the specified type as an array.
  #
  # @access public
  # @param string $type (default: '')
  # @return array
  #
  get: ($type = '') ->

    #  if it's all alerts
    if $type is ''
      $arr =
        'error':    @_ci.session.flashdata('error')
        'success':  @_ci.session.flashdata('success')
        'warning':  @_ci.session.flashdata('warning')
        'info':     @_ci.session.flashdata('info')
      return $arr

    #  else it's a specific type
    else
      return @_ci.session.flashdata($type)
    

  #  --------------------------------------------------------------------------
  
  #
  # display function.
  #
  # returns html wrapped items, either all or limited to a specific type.
  #
  # @access public
  # @param string $type (default: '')
  # @return string
  #
  display: ($type = '') ->
    $out = ''

    #  if no type is passed, add all message data to output
    if $type is ''
      $arr = @get()

      if $arr is false then $arr = {}

      for $type, $items of $arr
        if is_array($items)
          $out+=config_item('before_all')
          for $item in $items
            $out+=@_wrap($item, $type)

          $out+=config_item('after_all')
    #  else just this type
    else
      $arr = @get($type)

      if $arr is false then $arr = {}

      if is_array($arr)
        $out+=config_item('before_all')
        for $item in $arr
          $out+=@_wrap($item, $type)

        $out+=config_item('after_all')


    return $out

  #  --------------------------------------------------------------------------
  
  #
  # _wrap function.
  #
  # wraps an item in it's configured html and returns the value.
  #
  # @access private
  # @param string $msg
  # @param string $type
  # @return string
  #
  _wrap: ($msg, $type) ->

    $out = ''
    $out+=config_item('before_each')
    if $type isnt ''
      $out+=config_item('before_' + $type)

    else
      $out+=config_item('before_no_type' + $type)

    $out+=$msg
    $out+=config_item('after_each')
    if $type isnt ''
      $out+=config_item('after_' + $type)

    else
      $out+=config_item('after_no_type' + $type)

    return $out


  #  --------------------------------------------------------------------------
  

module.exports = ci_alerts
#  End of file ci_alerts.php 
#  Location: ./ci_authentication/libraries/ci_alerts.php 
