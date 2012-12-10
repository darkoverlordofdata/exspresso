#+--------------------------------------------------------------------+
#| Breadcrumb.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#  Breadcrumb - Main application
#
#
#
class global.Breadcrumb

  _output: ''
  _crumbs: null
  _location: ''

  _path_sep:     '>'
  _left_outer:   '<ul id="breadcrumb">'
  _right_outer:  '</ul>'
  _left_inner:   '<li>'
  _right_inner:  '</li>'
  _left_inner_active: '<li>'

  #
  # Constructor
  #
  constructor: ($config, @CI) ->

    log_message('debug', "Breadcrumb Class Initialized")

    @["_#{$key}"] = $val for $key, $val of $config

    if @CI.session.userdata('breadcrumb') isnt null 
      @_crumbs = @CI.session.userdata('breadcrumb')
    else
      @_crumbs = []

  #
  # Add a crumb to the trail:
  # @param $label - The string to display
  # @param $url - The url underlying the label
  # @param $level - The level of this link.
  #
  #
  add: ($label, $url = '', $level = 0) ->

    $crumb = {}
    $crumb['label'] = $label
    $crumb['url'] = base_url($url)

    if $crumb['label'] isnt null and $crumb['url'] isnt null and isset($level)

      while count(@crumbs) > $level

        @_crumbs.pop() # prune until we reach the $level we've allocated to this page

      if not isset(@_crumbs[0]) and $level > 0 # If there's no session data yet, assume a homepage link

        @_crumbs[0]['url'] = base_url()
        @_crumbs[0]['label'] = "Home"


      @_crumbs[$level] = $crumb

    @CI.session.set_userdata('breadcrumb', @_crumbs) # Persist the data
    @_crumbs[$level]['url'] = null # Ditch the underlying url for the current page.

   #
   # Output a semantic list of links.  See above for sample CSS.  Modify this to suit your design.
   #
  output: ->

    $bc = @_left_outer
    $sep = ''
    for $crumb in @_crumbs

      if $crumb['url'] isnt null

        $bc+= @_left_inner+$sep+'<a href="'+$crumb['url']+'" title="'+$crumb['label']+'">'+$crumb['label']+'</a>'+@_right_inner+' '

      else

        $bc+= @_left_inner_active+$sep+$crumb['label']+@_right_inner+' '

      $sep = @_path_sep

    $bc+= @_right_outer
    return $bc

# End of file Breadcrumb.coffee
# Location: .application/libraries/Breadcrumb.coffee