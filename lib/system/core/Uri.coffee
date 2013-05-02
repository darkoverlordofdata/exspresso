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
# Uri Class
#
# Parses URIs and determines routing
#
module.exports = class system.core.Uri

  _uri_string       : ''    # raw uri string value
  _keyval           : null  # key-value pairs parsed from uri string
  _segments         : null  # array of uri string segments, parsed on '/'
  _rsegments        : null  # array of uri string segments, parsed on '/'

  #
  # Constructor
  #
  # @param  [Object]  req http request object
  # @return [Void]
  #
  constructor : ($req) ->

    log_message 'debug', "Uri Class Initialized"


    defineProperties @,
      _uri_string   : {enumerable: false, writeable: false, value: $req.url}
      _keyval       : {enumerable: false, writeable: false, value: {}}
    defineProperties @,
      _rsegments    : {enumerable: false, writeable: false, value: @_uri_string.split('/')}
      _segments     : {enumerable: false, writeable: false, value: @_uri_string.split('/')}

  #
  # Fetch a URI Segment
  #
  # This function returns the URI segment based on the number provided.
  #
  # @param  [Integer] n segment number
  # @param	[Mixed] no_result the value to return if there is no segment n
  # @return	[String] the segment value
  #
  segment : ($n, $no_result = 0) ->
    if not @_segments[$n]? then $no_result else @_segments[$n]


  #
  # Fetch a URI "routed" Segment
  #
  # This function returns the re-routed URI segment (assuming routing rules are used)
  # based on the number provided.  If there is no routing this function returns the
  # same result as @segment()
  #
  # @param  [Integer] n segment number
  # @param	[Mixed] no_result the value to return if there is no segment n
  # @return	[String] the segment value
  #
  rsegment : ($n, $no_result = 0) ->
    if not @_rsegments[$n]? then $no_result else @_rsegments[$n]

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
  # @param  [Integer] n the starting segment number
  # @param  [Array] default an array of default values
  # @return	[Object] uri as hash table
  #
  uriToAssoc: ($n = 3, $default = {}) ->
    @_uri_to_assoc($n, $default, 'segment')

  #
  # Identical to above only it uses the re-routed segment array
  #
  #
  # @param  [Integer] n the starting segment number
  # @param  [Array] default an array of default values
  # @return	[Object] uri as hash table
  #
  ruriToAssoc: ($n = 3, $default = {}) ->
    @_uri_to_assoc($n, $default, 'rsegment')

  #
  # Generate a key value pair from the URI string or Re-routed URI string
  #
  # @private
  # @param  [Integer]  the starting segment number
  # @param  [Array]  an array of default values
  # @param  [String]  which array we should use
  # @return	array
  #
  @_uri_to_assoc: ($n = 3, $default = {}, $which = 'segment') ->
    if $which is 'segment'
      $total_segments = 'total_segments'
      $segment_array = 'segment_array'

    else
      $total_segments = 'total_rsegments'
      $segment_array = 'rsegment_array'

    return $default if typeof $n isnt 'number'

    return @_keyval[$n] if @_keyval[$n]?

    if @[$total_segments]() < $n
      return {} if Object.keys($default).length is 0

      $retval = {}
      for $val in $default
        $retval[$val] = false

      return $retval

    $i = 0
    $lastval = ''
    $retval = {}
    for $seg in @[$segment_array]().slice(($n - 1))
      if $i2
        $retval[$lastval] = $seg

      else
        $retval[$seg] = false
        $lastval = $seg

      $i++

    if $default.length > 0
      for $val in $default
        if not $retval[$val]?
          $retval[$val] = false

    #  Cache the array for reuse
    @_keyval[$n] = $retval

  #
  # Generate a URI string from an associative array
  #
  #
  # @param  [Object]  an associative array of key/values
  # @return	[Array] uri segment array
  #
  assocToUri : ($array) ->
    $temp = {}
    for $key, $val of $array
      $temp.push $key
      $temp.push $val

    $temp.join('/')


  #
  # Fetch a URI Segment and add a trailing slash
  #
  # @param  [Integer] n segment number
  # @param  [String]  where trailing or leading
  # @return	[String] slashed segment
  #
  slashSegment : ($n, $where = 'trailing') ->
    @_slash_segment($n, $where, 'segment')


  #
  # Fetch a URI rSegment and add a trailing slash
  #
  # @param  [Integer] n segment number
  # @param  [String]  where trailing or leading
  # @return	[String] slashed rsegment
  #
  slashRsegment : ($n, $where = 'trailing') ->
    @_slash_segment($n, $where, 'rsegment')

  #
  # Fetch a URI Segment and add a trailing slash - helper function
  #
  # @private
  # @param  [Integer]
  # @param  [String]
  # @param  [String]
  # @return	[String]
  #
  @_slash_segment: ($n, $where = 'trailing', $which = 'segment') ->
    $leading = '/'
    $trailing = '/'

    if $where is 'trailing'
      $leading = ''
    else if $where is 'leading'
      $trailing = ''

    $leading + @[$which]($n) + $trailing


  #
  # Segment Array
  #
  # @return	[Array] the parsed segments array
  #
  segmentArray :  ->
    @_segments


  #
  # Routed Segment Array
  #
  # @return	[Array] the parsed rsegments array
  #
  rsegmentArray :  ->
    @_rsegments


  #
  # Total number of segments
  #
  # @return	[Integer] the count of segments
  #
  totalSegments :  ->
    @_segments.length


  #
  # Total number of routed segments
  #
  # @return	[Integer] the count of rsegments
  #
  totalRsegments :  ->
    @_rsegments.length


  #
  # Fetch the entire URI string
  #
  # @return	[String] the original uri string
  #
  uriString :  ->
    @_uri_string


  #
  # Fetch the entire Re-routed URI string
  #
  # @return	[String] the re-routed uri string
  #
  ruriString :  ->
    '/'+@rsegment_array().join('/')

