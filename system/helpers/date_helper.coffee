#+--------------------------------------------------------------------+
#  date_helper.coffee
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
# Exspresso Date Helpers
#
# @package		Exspresso
# @subpackage	Helpers
# @category	Helpers
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/helpers/date_helper.html
#

#  ------------------------------------------------------------------------

#
# Get "now" time
#
# Returns time() or its GMT equivalent based on the config file preference
#
# @access	public
# @return	integer
#
if not function_exists('now')
  exports.now = now =  ->
    $CI = Exspresso
    
    if strtolower($CI.config.item('time_reference')) is 'gmt'
      $now = time()
      $system_time = mktime(gmdate("H", $now), gmdate("i", $now), gmdate("s", $now), gmdate("m", $now), gmdate("d", $now), gmdate("Y", $now))
      
      if strlen($system_time) < 10
        $system_time = time()
        log_message('error', 'The Date class could not set a proper GMT timestamp so the local time() value was used.')
        
      
      return $system_time
      
    else 
      return time()
      
    
  

#  ------------------------------------------------------------------------

#
# Convert MySQL Style Datecodes
#
# This function is identical to PHPs date() function,
# except that it allows date codes to be formatted using
# the MySQL style, where each code letter is preceded
# with a percent sign:  %Y %m %d etc...
#
# The benefit of doing dates this way is that you don't
# have to worry about escaping your text letters that
# match the date codes.
#
# @access	public
# @param	string
# @param	integer
# @return	integer
#
if not function_exists('mdate')
  exports.mdate = mdate = ($datestr = '', $time = '') ->
    if $datestr is '' then return ''
    if $time is '' then $time = now()
    $datestr = str_replace('%\\', '', preg_replace("/([a-z]+?){1}/i", "\\\\\\1", $datestr))
    return date($datestr, $time)

##  ------------------------------------------------------------------------#
# Standard Date
#
# Returns a date formatted according to the submitted standard.
#
# @access	public
# @param	string	the chosen format
# @param	integer	Unix timestamp
# @return	string
#
if not function_exists('standard_date')
  exports.standard_date = standard_date = ($fmt = 'DATE_RFC822', $time = '') ->
    $formats =
      'DATE_ATOM':'%Y-%m-%dT%H:%i:%s%Q',
      'DATE_COOKIE':'%l, %d-%M-%y %H:%i:%s UTC',
      'DATE_ISO8601':'%Y-%m-%dT%H:%i:%s%Q',
      'DATE_RFC822':'%D, %d %M %y %H:%i:%s %O',
      'DATE_RFC850':'%l, %d-%M-%y %H:%m:%i UTC',
      'DATE_RFC1036':'%D, %d %M %y %H:%i:%s %O',
      'DATE_RFC1123':'%D, %d %M %Y %H:%i:%s %O',
      'DATE_RSS':'%D, %d %M %Y %H:%i:%s %O',
      'DATE_W3C':'%Y-%m-%dT%H:%i:%s%Q'


    if not $formats[$fmt]?
      return false


    return mdate($formats[$fmt], $time)

##  ------------------------------------------------------------------------#
# Timespan
#
# Returns a span of seconds in this format:
#	10 days 14 hours 36 minutes 47 seconds
#
# @access	public
# @param	integer	a number of seconds
# @param	integer	Unix timestamp
# @return	integer
#
if not function_exists('timespan')
  exports.timespan = timespan = ($seconds = 1, $time = '') ->
    $CI = Exspresso
    $CI.lang.load('date')

    if not is_numeric($seconds)
      $seconds = 1


    if not is_numeric($time)
      $time = time()


    if $time<=$seconds
      $seconds = 1

    else
      $seconds = $time - $seconds


    $str = ''
    $years = floor($seconds / 31536000)

    if $years > 0
      $str+=$years + ' ' + $CI.lang.line((if ($years > 1) then 'date_years' else 'date_year')) + ', '


    $seconds-=$years * 31536000
    $months = floor($seconds / 2628000)

    if $years > 0 or $months > 0
      if $months > 0
        $str+=$months + ' ' + $CI.lang.line((if ($months > 1) then 'date_months' else 'date_month')) + ', '


      $seconds-=$months * 2628000


    $weeks = floor($seconds / 604800)

    if $years > 0 or $months > 0 or $weeks > 0
      if $weeks > 0
        $str+=$weeks + ' ' + $CI.lang.line((if ($weeks > 1) then 'date_weeks' else 'date_week')) + ', '


      $seconds-=$weeks * 604800


    $days = floor($seconds / 86400)

    if $months > 0 or $weeks > 0 or $days > 0
      if $days > 0
        $str+=$days + ' ' + $CI.lang.line((if ($days > 1) then 'date_days' else 'date_day')) + ', '


      $seconds-=$days * 86400


    $hours = floor($seconds / 3600)

    if $days > 0 or $hours > 0
      if $hours > 0
        $str+=$hours + ' ' + $CI.lang.line((if ($hours > 1) then 'date_hours' else 'date_hour')) + ', '


      $seconds-=$hours * 3600


    $minutes = floor($seconds / 60)

    if $days > 0 or $hours > 0 or $minutes > 0
      if $minutes > 0
        $str+=$minutes + ' ' + $CI.lang.line((if ($minutes > 1) then 'date_minutes' else 'date_minute')) + ', '


      $seconds-=$minutes * 60


    if $str is ''
      $str+=$seconds + ' ' + $CI.lang.line((if ($seconds > 1) then 'date_seconds' else 'date_second')) + ', '


    return substr(trim($str), 0,  - 1)

##  ------------------------------------------------------------------------#
# Number of days in a month
#
# Takes a month/year as input and returns the number of days
# for the given month/year. Takes leap years into consideration.
#
# @access	public
# @param	integer a numeric month
# @param	integer	a numeric year
# @return	integer
#
if not function_exists('days_in_month')
  exports.days_in_month = days_in_month = ($month = 0, $year = '') ->
    if $month < 1 or $month > 12
      return 0


    if not is_numeric($year) or strlen($year) isnt 4
      $year = date('Y')


    if $month is 2
      if $year400 is 0 or ($year4 is 0 and $year100 isnt 0)
        return 29



    $days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    return $days_in_month[$month - 1]

##  ------------------------------------------------------------------------#
# Converts a local Unix timestamp to GMT
#
# @access	public
# @param	integer Unix timestamp
# @return	integer
#
if not function_exists('local_to_gmt')
  exports.local_to_gmt = local_to_gmt = ($time = '') ->
    if $time is '' then $time = time()
    return mktime(gmdate("H", $time), gmdate("i", $time), gmdate("s", $time), gmdate("m", $time), gmdate("d", $time), gmdate("Y", $time))


##  ------------------------------------------------------------------------#
# Converts GMT time to a localized value
#
# Takes a Unix timestamp (in GMT) as input, and returns
# at the local value based on the timezone and DST setting
# submitted
#
# @access	public
# @param	integer Unix timestamp
# @param	string	timezone
# @param	bool	whether DST is active
# @return	integer
#
if not function_exists('gmt_to_local')
  exports.gmt_to_local = gmt_to_local = ($time = '', $timezone = 'UTC', $dst = false) ->
    if $time is ''
      return now()


    $time+=timezones($timezone) * 3600

    if $dst is true
      $time+=3600


    return $time

##  ------------------------------------------------------------------------#
# Converts a MySQL Timestamp to Unix
#
# @access	public
# @param	integer Unix timestamp
# @return	integer
#
if not function_exists('mysql_to_unix')
  exports.mysql_to_unix = mysql_to_unix = ($time = '') ->
    #  We'll remove certain characters for backward compatibility
    #  since the formatting changed with MySQL 4.1
    #  YYYY-MM-DD HH:MM:SS

    $time = str_replace('-', '', $time)
    $time = str_replace(':', '', $time)
    $time = str_replace(' ', '', $time)

    #  YYYYMMDDHHMMSS
    return mktime(substr($time, 8, 2), substr($time, 10, 2), substr($time, 12, 2), substr($time, 4, 2), substr($time, 6, 2), substr($time, 0, 4))

##  ------------------------------------------------------------------------#
# Unix to "Human"
#
# Formats Unix timestamp to the following prototype: 2006-08-21 11:35 PM
#
# @access	public
# @param	integer Unix timestamp
# @param	bool	whether to show seconds
# @param	string	format: us or euro
# @return	string
#
if not function_exists('unix_to_human')
  exports.unix_to_human = unix_to_human = ($time = '', $seconds = false, $fmt = 'us') ->
    $r = date('Y', $time) + '-' + date('m', $time) + '-' + date('d', $time) + ' '

    if $fmt is 'us'
      $r+=date('h', $time) + ':' + date('i', $time)

    else
      $r+=date('H', $time) + ':' + date('i', $time)


    if $seconds
      $r+=':' + date('s', $time)


    if $fmt is 'us'
      $r+=' ' + date('A', $time)


    return $r

##  ------------------------------------------------------------------------#
# Convert "human" date to GMT
#
# Reverses the above process
#
# @access	public
# @param	string	format: us or euro
# @return	integer
#
if not function_exists('human_to_unix')
  exports.human_to_unix = human_to_unix = ($datestr = '') ->
    if $datestr is ''
      return false


    $datestr = trim($datestr)
    $datestr = preg_replace("/\h20+/", ' ', $datestr)

    if not preg_match('/^[0-9]{2,4}\-[0-9]{1,2}\-[0-9]{1,2}\s[0-9]{1,2}:[0-9]{1,2}(?::[0-9]{1,2})?(?:\s[AP]M)?$/i', $datestr)
      return false


    $split = explode(' ', $datestr)

    $ex = explode("-", $split['0'])

    $year = if (strlen($ex['0']) is 2) then '20' + $ex['0'] else $ex['0']
    $month = if (strlen($ex['1']) is 1) then '0' + $ex['1'] else $ex['1']
    $day = if (strlen($ex['2']) is 1) then '0' + $ex['2'] else $ex['2']

    $ex = explode(":", $split['1'])

    $hour = if (strlen($ex['0']) is 1) then '0' + $ex['0'] else $ex['0']
    $min = if (strlen($ex['1']) is 1) then '0' + $ex['1'] else $ex['1']

    if $ex['2']?  and preg_match('/[0-9]{1,2}/', $ex['2'])
      $sec = if (strlen($ex['2']) is 1) then '0' + $ex['2'] else $ex['2']

    else
      #  Unless specified, seconds get set to zero.
      $sec = '00'


    if $split['2']?
      $ampm = strtolower($split['2'])

      if substr($ampm, 0, 1) is 'p' and $hour < 12 then $hour = $hour + 12
      if substr($ampm, 0, 1) is 'a' and $hour is 12 then $hour = '00'
      if strlen($hour) is 1 then $hour = '0' + $hour

    return mktime($hour, $min, $sec, $month, $day, $year)

# Timezone Menu
#
# Generates a drop-down menu of timezones.
#
# @access	public
# @param	string	timezone
# @param	string	classname
# @param	string	menu name
# @return	string
#
if not function_exists('timezone_menu')
  exports.timezone_menu = timezone_menu = ($default = 'UTC', $class = "", $name = 'timezones') ->
    $CI = Exspresso
    $CI.lang.load('date')

    if $default is 'GMT' then $default = 'UTC'
    $menu = '<select name="' + $name + '"'
    if $class isnt ''
      $menu+=' class="' + $class + '"'
    $menu+=">\n"

    for $key, $val of timezones()
      $selected = if ($default is $key) then " selected='selected'" else ''
      $menu+="<option value='{$key}'{$selected}>" + $CI.lang.line($key) + "</option>\n"


    $menu+="</select>"

    return $menu

##  ------------------------------------------------------------------------#
# Timezones
#
# Returns an array of timezones.  This is a helper function
# for various other ones in this library
#
# @access	public
# @param	string	timezone
# @return	string
#
if not function_exists('timezones')
  exports.timezones = timezones = ($tz = '') ->
    #  Note: Don't change the order of these even though
    #  some items appear to be in the wrong order

    $zones =
      'UM12': - 12,
      'UM11': - 11,
      'UM10': - 10,
      'UM95': - 9.5,
      'UM9': - 9,
      'UM8': - 8,
      'UM7': - 7,
      'UM6': - 6,
      'UM5': - 5,
      'UM45': - 4.5,
      'UM4': - 4,
      'UM35': - 3.5,
      'UM3': - 3,
      'UM2': - 2,
      'UM1': - 1,
      'UTC':0,
      'UP1': + 1,
      'UP2': + 2,
      'UP3': + 3,
      'UP35': + 3.5,
      'UP4': + 4,
      'UP45': + 4.5,
      'UP5': + 5,
      'UP55': + 5.5,
      'UP575': + 5.75,
      'UP6': + 6,
      'UP65': + 6.5,
      'UP7': + 7,
      'UP8': + 8,
      'UP875': + 8.75,
      'UP9': + 9,
      'UP95': + 9.5,
      'UP10': + 10,
      'UP105': + 10.5,
      'UP11': + 11,
      'UP115': + 11.5,
      'UP12': + 12,
      'UP1275': + 12.75,
      'UP13': + 13,
      'UP14': + 14


    if $tz is ''
      return $zones


    if $tz is 'GMT' then $tz = 'UTC'
    return if not $zones[$tz]?  then 0 else $zones[$tz]

    #  End of file date_helper.php
    #  Location: ./system/helpers/date_helper.php
