#+--------------------------------------------------------------------+
#  Calendar.coffee
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
# CodeIgniter Calendar Class
#
# This class enables the creation of calendars
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Libraries
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/calendar.html
#
class CI_Calendar
  
  CI: null
  lang: {}
  local_time: {}
  template: ''
  start_day: 'sunday'
  month_type: 'long'
  day_type: 'abr'
  show_next_prev: false
  next_prev_url: ''
  
  #
  # Constructor
  #
  # Loads the calendar language file and sets the default time reference
  #
  constructor: ($config = {}, @CI) ->

    if not in_array('calendar_lang' + EXT, @CI.lang.is_loaded, true)
      @CI.lang.load('calendar')

    @local_time = time()

    if count($config) > 0
      @initialize($config)

    log_message('debug', "Calendar Class Initialized")

  #  --------------------------------------------------------------------
  
  #
  # Initialize the user preferences
  #
  # Accepts an associative array as input, containing display preferences
  #
  # @access	public
  # @param	array	config preferences
  # @return	void
  #
  initialize : ($config = {}) ->
    for $key, $val of $config
      if @$key? 
        @$key = $val

  #  --------------------------------------------------------------------
  
  #
  # Generate the calendar
  #
  # @access	public
  # @param	integer	the year
  # @param	integer	the month
  # @param	array	the data to be shown in the calendar cells
  # @return	string
  #
  generate : ($year = '', $month = '', $data = {}) ->
    #  Set and validate the supplied month/year
    if $year is '' then $year = date("Y", @local_time)
    if $month is '' then $month = date("m", @local_time)
    if strlen($year) is 1 then $year = '200' + $year
    if strlen($year) is 2 then $year = '20' + $year
    if strlen($month) is 1 then $month = '0' + $month
    $adjusted_date = @adjust_date($month, $year)
    $month = $adjusted_date['month']
    $year = $adjusted_date['year']

    #  Determine the total days in the month
    $total_days = @get_total_days($month, $year)

    #  Set the starting day of the week
    $start_days = 'sunday':0, 'monday':1, 'tuesday':2, 'wednesday':3, 'thursday':4, 'friday':5, 'saturday':6
    $start_day = if ( not $start_days[@start_day]? ) then 0 else $start_days[@start_day]

    #  Set the starting day number
    $local_date = mktime(12, 0, 0, $month, 1, $year)
    $date = getdate($local_date)
    $day = $start_day + 1 - $date["wday"]

    while $day > 1
      $day-=7

    #  Set the current month/year/day
    #  We use this to determine the "today" date
    $cur_year = date("Y", @local_time)
    $cur_month = date("m", @local_time)
    $cur_day = date("j", @local_time)
    $is_current_month = if ($cur_year is $year and $cur_month is $month) then true else false

    #  Generate the template data array
    @parse_template()
    $out = @temp['table_open']
    $out+="\n"
    #  Begin building the calendar output
    $out+="\n"
    $out+=@temp['heading_row_start']
    $out+="\n"
    
    #  "previous" month link
    if @show_next_prev is true
      #  Add a trailing slash to the  URL if needed
      @next_prev_url = preg_replace("/(.+?)\/*$/", "\\1/", @next_prev_url)
      
      $adjusted_date = @adjust_date($month - 1, $year)
      $out+=str_replace('{previous_url}', @next_prev_url + $adjusted_date['year'] + '/' + $adjusted_date['month'], @temp['heading_previous_cell'])
      $out+="\n"
      
    
    #  Heading containing the month/year
    $colspan = if (@show_next_prev is true) then 5 else 7
    
    @temp['heading_title_cell'] = str_replace('{colspan}', $colspan, @temp['heading_title_cell'])
    @temp['heading_title_cell'] = str_replace('{heading}', @get_month_name($month) + "&nbsp;" + $year, @temp['heading_title_cell'])
    
    $out+=@temp['heading_title_cell']
    $out+="\n"
    
    #  "next" month link
    if @show_next_prev is true
      $adjusted_date = @adjust_date($month + 1, $year)
      $out+=str_replace('{next_url}', @next_prev_url + $adjusted_date['year'] + '/' + $adjusted_date['month'], @temp['heading_next_cell'])
      
    
    $out+="\n"
    $out+=@temp['heading_row_end']
    $out+="\n"
    
    #  Write the cells containing the days of the week
    $out+="\n"
    $out+=@temp['week_row_start']
    $out+="\n"
    
    $day_names = @get_day_names()
    
    for $i in [0...7]
      $out+=str_replace('{week_day}', $day_names[($start_day + $i) % 7], @temp['week_day_cell'])

    $out+="\n"
    $out+=@temp['week_row_end']
    $out+="\n"
    
    #  Build the main body of the calendar
    while $day<=$total_days
      $out+="\n"
      $out+=@temp['cal_row_start']
      $out+="\n"

      for $i in [0...7]

        $out+= if ($is_current_month is true and $day is $cur_day) then @temp['cal_cell_start_today'] else @temp['cal_cell_start']

        if $day > 0 and $day<=$total_days
          if $data[$day]?
            #  Cells with content
            $temp = if ($is_current_month is true and $day is $cur_day) then @temp['cal_cell_content_today'] else @temp['cal_cell_content']
            $out+=str_replace('{day}', $day, str_replace('{content}', $data[$day], $temp))

          else
            #  Cells with no content
            $temp = if ($is_current_month is true and $day is $cur_day) then @temp['cal_cell_no_content_today'] else @temp['cal_cell_no_content']
            $out+=str_replace('{day}', $day, $temp)


        else
          #  Blank cells
          $out+=@temp['cal_cell_blank']

        $out+= if ($is_current_month is true and $day is $cur_day) then @temp['cal_cell_end_today'] else @temp['cal_cell_end']
        $day++

      $out+="\n"
      $out+=@temp['cal_row_end']
      $out+="\n"

    $out+="\n"
    $out+=@temp['table_close']
    
    return $out
    
  
  #  --------------------------------------------------------------------
  
  #
  # Get Month Name
  #
  # Generates a textual month name based on the numeric
  # month provided.
  #
  # @access	public
  # @param	integer	the month
  # @return	string
  #
  get_month_name : ($month) ->
    if @month_type is 'short'
      $month_names =
        '01':'cal_jan'
        '02':'cal_feb'
        '03':'cal_mar'
        '04':'cal_apr'
        '05':'cal_may'
        '06':'cal_jun'
        '07':'cal_jul'
        '08':'cal_aug'
        '09':'cal_sep'
        '10':'cal_oct'
        '11':'cal_nov'
        '12':'cal_dec'
      
    else 
      $month_names =
        '01':'cal_january'
        '02':'cal_february'
        '03':'cal_march'
        '04':'cal_april'
        '05':'cal_mayl'
        '06':'cal_june'
        '07':'cal_july'
        '08':'cal_august'
        '09':'cal_september'
        '10':'cal_october'
        '11':'cal_november'
        '12':'cal_december'
      
    $month = $month_names[$month]
    
    if @CI.lang.line($month) is false
      return ucfirst(str_replace('cal_', '', $month))

    return @CI.lang.line($month)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Get Day Names
  #
  # Returns an array of day names (Sunday, Monday, etc.) based
  # on the type.  Options: long, short, abrev
  #
  # @access	public
  # @param	string
  # @return	array
  #
  get_day_names: ($day_type = '') ->

    if $day_type isnt ''
      @day_type = $day_type

    if @day_type is 'long'
      $day_names = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
    else if @day_type is 'short'
      $day_names = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
    else
      $day_names = ['su', 'mo', 'tu', 'we', 'th', 'fr', 'sa']

    $days = {}
    for $val in $day_names
      $days.push if (@CI.lang.line('cal_' + $val) is false) then ucfirst($val) else @CI.lang.line('cal_' + $val)
    return $days

  # --------------------------------------------------------------------

  #
  # Adjust Date
  #
  # This function makes sure that we have a valid month/year.
  # For example, if you submit 13 as the month, the year will
  # increment and the month will become January.
  #
  # @access	public
  # @param	integer	the month
  # @param	integer	the year
  # @return	array
  #
  adjust_date : ($month, $year) ->

    $date = {}

    $date['month'] = $month
    $date['year'] = $year

    while $date['month'] > 12
      $date['month']-=12
      $date['year']++

    while $date['month']<=0
      $date['month']+=12
      $date['year']--

    if strlen($date['month']) is 1
      $date['month'] = '0' + $date['month']

    return $date

  # --------------------------------------------------------------------

  #
  # Total days in a given month
  #
  # @access	public
  # @param	integer	the month
  # @param	integer	the year
  # @return	integer
  #
  get_total_days : ($month, $year) ->
    $days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    if $month < 1 or $month > 12
      return 0

    #  Is the year a leap year?
    if $month is 2
      if $year400 is 0 or ($year4 is 0 and $year100 isnt 0)
        return 29

    return $days_in_month[$month - 1]


  # --------------------------------------------------------------------

  #
  # Set Default Template Data
  #
  # This is used in the event that the user has not created their own template
  #
  # @access	public
  # @return array
  #
  default_template :  ->
    'table_open':'<table border="0" cellpadding="4" cellspacing="0">'
    'heading_row_start':'<tr>'
    'heading_previous_cell':'<th><a href="{previous_url}">&lt;&lt;</a></th>'
    'heading_title_cell':'<th colspan="{colspan}">{heading}</th>'
    'heading_next_cell':'<th><a href="{next_url}">&gt;&gt;</a></th>'
    'heading_row_end':'</tr>'
    'week_row_start':'<tr>'
    'week_day_cell':'<td>{week_day}</td>'
    'week_row_end':'</tr>'
    'cal_row_start':'<tr>'
    'cal_cell_start':'<td>'
    'cal_cell_start_today':'<td>'
    'cal_cell_content':'<a href="{content}">{day}</a>'
    'cal_cell_content_today':'<a href="{content}"><strong>{day}</strong></a>'
    'cal_cell_no_content':'{day}'
    'cal_cell_no_content_today':'<strong>{day}</strong>'
    'cal_cell_blank':'&nbsp;'
    'cal_cell_end':'</td>'
    'cal_cell_end_today':'</td>'
    'cal_row_end':'</tr>'
    'table_close':'</table>'

  ##  --------------------------------------------------------------------#
  # Parse Template
  #
  # Harvests the data within the template {pseudo-variables}
  # used to display the calendar
  #
  # @access	public
  # @return	void
  parse_template :  ->
    @temp = @default_template()

    if @template is ''
      return

    $today = ['cal_cell_start_today', 'cal_cell_content_today', 'cal_cell_no_content_today', 'cal_cell_end_today']

    for $val in ['table_open', 'table_close', 'heading_row_start', 'heading_previous_cell', 'heading_title_cell', 'heading_next_cell', 'heading_row_end', 'week_row_start', 'week_day_cell', 'week_row_end', 'cal_row_start', 'cal_cell_start', 'cal_cell_content', 'cal_cell_no_content', 'cal_cell_blank', 'cal_cell_end', 'cal_row_end', 'cal_cell_start_today', 'cal_cell_content_today', 'cal_cell_no_content_today', 'cal_cell_end_today']
      if preg_match("/\{" + $val + "\}(.*?)\{\/" + $val + "\}/si", @template, $match)
        @temp[$val] = $match['1']

      else
        if in_array($val, $today, true)
          @temp[$val] = @temp[str_replace('_today', '', $val)]

##  END CI_Calendar class

module.exports = CI_Calendar

#  End of file Calendar.php
#  Location: ./system/libraries/Calendar.php
