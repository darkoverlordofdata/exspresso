#+--------------------------------------------------------------------+
#  date_helper.coffee
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
# Exspresso Date Helpers
#
#
moment = require('moment')

exports.date = date = ($format, $timestamp = Date.now()) ->
  moment($timestamp).format($format)

#
# Get "now" time
#
# Returns time() or its GMT equivalent based on the config file preference
#
# @return	integer
#
exports.now = now =  ->
  Date.now()

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
# @param  [String]
# @param  [Integer]
# @return	[Integer]
#
exports.mdate = mdate = ($datestr = '', $time = now()) ->
  if $datestr is '' then return ''

  $datestr = $datestr.replace(/([a-z]+?){1}/ig, '\\$1').replace(/\%\\/g, '').replace(/\\/g, '')
  date($datestr, $time)

# Standard Date
#
# Returns a date formatted according to the submitted standard.
#
# @param  [String]  the chosen format
# @param  [Integer]  Unix timestamp
# @return	[String]
#
exports.standard_date = standard_date = ($fmt = 'DATE_RFC822', $time = '') ->
  $formats =
    DATE_ATOM     :'%Y-%m-%dT%H:%i:%s%Q'
    DATE_COOKIE   :'%l, %d-%M-%y %H:%i:%s UTC'
    DATE_ISO8601  :'%Y-%m-%dT%H:%i:%s%Q'
    DATE_RFC822   :'%D, %d %M %y %H:%i:%s %O'
    DATE_RFC850   :'%l, %d-%M-%y %H:%m:%i UTC'
    DATE_RFC1036  :'%D, %d %M %y %H:%i:%s %O'
    DATE_RFC1123  :'%D, %d %M %Y %H:%i:%s %O'
    DATE_RSS      :'%D, %d %M %Y %H:%i:%s %O'
    DATE_W3C      :'%Y-%m-%dT%H:%i:%s%Q'

  if not $formats[$fmt]?
    return false

  mdate($formats[$fmt], $time)

# Timespan
#
# Returns a span of seconds in this format:
#	10 days 14 hours 36 minutes 47 seconds
#
# @param  [Integer]  a number of seconds
# @param  [Integer]  Unix timestamp
# @return	integer
#
exports.timespan = timespan = ($seconds = 1, $time = '') ->
  exspresso.lang.load('date')

  if not 'number' is typeof($seconds)
    $seconds = 1


  if not 'number' is typeof($time)
    $time = time()


  if $time<=$seconds
    $seconds = 1

  else
    $seconds = $time - $seconds


  $str = ''
  $years = floor($seconds / 31536000)

  if $years > 0
    $str+=$years + ' ' + exspresso.lang.line((if ($years > 1) then 'date_years' else 'date_year')) + ', '


  $seconds-=$years * 31536000
  $months = floor($seconds / 2628000)

  if $years > 0 or $months > 0
    if $months > 0
      $str+=$months + ' ' + exspresso.lang.line((if ($months > 1) then 'date_months' else 'date_month')) + ', '


    $seconds-=$months * 2628000


  $weeks = floor($seconds / 604800)

  if $years > 0 or $months > 0 or $weeks > 0
    if $weeks > 0
      $str+=$weeks + ' ' + exspresso.lang.line((if ($weeks > 1) then 'date_weeks' else 'date_week')) + ', '


    $seconds-=$weeks * 604800


  $days = floor($seconds / 86400)

  if $months > 0 or $weeks > 0 or $days > 0
    if $days > 0
      $str+=$days + ' ' + exspresso.lang.line((if ($days > 1) then 'date_days' else 'date_day')) + ', '


    $seconds-=$days * 86400


  $hours = floor($seconds / 3600)

  if $days > 0 or $hours > 0
    if $hours > 0
      $str+=$hours + ' ' + exspresso.lang.line((if ($hours > 1) then 'date_hours' else 'date_hour')) + ', '


    $seconds-=$hours * 3600


  $minutes = floor($seconds / 60)

  if $days > 0 or $hours > 0 or $minutes > 0
    if $minutes > 0
      $str+=$minutes + ' ' + exspresso.lang.line((if ($minutes > 1) then 'date_minutes' else 'date_minute')) + ', '


    $seconds-=$minutes * 60


  if $str is ''
    $str+=$seconds + ' ' + exspresso.lang.line((if ($seconds > 1) then 'date_seconds' else 'date_second')) + ', '


  return substr(trim($str), 0,  - 1)

# Number of days in a month
#
# Takes a month/year as input and returns the number of days
# for the given month/year. Takes leap years into consideration.
#
# @param  [Integer]  a numeric month
# @param  [Integer]  a numeric year
# @return	integer
#
exports.days_in_month = days_in_month = ($month = 0, $year = '') ->
  if $month < 1 or $month > 12
    return 0


  if not 'number' is typeof($year) or strlen($year) isnt 4
    $year = date('Y')


  if $month is 2
    if $year400 is 0 or ($year4 is 0 and $year100 isnt 0)
      return 29



  $days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  return $days_in_month[$month - 1]

# Converts a local Unix timestamp to GMT
#
# @param  [Integer]  Unix timestamp
# @return	integer
#
exports.local_to_gmt = local_to_gmt = ($time = '') ->
  if $time is '' then $time = time()
  return mktime(gmdate("H", $time), gmdate("i", $time), gmdate("s", $time), gmdate("m", $time), gmdate("d", $time), gmdate("Y", $time))


#
# Converts GMT time to a localized value
#
# Takes a Unix timestamp (in GMT) as input, and returns
# at the local value based on the timezone and DST setting
# submitted
#
# @param  [Integer]  Unix timestamp
# @param  [String]  timezone
# @return	[Boolean]	whether DST is active
# @return	integer
#
exports.gmt_to_local = gmt_to_local = ($time = '', $timezone = 'UTC', $dst = false) ->
  if $time is ''
    return now()


  $time+=timezones($timezone) * 3600

  if $dst is true
    $time+=3600


  return $time

#
# Converts a MySQL Timestamp to Unix
#
# @param  [Integer]  Unix timestamp
# @return	integer
#
exports.mysql_to_unix = mysql_to_unix = ($time = '') ->
  #  We'll remove certain characters for backward compatibility
  #  since the formatting changed with MySQL 4.1
  #  YYYY-MM-DD HH:MM:SS

  $time = str_replace('-', '', $time)
  $time = str_replace(':', '', $time)
  $time = str_replace(' ', '', $time)

  #  YYYYMMDDHHMMSS
  return mktime(substr($time, 8, 2), substr($time, 10, 2), substr($time, 12, 2), substr($time, 4, 2), substr($time, 6, 2), substr($time, 0, 4))

#
# Unix to "Human"
#
# Formats Unix timestamp to the following prototype: 2006-08-21 11:35 PM
#
# @param  [Integer]  Unix timestamp
# @return	[Boolean]	whether to show seconds
# @param  [String]  format: us or euro
# @return	[String]
#
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

#
# Convert "human" date to GMT
#
# Reverses the above process
#
# @param  [String]  format: us or euro
# @return	integer
#
exports.human_to_unix = human_to_unix = ($datestr = '') ->
  if $datestr is ''
    return false


  $datestr = trim($datestr)
  $datestr = preg_replace("/\h20+/", ' ', $datestr)

  if not preg_match('/^[0-9]{2,4}\\-[0-9]{1,2}\\-[0-9]{1,2}\\s[0-9]{1,2}:[0-9]{1,2}(?::[0-9]{1,2})?(?:\\s[AP]M)?$/i', $datestr)?
    return false


  $split = $datestr.split(' ')

  $ex = $split['0'].split("-")

  $year = if (strlen($ex['0']) is 2) then '20' + $ex['0'] else $ex['0']
  $month = if (strlen($ex['1']) is 1) then '0' + $ex['1'] else $ex['1']
  $day = if (strlen($ex['2']) is 1) then '0' + $ex['2'] else $ex['2']

  $ex = $split['1'].split(":")

  $hour = if (strlen($ex['0']) is 1) then '0' + $ex['0'] else $ex['0']
  $min = if (strlen($ex['1']) is 1) then '0' + $ex['1'] else $ex['1']

  if $ex['2']?  and preg_match('/[0-9]{1,2}/', $ex['2'])?
    $sec = if (strlen($ex['2']) is 1) then '0' + $ex['2'] else $ex['2']

  else
    #  Unless specified, seconds get set to zero.
    $sec = '00'


  if $split['2']?
    $ampm = $split['2'].toLowerCase()

    if substr($ampm, 0, 1) is 'p' and $hour < 12 then $hour = $hour + 12
    if substr($ampm, 0, 1) is 'a' and $hour is 12 then $hour = '00'
    if strlen($hour) is 1 then $hour = '0' + $hour

  return mktime($hour, $min, $sec, $month, $day, $year)

# Timezone Menu
#
# Generates a drop-down menu of timezones.
#
# @param  [String]  timezone
# @param  [String]  classname
# @param  [String]  menu name
# @return	[String]
#
exports.timezone_menu = timezone_menu = ($default = 'UTC', $class = "", $name = 'timezones') ->
  exspresso.lang.load('date')

  if $default is 'GMT' then $default = 'UTC'
  $menu = '<select name="' + $name + '"'
  if $class isnt ''
    $menu+=' class="' + $class + '"'
  $menu+=">\n"

  for $key, $val of timezones()
    $selected = if ($default is $key) then " selected='selected'" else ''
    $menu+="<option value='{$key}'{$selected}>" + exspresso.lang.line($key) + "</option>\n"


  $menu+="</select>"

  return $menu

#
# Timezones
#
# Returns an array of timezones.  This is a helper function
# for various other ones in this library
#
# @param  [String]  timezone
# @return	[String]
#
exports.timezones = timezones = ($tz = '') ->
  #  Note: Don't change the order of these even though
  #  some items appear to be in the wrong order

  $zones =
    UM12    : - 12
    UM11    : - 11
    UM10    : - 10
    UM95    : - 9.5
    UM9     : - 9
    UM8     : - 8
    UM7     : - 7
    UM6     : - 6
    UM5     : - 5
    UM45    : - 4.5
    UM4     : - 4
    UM35    : - 3.5
    UM3     : - 3
    UM2     : - 2
    UM1     : - 1
    UTC     : 0
    UP1     : + 1
    UP2     : + 2
    UP3     : + 3
    UP35    : + 3.5
    UP4     : + 4
    UP45    : + 4.5
    UP5     : + 5
    UP55    : + 5.5
    UP575   : + 5.75
    UP6     : + 6
    UP65    : + 6.5
    UP7     : + 7
    UP8     : + 8
    UP875   : + 8.75
    UP9     : + 9
    UP95    : + 9.5
    UP10    : + 10
    UP105   : + 10.5
    UP11    : + 11
    UP115   : + 11.5
    UP12    : + 12
    UP1275  : + 12.75
    UP13    : + 13
    UP14    : + 14

  if $tz is ''
    return $zones

  if $tz is 'GMT' then $tz = 'UTC'
  return if not $zones[$tz]?  then 0 else $zones[$tz]
