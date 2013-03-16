#+--------------------------------------------------------------------+
#  Pagination.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Pagination Class
#
#
class system.lib.Pagination

  ceil = Math.ceil
  floor = Math.floor

  _base_url                 : ''  #  The page we are linking to
  _prefix                   : ''  #  A custom prefix added to the path.
  _suffix                   : ''  #  A custom suffix added to the path.

  _total_rows               : ''  #  Total number of items (database results)
  _per_page                 : 10  #  Max number of items you want shown per page
  _num_links                : 2   #  Number of "digit" links to show before/after the currently viewed page
  _cur_page                 : 0   #  The current page being viewed
  _first_link               : '&lsaquo; First'
  _next_link                : '&gt;'
  _prev_link                : '&lt;'
  _last_link                : 'Last &rsaquo;'
  _uri_segment              : 3
  _full_tag_open            : ''
  _full_tag_close           : ''
  _first_tag_open           : ''
  _first_tag_close          : '&nbsp;'
  _first_url                : ''  #  Alternative URL for the First Page.
  _cur_tag_open             : '&nbsp;<strong>'
  _cur_tag_close            : '</strong>'
  _next_tag_open            : '&nbsp;'
  _next_tag_close           : '&nbsp;'
  _prev_tag_open            : '&nbsp;'
  _prev_tag_close           : ''
  _num_tag_open             : '&nbsp;'
  _num_tag_close            : ''
  _page_query_string        : false
  _query_string_segment     : 'per_page'
  _display_pages            : true
  _anchor_class             : ''
  
  #
  # Constructor
  #
    # @param  [Array]  initialization parameters
  #
  constructor: ($controller, $config = {}) ->

    # Initialize the config preferences
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    if @_anchor_class isnt ''
      @_anchor_class = 'class="' + @_anchor_class + '" '

    log_message('debug', "Pagination Class Initialized")

  #
  # Generate the pagination links
  #
    # @return	[String]
  #
  createLinks :  ->
    #  If our item count or per-page total is zero there is no need to continue.
    if @_total_rows is 0 or @_per_page is 0
      return ''

    #  Calculate the total number of pages
    $num_pages = ceil(@_total_rows / @_per_page)
    
    #  Is there only one page? Hm... nothing more to do here then.
    if $num_pages is 1
      return ''

    #  Determine the current page number.
    if @config.item('enable_query_strings') is true or @_page_query_string is true
      if @input.get(@_query_string_segment) isnt 0
        @_cur_page = @input.get(@_query_string_segment)
        
        #  Prep the current page - no funny business!
        @_cur_page = parseInt(@_cur_page, 10)
        
      
    else
      if @uri.segment(@_uri_segment) isnt 0
        @_cur_page = @uri.segment(@_uri_segment)
        
        #  Prep the current page - no funny business!
        @_cur_page = parseInt(@_cur_page, 10)
        

    @_num_links = parseInt(@_num_links)
    
    if @_num_links < 1
      show_error('Your number of links must be a positive number.')
      
    
    if not is_numeric(@_cur_page)
      @_cur_page = 0
      
    
    #  Is the page number beyond the result range?
    #  If so we show the last page
    if @_cur_page > @_total_rows
      @_cur_page = ($num_pages - 1) * @_per_page
      
    
    $uri_page_number = @_cur_page
    @_cur_page = floor((@_cur_page / @_per_page) + 1)
    log_message 'debug', 'cur_page = %s', @_cur_page

    #  Calculate the start and end numbers. These determine
    #  which number to start and end the digit links with
    $start = if ((@_cur_page - @_num_links) > 0) then @_cur_page - (@_num_links - 1) else 1
    $end = if ((@_cur_page + @_num_links) < $num_pages) then @_cur_page + @_num_links else $num_pages
    
    #  Is pagination being used over GET or POST?  If get, add a per_page query
    #  string. If post, add a trailing slash to the base URL if needed
    if @config.item('enable_query_strings') is true or @_page_query_string is true
      @_base_url = rtrim(@_base_url) + '&amp;' + @_query_string_segment + '='
      
    else 
      @_base_url = rtrim(@_base_url, '/') + '/'
      
    
    #  And here we go...
    $output = ''
    
    #  Render the "First" link
    if @_first_link isnt false and @_cur_page > (@_num_links + 1)
      $first_url = if (@_first_url is '') then @_base_url else @_first_url
      $output+=@_first_tag_open + '<a ' + @_anchor_class + 'href="' + $first_url + '">' + @_first_link + '</a>' + @_first_tag_close
      
    
    #  Render the "previous" link
    if @_prev_link isnt false and @_cur_page isnt 1
      $i = $uri_page_number - @_per_page
      
      if $i is 0 and @_first_url isnt ''
        $output+=@_prev_tag_open + '<a ' + @_anchor_class + 'href="' + @_first_url + '">' + @_prev_link + '</a>' + @_prev_tag_close
        
      else 
        $i = if ($i is 0) then '' else @_prefix + $i + @_suffix
        $output+=@_prev_tag_open + '<a ' + @_anchor_class + 'href="' + @_base_url + $i + '">' + @_prev_link + '</a>' + @_prev_tag_close
        
      
      
    
    #  Render the pages
    if @_display_pages isnt false
      #  Write the digit links
      for $loop in [$start - 1..$end]
        $i = ($loop * @_per_page) - @_per_page

        if $i>=0
          if @_cur_page is $loop
            $output+=@_cur_tag_open + $loop + @_cur_tag_close#  Current page

          else
            $n = if ($i is 0) then '' else $i

            if $n is '' and @_first_url isnt ''
              $output+=@_num_tag_open + '<a ' + @_anchor_class + 'href="' + @_first_url + '">' + $loop + '</a>' + @_num_tag_close

            else
              $n = if ($n is '') then '' else @_prefix + $n + @_suffix

              $output+=@_num_tag_open + '<a ' + @_anchor_class + 'href="' + @_base_url + $n + '">' + $loop + '</a>' + @_num_tag_close
            

    #  Render the "next" link
    if @_next_link isnt false and @_cur_page < $num_pages
      $output+=@_next_tag_open + '<a ' + @_anchor_class + 'href="' + @_base_url + @_prefix + (@_cur_page * @_per_page) + @_suffix + '">' + @_next_link + '</a>' + @_next_tag_close
      
    
    #  Render the "Last" link
    if @_last_link isnt false and (@_cur_page + @_num_links) < $num_pages
      $i = (($num_pages * @_per_page) - @_per_page)
      $output+=@_last_tag_open + '<a ' + @_anchor_class + 'href="' + @_base_url + @_prefix + $i + @_suffix + '">' + @_last_link + '</a>' + @_last_tag_close
      
    
    #  Kill double slashes.  Note: Sometimes we can end up with a double slash
    #  in the penultimate link so we'll kill all double slashes.
    #$output = preg_replace("#([^:])//+#", "$1/", $output)
    $output = $output.replace(/([^:])\/\/+/gm, "$1/")

    #  Add the wrapper HTML if exists
    $output = @_full_tag_open + $output + @_full_tag_close
    
    return $output
    
module.exports = system.lib.Pagination
#  END Pagination Class

#  End of file Pagination.coffee
#  Location: .system/lib/Pagination.coffee