#+--------------------------------------------------------------------+
#  URI.coffee
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
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# URI Class
#
# Parses URIs and determines routing
#
class system.core.URI

  _uri_string       : ''    # raw uri string value
  _keyval           : null  # key-value pairs parsed from uri string
  _segments         : null  # array of uri string segments, parsed on '/'
  _rsegments        : null  # array of uri string segments, parsed on '/'

  #
  # Constructor
  #
    # @param  [Object]    http request object
  # @return [Void]  #
  constructor : ($req) ->

    log_message('debug', "URI Class Initialized")

    $this = @

    defineProperties $this,
      #_uri_string   : {enumerable: false, writeable: false, value: $this.req.path}
      _uri_string   : {enumerable: false, writeable: false, value: $req.path}

    defineProperties $this,
      _keyval       : {enumerable: false, writeable: false, value: {}}
      _rsegments    : {enumerable: false, writeable: false, value: $this._uri_string.split('/')}
      _segments     : {enumerable: false, writeable: false, value: $this._uri_string.split('/')}



  #  --------------------------------------------------------------------

  #
  # Fetch a URI Segment
  #
  # This function returns the URI segment based on the number provided.
  #
    # @param  [Integer]  # @return	[Boolean]
  # @return	[String]
  #
  segment : ($n, $no_result = 0) ->
    if not @_segments[$n]? then $no_result else @_segments[$n]


  #  --------------------------------------------------------------------

  #
  # Fetch a URI "routed" Segment
  #
  # This function returns the re-routed URI segment (assuming routing rules are used)
  # based on the number provided.  If there is no routing this function returns the
  # same result as $this->segment()
  #
    # @param  [Integer]  # @return	[Boolean]
  # @return	[String]
  #
  rsegment : ($n, $no_result = 0) ->
    if not @_rsegments[$n]? then $no_result else @_rsegments[$n]

  #  --------------------------------------------------------------------

  #
  # Generate a key value pair from the URI string
  #
  # This function generates and associative array of URI data starting
  # at the supplied segment. For example, if this is your URI:
  #
  #	example.com/user/search/name/joe/location/UK/gender/male
  #
  # You can use this function to generate an array with this prototype:
  #
  # array (
  #			name => joe
  #			location => UK
  #			gender => male
  #		 )
  #
    # @param  [Integer]  the starting segment number
  # @param  [Array]  an array of default values
  # @return	array
  #
  uriToAssoc: ($n = 3, $default = {}) ->
    @_uri_to_assoc($n, $default, 'segment')

  #
  # Identical to above only it uses the re-routed segment array
  #
  #
  ruriToAssoc: ($n = 3, $default = {}) ->
    @_uri_to_assoc($n, $default, 'rsegment')

  #  --------------------------------------------------------------------

  #
  # Generate a key value pair from the URI string or Re-routed URI string
  #
  # @private
  # @param  [Integer]  the starting segment number
  # @param  [Array]  an array of default values
  # @param  [String]  which array we should use
  # @return	array
  #
  @_uri_to_assoc = ($n = 3, $default = {}, $which = 'segment') ->
    if $which is 'segment'
      $total_segments = 'total_segments'
      $segment_array = 'segment_array'

    else
      $total_segments = 'total_rsegments'
      $segment_array = 'rsegment_array'

    if not is_numeric($n)
      return $default

    if @_keyval[$n]?
      return @_keyval[$n]

    if @[$total_segments]() < $n
      if count($default) is 0
        return {}

      $retval = {}
      for $val in $default
        $retval[$val] = false

      return $retval

    $i = 0
    $lastval = ''
    $retval = {}
    for $seg in array_slice(@[$segment_array](), ($n - 1))
      if $i2
        $retval[$lastval] = $seg

      else
        $retval[$seg] = false
        $lastval = $seg

      $i++

    if count($default) > 0
      for $val in $default
        if not array_key_exists($val, $retval)
          $retval[$val] = false

    #  Cache the array for reuse
    @_keyval[$n] = $retval
    return $retval

  #  --------------------------------------------------------------------

  #
  # Generate a URI string from an associative array
  #
  #
    # @param  [Array]  an associative array of key/values
  # @return	array
  #
  assocToUri : ($array) ->
    $temp = {}
    for $key, $val of $array
      $temp.push $key
      $temp.push $val

    return implode('/', $temp)


  #  --------------------------------------------------------------------

  #
  # Fetch a URI Segment and add a trailing slash
  #
    # @param  [Integer]  # @param  [String]    # @return	[String]
  #
  slashSegment : ($n, $where = 'trailing') ->
    @_slash_segment($n, $where, 'segment')


  #  --------------------------------------------------------------------

  #
  # Fetch a URI Segment and add a trailing slash
  #
    # @param  [Integer]  # @param  [String]    # @return	[String]
  #
  slashRsegment : ($n, $where = 'trailing') ->
    @_slash_segment($n, $where, 'rsegment')

  #  --------------------------------------------------------------------

  #
  # Fetch a URI Segment and add a trailing slash - helper function
  #
  # @private
  # @param  [Integer]  # @param  [String]    # @param  [String]    # @return	[String]
  #
  @_slash_segment = ($n, $where = 'trailing', $which = 'segment') ->
    $leading = '/'
    $trailing = '/'

    if $where is 'trailing'
      $leading = ''

    else if $where is 'leading'
      $trailing = ''

    return $leading + @[$which]($n) + $trailing


  #  --------------------------------------------------------------------

  #
  # Segment Array
  #
    # @return	array
  #
  segmentArray :  ->
    @_segments


  #  --------------------------------------------------------------------

  #
  # Routed Segment Array
  #
    # @return	array
  #
  rsegmentArray :  ->
    @_rsegments


  #  --------------------------------------------------------------------

  #
  # Total number of segments
  #
    # @return	integer
  #
  totalSegments :  ->
    count(@_segments)


  #  --------------------------------------------------------------------

  #
  # Total number of routed segments
  #
    # @return	integer
  #
  totalRsegments :  ->
    count(@_rsegments)


  #  --------------------------------------------------------------------

  #
  # Fetch the entire URI string
  #
    # @return	[String]
  #
  uriString :  ->
    @_uri_string


  #  --------------------------------------------------------------------

  #
  # Fetch the entire Re-routed URI string
  #
    # @return	[String]
  #
  ruriString :  ->
    '/' + implode('/', @rsegment_array())




module.exports = system.core.URI
#  END URI Class

#  End of file URI.php
#  Location: .system/core/URI.php