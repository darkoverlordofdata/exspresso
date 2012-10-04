#+--------------------------------------------------------------------+
#  Pagination.coffee
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
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{__construct, ceil, config, count, defined, floor, get, get_instance, input, is_numeric, item, preg_replace, rtrim, segment, uri}  = require(FCPATH + 'pal')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Pagination Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Pagination
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/pagination.html
#
class CI_Pagination
  
  base_url: ''#  The page we are linking to
  prefix: ''#  A custom prefix added to the path.
  suffix: ''#  A custom suffix added to the path.
  
  total_rows: ''#  Total number of items (database results)
  per_page: 10#  Max number of items you want shown per page
  num_links: 2#  Number of "digit" links to show before/after the currently viewed page
  cur_page: 0#  The current page being viewed
  first_link: '&lsaquo; First'
  next_link: '&gt;'
  prev_link: '&lt;'
  last_link: 'Last &rsaquo;'
  uri_segment: 3
  full_tag_open: ''
  full_tag_close: ''
  first_tag_open: ''
  first_tag_close: '&nbsp;'
  last_tag_open: '&nbsp;'
  last_tag_close: ''
  first_url: ''#  Alternative URL for the First Page.
  cur_tag_open: '&nbsp;<strong>'
  cur_tag_close: '</strong>'
  next_tag_open: '&nbsp;'
  next_tag_close: '&nbsp;'
  prev_tag_open: '&nbsp;'
  prev_tag_close: ''
  num_tag_open: '&nbsp;'
  num_tag_close: ''
  page_query_string: false
  query_string_segment: 'per_page'
  display_pages: true
  anchor_class: ''
  
  #
  # Constructor
  #
  # @access	public
  # @param	array	initialization parameters
  #
  __construct($params = {})
  {
  if count($params) > 0
    @initialize($params)
    
  
  if @anchor_class isnt ''
    @anchor_class = 'class="' + @anchor_class + '" '
    
  
  log_message('debug', "Pagination Class Initialized")
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Initialize Preferences
  #
  # @access	public
  # @param	array	initialization parameters
  # @return	void
  #
  initialize : ($params = {}) ->
    if count($params) > 0
      for $key, $val of $params
        if @$key? 
          @$key = $val
          
        
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Generate the pagination links
  #
  # @access	public
  # @return	string
  #
  create_links :  ->
    #  If our item count or per-page total is zero there is no need to continue.
    if @total_rows is 0 or @per_page is 0
      return ''
      
    
    #  Calculate the total number of pages
    $num_pages = ceil(@total_rows / @per_page)
    
    #  Is there only one page? Hm... nothing more to do here then.
    if $num_pages is 1
      return ''
      
    
    #  Determine the current page number.
    $CI = get_instance()
    
    if $CI.config.item('enable_query_strings') is true or @page_query_string is true
      if $CI.input.get(@query_string_segment) isnt 0
        @cur_page = $CI.input.get(@query_string_segment)
        
        #  Prep the current page - no funny business!
        @cur_page = @cur_page
        
      
    else 
      if $CI.uri.segment(@uri_segment) isnt 0
        @cur_page = $CI.uri.segment(@uri_segment)
        
        #  Prep the current page - no funny business!
        @cur_page = @cur_page
        
      
    
    @num_links = @num_links
    
    if @num_links < 1
      show_error('Your number of links must be a positive number.')
      
    
    if not is_numeric(@cur_page)
      @cur_page = 0
      
    
    #  Is the page number beyond the result range?
    #  If so we show the last page
    if @cur_page > @total_rows
      @cur_page = ($num_pages - 1) * @per_page
      
    
    $uri_page_number = @cur_page
    @cur_page = floor((@cur_page / @per_page) + 1)
    
    #  Calculate the start and end numbers. These determine
    #  which number to start and end the digit links with
    $start = if ((@cur_page - @num_links) > 0) then @cur_page - (@num_links - 1) else 1
    $end = if ((@cur_page + @num_links) < $num_pages) then @cur_page + @num_links else $num_pages
    
    #  Is pagination being used over GET or POST?  If get, add a per_page query
    #  string. If post, add a trailing slash to the base URL if needed
    if $CI.config.item('enable_query_strings') is true or @page_query_string is true
      @base_url = rtrim(@base_url) + '&amp;' + @query_string_segment + '='
      
    else 
      @base_url = rtrim(@base_url, '/') + '/'
      
    
    #  And here we go...
    $output = ''
    
    #  Render the "First" link
    if @first_link isnt false and @cur_page > (@num_links + 1)
      $first_url = if (@first_url is '') then @base_url else @first_url
      $output+=@first_tag_open + '<a ' + @anchor_class + 'href="' + $first_url + '">' + @first_link + '</a>' + @first_tag_close
      
    
    #  Render the "previous" link
    if @prev_link isnt false and @cur_page isnt 1
      $i = $uri_page_number - @per_page
      
      if $i is 0 and @first_url isnt ''
        $output+=@prev_tag_open + '<a ' + @anchor_class + 'href="' + @first_url + '">' + @prev_link + '</a>' + @prev_tag_close
        
      else 
        $i = if ($i is 0) then '' else @prefix + $i + @suffix
        $output+=@prev_tag_open + '<a ' + @anchor_class + 'href="' + @base_url + $i + '">' + @prev_link + '</a>' + @prev_tag_close
        
      
      
    
    #  Render the pages
    if @display_pages isnt false
      #  Write the digit links
      for ($loop = $start - 1$loop<=$end$loop++)
      {
      $i = ($loop * @per_page) - @per_page
      
      if $i>=0
        if @cur_page is $loop
          $output+=@cur_tag_open + $loop + @cur_tag_close#  Current page
          
        else 
          $n = if ($i is 0) then '' else $i
          
          if $n is '' and @first_url isnt ''
            $output+=@num_tag_open + '<a ' + @anchor_class + 'href="' + @first_url + '">' + $loop + '</a>' + @num_tag_close
            
          else 
            $n = if ($n is '') then '' else @prefix + $n + @suffix
            
            $output+=@num_tag_open + '<a ' + @anchor_class + 'href="' + @base_url + $n + '">' + $loop + '</a>' + @num_tag_close
            
          
        
      }
      
    
    #  Render the "next" link
    if @next_link isnt false and @cur_page < $num_pages
      $output+=@next_tag_open + '<a ' + @anchor_class + 'href="' + @base_url + @prefix + (@cur_page * @per_page) + @suffix + '">' + @next_link + '</a>' + @next_tag_close
      
    
    #  Render the "Last" link
    if @last_link isnt false and (@cur_page + @num_links) < $num_pages
      $i = (($num_pages * @per_page) - @per_page)
      $output+=@last_tag_open + '<a ' + @anchor_class + 'href="' + @base_url + @prefix + $i + @suffix + '">' + @last_link + '</a>' + @last_tag_close
      
    
    #  Kill double slashes.  Note: Sometimes we can end up with a double slash
    #  in the penultimate link so we'll kill all double slashes.
    $output = preg_replace("#([^:])//+#", "\\1/", $output)
    
    #  Add the wrapper HTML if exists
    $output = @full_tag_open + $output + @full_tag_close
    
    return $output
    
  

register_class 'CI_Pagination', CI_Pagination
module.exports = CI_Pagination
#  END Pagination Class

#  End of file Pagination.php 
#  Location: ./system/libraries/Pagination.php 