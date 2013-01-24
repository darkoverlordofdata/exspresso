#+--------------------------------------------------------------------+
#  URI.coffee
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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# URI Class
#
# Parses URIs and determines routing
#
# @package		Exspresso
# @subpackage	Libraries
# @category	URI
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/uri.html
#
class global.Exspresso_URI

  keyval: null
  _uri_string: ''
  segments: null
  rsegments: null

  #
  # Constructor
  #
  # Simply globalizes the Exspresso.router object.  The front
  # loads the Router class early on so it's not available
  # normally as other classes are.
  #
  # @access	public
  #
  constructor : () ->

    @keyval = {}
    @segments = []
    @rsegments = []

    log_message('debug', "URI Class Initialized")
    Exspresso.server.uri @

  #  --------------------------------------------------------------------

  #
  # Fetch a URI Segment
  #
  # This function returns the URI segment based on the number provided.
  #
  # @access	public
  # @param	integer
  # @param	bool
  # @return	string
  #
  segment : ($n, $no_result = false) ->
    $no_result


  #  --------------------------------------------------------------------

  #
  # Fetch a URI "routed" Segment
  #
  # This function returns the re-routed URI segment (assuming routing rules are used)
  # based on the number provided.  If there is no routing this function returns the
  # same result as $this->segment()
  #
  # @access	public
  # @param	integer
  # @param	bool
  # @return	string
  #
  rsegment : ($n, $no_result = false) ->
    $no_result

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
  # @access	public
  # @param	integer	the starting segment number
  # @param	array	an array of default values
  # @return	array
  #
  uri_to_assoc: ($n = 3, $default = {}) ->
    return @_uri_to_assoc($n, $default, 'segment')

  #
  # Identical to above only it uses the re-routed segment array
  #
  #
  ruri_to_assoc: ($n = 3, $default = {}) ->
    return @_uri_to_assoc($n, $default, 'rsegment')

  #  --------------------------------------------------------------------

  #
  # Generate a URI string from an associative array
  #
  #
  # @access	public
  # @param	array	an associative array of key/values
  # @return	array
  #
  assoc_to_uri : ($array) ->
    $temp = {}
    for $key, $val of $array
      $temp.push $key
      $temp.push $val


    return implode('/', $temp)


  #  --------------------------------------------------------------------

  #
  # Fetch a URI Segment and add a trailing slash
  #
  # @access	public
  # @param	integer
  # @param	string
  # @return	string
  #
  slash_segment : ($n, $where = 'trailing') ->
    return @_slash_segment($n, $where, 'segment')


  #  --------------------------------------------------------------------

  #
  # Fetch a URI Segment and add a trailing slash
  #
  # @access	public
  # @param	integer
  # @param	string
  # @return	string
  #
  slash_rsegment : ($n, $where = 'trailing') ->
    return @_slash_segment($n, $where, 'rsegment')

  #  --------------------------------------------------------------------

  #
  # Segment Array
  #
  # @access	public
  # @return	array
  #
  segment_array :  ->
    []


  #  --------------------------------------------------------------------

  #
  # Routed Segment Array
  #
  # @access	public
  # @return	array
  #
  rsegment_array :  ->
    []


  #  --------------------------------------------------------------------

  #
  # Total number of segments
  #
  # @access	public
  # @return	integer
  #
  total_segments :  ->
    0


  #  --------------------------------------------------------------------

  #
  # Total number of routed segments
  #
  # @access	public
  # @return	integer
  #
  total_rsegments :  ->
    0


  #  --------------------------------------------------------------------

  #
  # Fetch the entire URI string
  #
  # @access	public
  # @return	string
  #
  uri_string :  ->
    return ''


  #  --------------------------------------------------------------------

  #
  # Fetch the entire Re-routed URI string
  #
  # @access	public
  # @return	string
  #
  ruri_string :  ->
    return '/' + implode('/', @rsegment_array())

  # --------------------------------------------------------------------

  #
  # Override output instance methods
  #
  #   @returns function middlware callback
  #
  middleware: ()->

    log_message 'debug',"URI middleware initialized"

    ($req, $res, $next) =>

      $keyval = {}
      $uri_string = $req.path
      $rsegments = $segments = $uri_string.split('/')

      #  --------------------------------------------------------------------

      #
      # Fetch a URI Segment
      #
      # This function returns the URI segment based on the number provided.
      #
      # @access	public
      # @param	integer
      # @param	bool
      # @return	string
      #
      @segment = ($n, $no_result = 0) ->
        return if not $segments[$n]? then $no_result else $segments[$n]


      #  --------------------------------------------------------------------

      #
      # Fetch a URI "routed" Segment
      #
      # This function returns the re-routed URI segment (assuming routing rules are used)
      # based on the number provided.  If there is no routing this function returns the
      # same result as $this->segment()
      #
      # @access	public
      # @param	integer
      # @param	bool
      # @return	string
      #
      @rsegment = ($n, $no_result = 0) ->
        return if not $rsegments[$n]? then $no_result else $rsegments[$n]


      #  --------------------------------------------------------------------

      #
      # Generate a key value pair from the URI string or Re-routed URI string
      #
      # @access	private
      # @param	integer	the starting segment number
      # @param	array	an array of default values
      # @param	string	which array we should use
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


        if $keyval[$n]?
          return $keyval[$n]


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
        $keyval[$n] = $retval
        return $retval

      #  --------------------------------------------------------------------

      #
      # Fetch a URI Segment and add a trailing slash - helper function
      #
      # @access	private
      # @param	integer
      # @param	string
      # @param	string
      # @return	string
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
      # @access	public
      # @return	array
      #
      @segment_array =  ->
        return $segments


      #  --------------------------------------------------------------------

      #
      # Routed Segment Array
      #
      # @access	public
      # @return	array
      #
      @rsegment_array =  ->
        return $rsegments


      #  --------------------------------------------------------------------

      #
      # Total number of segments
      #
      # @access	public
      # @return	integer
      #
      @total_segments =  ->
        return count($segments)


      #  --------------------------------------------------------------------

      #
      # Total number of routed segments
      #
      # @access	public
      # @return	integer
      #
      @total_rsegments =  ->
        return count($rsegments)


      #  --------------------------------------------------------------------

      #
      # Fetch the entire URI string
      #
      # @access	public
      # @return	string
      #
      @uri_string =  ->
        return $uri_string

      $next()





module.exports = Exspresso_URI
#  END URI Class

#  End of file URI.php
#  Location: ./system/core/URI.php