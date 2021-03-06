#+--------------------------------------------------------------------+
#  Calendar.coffee
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
# Exspresso Calendar Class
#
# This class enables the creation of calendars
#
#
module.exports = class system.lib.Calendar

  {ucfirst} = require(SYSPATH+'core.coffee')

  _local_time         : null
  _template           : ''
  _start_day          : 'sunday'
  _month_type         : 'long'
  _day_type           : 'abr'
  _show_next_prev     : false
  _next_prev_url      : ''
  
  #
  # Constructor
  #
  # Loads the calendar language file and sets the default time reference
  #
  constructor: ($controller, $config = {}) ->

    # Initialize the config preferences
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    #if not in_array('calendar_lang.coffee', @i18n.is_loaded, true)
    @i18n.load('calendar')

    @_local_time = time()

    log_message('debug', "Calendar Class Initialized")

  #
  # Generate the calendar
  #
  # @param  [Integer]  the year
  # @param  [Integer]  the month
  # @param  [Array]  the data to be shown in the calendar cells
  # @return	[String]
  #
  generate : ($year = '', $month = '', $data = {}) ->
    #  Set and validate the supplied month/year
    if $year is '' then $year = date("Y", @_local_time)
    if $month is '' then $month = date("m", @_local_time)
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
    $start_day = if ( not $start_days[@_start_day]? ) then 0 else $start_days[@_start_day]

    #  Set the starting day number
    $local_date = mktime(12, 0, 0, $month, 1, $year)
    $date = getdate($local_date)
    $day = $start_day + 1 - $date["wday"]

    while $day > 1
      $day-=7

    #  Set the current month/year/day
    #  We use this to determine the "today" date
    $cur_year = date("Y", @_local_time)
    $cur_month = date("m", @_local_time)
    $cur_day = date("j", @_local_time)
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
    if @_show_next_prev is true
      #  Add a trailing slash to the  URL if needed
      @_next_prev_url = @_next_prev_url.replace(/(.+?)\/*$/, "$1/")

      $adjusted_date = @adjust_date($month - 1, $year)
      $out+=str_replace('{previous_url}', @_next_prev_url + $adjusted_date['year'] + '/' + $adjusted_date['month'], @temp['heading_previous_cell'])
      $out+="\n"
      
    
    #  Heading containing the month/year
    $colspan = if (@_show_next_prev is true) then 5 else 7
    
    @temp['heading_title_cell'] = @temp['heading_title_cell'].replace('{colspan}', $colspan)
    @temp['heading_title_cell'] = @temp['heading_title_cell'].replace('{heading}', @get_month_name($month) + "&nbsp;" + $year)
    
    $out+=@temp['heading_title_cell']
    $out+="\n"
    
    #  "next" month link
    if @_show_next_prev is true
      $adjusted_date = @adjust_date($month + 1, $year)
      $out+=@temp['heading_next_cell'].replace('{next_url}', @_next_prev_url + $adjusted_date['year'] + '/' + $adjusted_date['month'])
      
    
    $out+="\n"
    $out+=@temp['heading_row_end']
    $out+="\n"
    
    #  Write the cells containing the days of the week
    $out+="\n"
    $out+=@temp['week_row_start']
    $out+="\n"
    
    $day_names = @get_day_names()
    
    for $i in [0...7]
      $out+=@temp['week_day_cell'].replace('{week_day}', $day_names[($start_day + $i) % 7])

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
            $out+=$temp.replace('{content}', $data[$day]).replace('{day}', $day)

          else
            #  Cells with no content
            $temp = if ($is_current_month is true and $day is $cur_day) then @temp['cal_cell_no_content_today'] else @temp['cal_cell_no_content']
            $out+=$temp.replace('{day}', $day)


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
    
  
  #
  # Get Month Name
  #
  # Generates a textual month name based on the numeric
  # month provided.
  #
  # @param  [Integer]  the month
  # @return	[String]
  #
  getMonthName : ($month) ->
    if @_month_type is 'short'
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
    
    if @i18n.line($month) is false
      return ucfirst(str_replace('cal_', '', $month))

    return @i18n.line($month)
    
  
  #
  # Get Day Names
  #
  # Returns an array of day names (Sunday, Monday, etc.) based
  # on the type.  Options: long, short, abrev
  #
    # @param  [String]    # @return	array
  #
  getDayNames: ($day_type = '') ->

    if $day_type isnt ''
      @_day_type = $day_type

    if @_day_type is 'long'
      $day_names = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
    else if @_day_type is 'short'
      $day_names = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
    else
      $day_names = ['su', 'mo', 'tu', 'we', 'th', 'fr', 'sa']

    $days = {}
    for $val in $day_names
      $days.push if (@i18n.line('cal_' + $val) is false) then ucfirst($val) else @i18n.line('cal_' + $val)
    return $days

  #
  # Adjust Date
  #
  # This function makes sure that we have a valid month/year.
  # For example, if you submit 13 as the month, the year will
  # increment and the month will become January.
  #
  # @param  [Integer]  the month
  # @param  [Integer]  the year
  # @return	array
  #
  adjustDate : ($month, $year) ->

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

  #
  # Total days in a given month
  #
  # @param  [Integer]  the month
  # @param  [Integer]  the year
  # @return	integer
  #
  getTotalDays : ($month, $year) ->
    $days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    if $month < 1 or $month > 12
      return 0

    #  Is the year a leap year?
    if $month is 2
      if $year400 is 0 or ($year4 is 0 and $year100 isnt 0)
        return 29

    return $days_in_month[$month - 1]


  #
  # Set Default Template Data
  #
  # This is used in the event that the user has not created their own template
  #
    # @return array
  #
  defaultTemplate :  ->
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

  #
  # Parse Template
  #
  # Harvests the data within the template {pseudo-variables}
  # used to display the calendar
  #
    # @return [Void]  parseTemplate :  ->
    @temp = @defaultTemplate()

    if @_template is ''
      return

    $today = ['cal_cell_start_today', 'cal_cell_content_today', 'cal_cell_no_content_today', 'cal_cell_end_today']

    for $val in ['table_open', 'table_close', 'heading_row_start', 'heading_previous_cell', 'heading_title_cell', 'heading_next_cell', 'heading_row_end', 'week_row_start', 'week_day_cell', 'week_row_end', 'cal_row_start', 'cal_cell_start', 'cal_cell_content', 'cal_cell_no_content', 'cal_cell_blank', 'cal_cell_end', 'cal_row_end', 'cal_cell_start_today', 'cal_cell_content_today', 'cal_cell_no_content_today', 'cal_cell_end_today']

      if ($match = RegExp("\\{" + $val + "\\}(.*?)\\{\\/" + $val + "\\}", "mgi").match(@_template))?
      #if preg_match("/\\{" + $val + "\\}(.*?)\\{\\/" + $val + "\\}/mgi", @_template, $match)?
        @temp[$val] = $match[1]

      else
        if $today.indexOf($val) isnt -1
          @temp[$val] = @temp[$val.replace('_today', '')]

