#+--------------------------------------------------------------------+
#  Router.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
# 
#  This file is a part of Expresso
# 
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
# 
#+--------------------------------------------------------------------+
#
# Router Component
#
# Parses URIs and determines routing
#

#  ------------------------------------------------------------------------
#
# Exspresso Router Class
#
class global.CI_Router

  routes:                 {}          # route dispatch bindings

  _default_controller:    false       # matches route '/'
  _404_override:          false       # when the specified controller is not found
  _directory:             ''          # parsed directory
  _class:                 ''          # parsed class
  _method:                ''          # parsed method

  constructor: ->

    @config = load_class('Config', 'core')
    log_message('debug', "Router Class Initialized")


  # --------------------------------------------------------------------

  #
  # Set the route mapping
  #
  # This function determines what should be served based on the URI request,
  # as well as any "routes" that have been set in the routing config file.
  #
  # @access	private
  # @return	void
  #
  _set_routing: ($uri) ->

    @_directory = ''
    @_class = ''
    @_method = ''
    @_set_request $uri.split('/')

  # --------------------------------------------------------------------

  #
  # Set the default controller
  #
  # @access	private
  # @return	void
  #
  _set_default_controller: ->
    
    if @_default_controller is false
      show_error "Unable to determine what should be displayed. A default route has not been specified in the routing file."

    # Is the method being specified?
    if @_default_controller.indexOf('/') isnt -1

      $x = @_default_controller.split('/')
      @set_class $x[0]
      @set_method $x[1]
      @_set_request $x
      
    else
      
      @set_class @_default_controller
      @set_method 'index'
      @_set_request [@_default_controller, 'index']

    log_message 'debug', "No URI present. Default controller set."

  #
  # Set the Route
  #
  # This takes an array of URI segments as
  # input, and sets the current class/method
  #
  # @access	private
  # @param	array
  # @param	bool
  # @return	void
  #
  _set_request: ($segments = []) ->

    $segments = @_validate_request($segments)

    if $segments.length is 0
      return @_set_default_controller()
    
    @set_class $segments[0]
    
    if $segments[1]?

      # A standard method request
      @set_method $segments[1]

    else

      # This lets the "routed" segment array identify that the default
      # index method is being used.
      $segments[1] = 'index'


  # --------------------------------------------------------------------

  #
  # Validates the supplied segments.  Attempts to determine the path to
  # the controller.
  #
  # @access	private
  # @param	array
  # @return	array
  #
  _validate_request: ($segments) ->

    if $segments.length is 0
      return $segments


    # Does the requested controller exist in the root folder?
    if file_exists(APPPATH + 'controllers/' + $segments[0] + EXT)
      return $segments


    # Is the controller in a sub-folder?
    if is_dir(APPPATH + 'controllers/' + $segments[0])

      # Set the directory and remove it from the segment array
      @set_directory $segments[0]
      $segments = $segments.shift()

      if $segments.length > 0

        # Does the requested controller exist in the sub-folder?
        if not file_exists(APPPATH + 'controllers/' + @fetch_directory() + $segments[0] + EXT)
          console.log "Unable to validate" + @fetch_directory() + $segments[0]
          return []

      else

        # Is the method being specified in the route?
        if @_default_controller.indexOf('/') isnt -1

          $x = @_default_controller.split('/')

          @set_class $x[0]
          @set_method $x[1]

        else

          @set_class @_default_controller
          @set_method 'index'

        # Does the default controller exist in the sub-folder?
        if not file_exists(APPPATH + 'controllers/' + @fetch_directory() + @_default_controller + EXT)
          @_directory = ''
          return []

      return $segments

    # If we've gotten this far it means that the URI does not correlate to a valid
    # controller class.  We will now see if there is an override
    if @_404_override isnt false

      $x = @_404_override.split('/')

      @set_class $x[0]
      @set_method $x[1] ? 'index'

      return $x


    # Nothing else to do at this point but show a 404
    console.log "Unable to validate" + $segments[0]
    return []

  # --------------------------------------------------------------------

  #
  # Set the class name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_class: ($class) ->
    @_class = $class.replace('/', '').replace('.', '')
  

  # --------------------------------------------------------------------

  #
  # Fetch the current class
  #
  # @access	public
  # @return	string
  #
  fetch_class: ->
    return @_class
  

  # --------------------------------------------------------------------

  #
  #  Set the method name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_method: ($method) ->
    @_method = $method


  # --------------------------------------------------------------------

  #
  #  Fetch the current method
  #
  # @access	public
  # @return	string
  #
  fetch_method: ->
    if @_method is @fetch_class()
      return 'index'

    return @_method

  # --------------------------------------------------------------------

  #
  #  Set the directory name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_directory: ($dir) ->
    @_directory = $dir.replace('/', '').replace('.', '') + '/'

  # --------------------------------------------------------------------

  #
  #  Fetch the sub-directory (if any) that contains the requested controller class
  #
  # @access	public
  # @return	string
  #
  fetch_directory: ->
    return @_directory

  #  --------------------------------------------------------------------

  #
  #  Set the controller overrides
  #
  # @access	public
  # @param	array
  # @return	null
  #
  _set_overrides : ($routing) ->
    if not is_array($routing)
      return


    if $routing['directory']?
      @set_directory($routing['directory'])


    if $routing['controller']?  and $routing['controller'] isnt ''
      @set_class($routing['controller'])


    if $routing['function']?
      $routing['function'] = if ($routing['function'] is '') then 'index' else $routing['function']
      @set_method($routing['function'])

# END CI_Router class

module.exports = CI_Router

# End of file Router.coffee
# Location: ./system/core/Router.coffee