#+--------------------------------------------------------------------+
#  Upload.coffee
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
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# File Uploading Class
#
#
class system.lib.Upload
  
  max_size: 0
  max_width: 0
  max_height: 0
  max_filename: 0
  allowed_types: ""
  file_temp: ""
  file_name: ""
  orig_name: ""
  file_type: ""
  file_size: ""
  file_ext: ""
  upload_path: ""
  overwrite: false
  encrypt_name: false
  is_image: false
  image_width: ''
  image_height: ''
  image_type: ''
  image_size_str: ''
  error_msg: {}
  mimes: {}
  remove_spaces: true
  xssClean: false
  temp_prefix: "temp_file_"
  client_name: ''
  
  _file_name_override: ''
  
  #
  # Constructor
  #
    #
  __construct($props = {})
  {
  if count($props) > 0
    @initialize($props)
    
  
  log_message('debug', "Upload Class Initialized")
  }
  
  #
  # Initialize preferences
  #
  # @param  [Array]  # @return [Void]  #
  initialize($config = {})
  {
  $defaults = 
    'max_size':0, 
    'max_width':0, 
    'max_height':0, 
    'max_filename':0, 
    'allowed_types':"", 
    'file_temp':"", 
    'file_name':"", 
    'orig_name':"", 
    'file_type':"", 
    'file_size':"", 
    'file_ext':"", 
    'upload_path':"", 
    'overwrite':false, 
    'encrypt_name':false, 
    'is_image':false, 
    'image_width':'', 
    'image_height':'', 
    'image_type':'', 
    'image_size_str':'', 
    'error_msg':{}, 
    'mimes':{}, 
    'remove_spaces':true, 
    'xssClean':false,
    'temp_prefix':"temp_file_", 
    'client_name':''
    
  
  
  for $key, $val of $defaults
    if $config[$key]? 
      $method = 'set_' + $key
      if @[$method]?
        @$method($config[$key])
        
      else 
        @$key = $config[$key]
        
      
    else 
      @$key = $val
      
    
  
  #  if a file_name was provided in the config, use it instead of the user input
  #  supplied file name for all uploads until initialized again
  @_file_name_override = @file_name
  }
  
  #
  # Perform the file upload
  #
  # @return	bool
  #
  do_upload($field = 'userfile')
  {
  
  #  Is $_FILES[$field] set? If not, no reason to continue.
  if not $_FILES[$field]? 
    @set_error('upload_no_file_selected')
    return false
    
  
  #  Is the upload path valid?
  if not @validate_upload_path()
    #  errors will already be set by validate_upload_path() so just return FALSE
    return false
    
  
  #  Was the file able to be uploaded? If not, determine the reason why.
  if not is_uploaded_file($_FILES[$field]['tmp_name'])
    $error = if ( not $_FILES[$field]['error']? ) then 4 else $_FILES[$field]['error']
    
    switch $error
      when 1#  UPLOAD_ERR_INI_SIZE#  UPLOAD_ERR_INI_SIZE
        @set_error('upload_file_exceeds_limit')
        
      when 2#  UPLOAD_ERR_FORM_SIZE#  UPLOAD_ERR_FORM_SIZE
        @set_error('upload_file_exceeds_form_limit')
        
      when 3#  UPLOAD_ERR_PARTIAL#  UPLOAD_ERR_PARTIAL
        @set_error('upload_file_partial')
        
      when 4#  UPLOAD_ERR_NO_FILE#  UPLOAD_ERR_NO_FILE
        @set_error('upload_no_file_selected')
        
      when 6#  UPLOAD_ERR_NO_TMP_DIR#  UPLOAD_ERR_NO_TMP_DIR
        @set_error('upload_no_temp_directory')
        
      when 7#  UPLOAD_ERR_CANT_WRITE#  UPLOAD_ERR_CANT_WRITE
        @set_error('upload_unable_to_write_file')
        
      when 8#  UPLOAD_ERR_EXTENSION#  UPLOAD_ERR_EXTENSION
        @set_error('upload_stopped_by_extension')
        
      else@set_error('upload_no_file_selected')
        
        
    
    return false
    
  
  
  #  Set the uploaded data as class variables
  @file_temp = $_FILES[$field]['tmp_name']
  @file_size = $_FILES[$field]['size']
  @file_type = preg_replace("/^(.+?);.*$/", "\\1", $_FILES[$field]['type'])
  @file_type = trim(stripslashes(@file_type.toLowerCase()), '"')
  @file_name = @_prep_filename($_FILES[$field]['name'])
  @file_ext = @get_extension(@file_name)
  @client_name = @file_name
  
  #  Is the file type allowed to be uploaded?
  if not @is_allowed_filetype()
    @set_error('upload_invalid_filetype')
    return false
    
  
  #  if we're overriding, let's now make sure the new name and type is allowed
  if @_file_name_override isnt ''
    @file_name = @_prep_filename(@_file_name_override)
    
    #  If no extension was provided in the file_name config item, use the uploaded one
    if @_file_name_override.indexOf('.') is -1
      @file_name+=@file_ext
      
    
    #  An extension was provided, lets have it!
    else 
      @file_ext = @get_extension(@_file_name_override)
      
    
    if not @is_allowed_filetype(true)
      @set_error('upload_invalid_filetype')
      return false
      
    
  
  #  Convert the file size to kilobytes
  if @file_size > 0
    @file_size = Math.round(@file_size / 1024, 2)
    
  
  #  Is the file size within the allowed maximum?
  if not @is_allowed_filesize()
    @set_error('upload_invalid_filesize')
    return false
    
  
  #  Are the image dimensions within the allowed size?
  #  Note: This can fail if the server has an open_basdir restriction.
  if not @is_allowed_dimensions()
    @set_error('upload_invalid_dimensions')
    return false
    
  
  #  Sanitize the file name for security
  @file_name = @clean_file_name(@file_name)
  
  #  Truncate the file name if it's too long
  if @max_filename > 0
    @file_name = @limit_filename_length(@file_name, @max_filename)
    
  
  #  Remove white spaces in the name
  if @remove_spaces is true
    @file_name = preg_replace("/\s+/", "_", @file_name)
    
  
  #
  # Validate the file name
  # This function appends an number onto the end of
  # the file if one with the same name already exists.
  # If it returns false there was a problem.
  #
  @orig_name = @file_name
  
  if @overwrite is false
    @file_name = @set_filename(@upload_path, @file_name)
    
    if @file_name is false
      return false
      
    
  
  #
  # Run the file through the XSS hacking filter
  # This helps prevent malicious code from being
  # embedded within a file.  Scripts can easily
  # be disguised as images or other file types.
  #
  if @xssClean
    if @do_xssClean() is false
      @set_error('upload_unable_to_write_file')
      return false
      
    
  
  #
  # Move the file to the final destination
  # To deal with different server configurations
  # we'll attempt to use copy() first.  If that fails
  # we'll use move_uploaded_file().  One of the two should
  # reliably work in most environments
  #
  if not copy(@file_temp, @upload_path + @file_name)
    if not move_uploaded_file(@file_temp, @upload_path + @file_name)
      @set_error('upload_destination_error')
      return false
      
    
  
  #
  # Set the finalized image dimensions
  # This sets the image width/height (assuming the
  # file was an image).  We use this information
  # in the "data" function.
  #
  @set_image_properties(@upload_path + @file_name)
  
  return true
  }
  
  #
  # Finalized Data Array
  #
  # Returns an associative array containing all of the information
  # related to the upload, allowing the developer easy access in one array.
  #
  # @return	array
  #
  data()
  {
  return 
    'file_name':@file_name, 
    'file_type':@file_type, 
    'file_path':@upload_path, 
    'full_path':@upload_path + @file_name, 
    'raw_name':str_replace(@file_ext, '', @file_name,
  'orig_name':@orig_name, 
  'client_name':@client_name, 
  'file_ext':@file_ext, 
  'file_size':@file_size, 
  'is_image':@is_image(), 
  'image_width':@image_width, 
  'image_height':@image_height, 
  'image_type':@image_type, 
  'image_size_str':@image_size_str, 
  )
  }
  
  #
  # Set Upload Path
  #
  # @param  [String]    # @return [Void]  #
  set_upload_path($path)
  {
  #  Make sure it has a trailing slash
  @upload_path = rtrim($path, '/') + '/'
  }
  
  #
  # Set the file name
  #
  # This function takes a filename/path as input and looks for the
  # existence of a file with the same name. If found, it will append a
  # number to the end of the filename to avoid overwriting a pre-existing file.
  #
  # @param  [String]    # @param  [String]    # @return	[String]
  #
  set_filename($path, $filename)
  {
  if @encrypt_name is true
    #mt_srand()
    $filename = md5(uniqid(rand())) + @file_ext
    
  
  if not file_exists($path + $filename)
    return $filename
    
  
  $filename = str_replace(@file_ext, '', $filename)
  
  $new_filename = ''
  for ($i = 1$i < 100$i++)
  {
  if not file_exists($path + $filename + $i + @file_ext)
    $new_filename = $filename + $i + @file_ext
    break
    
  }
  
  if $new_filename is ''
    @set_error('upload_bad_filename')
    return false
    
  else 
    return $new_filename
    
  }
  
  #
  # Set Maximum File Size
  #
  # @param  [Integer]  # @return [Void]  #
  set_max_filesize($n)
  {
  @max_size = if ($n < 0) then 0 else $n
  }
  
  #
  # Set Maximum File Name Length
  #
  # @param  [Integer]  # @return [Void]  #
  set_max_filename($n)
  {
  @max_filename = if ($n < 0) then 0 else $n
  }
  
  #
  # Set Maximum Image Width
  #
  # @param  [Integer]  # @return [Void]  #
  set_max_width($n)
  {
  @max_width = if ($n < 0) then 0 else $n
  }
  
  #
  # Set Maximum Image Height
  #
  # @param  [Integer]  # @return [Void]  #
  set_max_height($n)
  {
  @max_height = if ($n < 0) then 0 else $n
  }
  
  #
  # Set Allowed File Types
  #
  # @param  [String]    # @return [Void]  #
  set_allowed_types($types)
    if not is_array($types) and $types is '*'
      @allowed_types = '*'
      return

    @allowed_types = explode('|', $types)

  #
  # Set Image Properties
  #
  # Uses GD to determine the width/height/type of image
  #
  # @param  [String]    # @return [Void]  #
  set_image_properties($path = '')
  {
  if not @is_image()
    return 
    
  
  if function_exists('getimagesize')
    if false isnt ($D = getimagesize($path))
      $types = 1:'gif', 2:'jpeg', 3:'png'
      
      @image_width = $D['0']
      @image_height = $D['1']
      @image_type = if ( not $types[$D['2']]? ) then 'unknown' else $types[$D['2']]
      @image_size_str = $D['3']#  string containing height and width
      
    
  }
  
  #
  # Set XSS Clean
  #
  # Enables the XSS flag so that the file that was uploaded
  # will be run through the XSS filter.
  #
  # @return	[Boolean]
  # @return [Void]  #
  set_xssClean($flag = false)
  {
  @xssClean = if ($flag is true) then true else false
  }
  
  #
  # Validate the image
  #
  # @return	bool
  #
  is_image()
  {
  #  IE will sometimes return odd mime-types during upload, so here we just standardize all
  #  jpegs or pngs to the same file type.
  
  $png_mimes = ['image/x-png']
  $jpeg_mimes = ['image/jpg', 'image/jpe', 'image/jpeg', 'image/pjpeg']
  
  if in_array(@file_type, $png_mimes)
    @file_type = 'image/png'
    
  
  if in_array(@file_type, $jpeg_mimes)
    @file_type = 'image/jpeg'
    
  
  $img_mimes = [
    'image/gif', 
    'image/jpeg', 
    'image/png', 
    ]
  
  return if (in_array(@file_type, $img_mimes, true)) then true else false
  }
  
  #
  # Verify that the filetype is allowed
  #
  # @return	bool
  #
  is_allowed_filetype($ignore_mime = false)
  {
  if @allowed_types is '*'
    return true
    
  
  if count(@allowed_types) is 0 or  not is_array(@allowed_types)
    @set_error('upload_no_file_types')
    return false
    
  
  $ext = ltrim(@file_ext.toLowerCase(), '.')
  
  if not in_array($ext, @allowed_types)
    return false
    
  
  #  Images get some additional checks
  $image_types = ['gif', 'jpg', 'jpeg', 'png', 'jpe']
  
  if in_array($ext, $image_types)
    if getimagesize(@file_temp) is false
      return false
      
    
  
  if $ignore_mime is true
    return true
    
  
  $mime = @mimes_types($ext)
  
  if is_array($mime)
    if in_array(@file_type, $mime, true)
      return true
      
    
  else if $mime is @file_type
    return true
    
  
  return false
  }
  
  #
  # Verify that the file is within the allowed size
  #
  # @return	bool
  #
  is_allowed_filesize()
  {
  if @max_size isnt 0 and @file_size > @max_size
    return false
    
  else 
    return true
    
  }
  
  #
  # Verify that the image is within the allowed width/height
  #
  # @return	bool
  #
  is_allowed_dimensions()
  {
  if not @is_image()
    return true
    
  
  if function_exists('getimagesize')
    $D = getimagesize(@file_temp)
    
    if @max_width > 0 and $D['0'] > @max_width
      return false
      
    
    if @max_height > 0 and $D['1'] > @max_height
      return false
      
    
    return true
    
  
  return true
  }
  
  #
  # Validate Upload Path
  #
  # Verifies that it is a valid upload path with proper permissions.
  #
  #
  # @return	bool
  #
  validate_upload_path()
  {
  if @upload_path is ''
    @set_error('upload_no_filepath')
    return false
    
  
  if function_exists('realpath') and realpath(@upload_path) isnt false
    @upload_path = str_replace("\\", "/", realpath(@upload_path))
    
  
  if not is_dir(@upload_path)
    @set_error('upload_no_filepath')
    return false
    
  
  if not is_really_writable(@upload_path)
    @set_error('upload_not_writable')
    return false
    
  
  @upload_path = preg_replace("/(.+?)\/*$/", "\\1/", @upload_path)
  return true
  }
  
  #
  # Extract the file extension
  #
  # @param  [String]    # @return	[String]
  #
  get_extension($filename)
  {
  $x = explode('.', $filename)
  return '.' + $x.pop()
  }
  
  #
  # Clean the file name for security
  #
  # @param  [String]    # @return	[String]
  #
  clean_file_name($filename)
  {
  $bad = [
    "<!--", 
    "-->", 
    "'", 
    "<", 
    ">", 
    '"', 
    '&', 
    '$', 
    '=', 
    ';', 
    '?', 
    '/', 
    "%20", 
    "%22", 
    "%3c", #  <
    "%253c", #  <
    "%3e", #  >
    "%0e", #  >
    "%28", #  (
    "%29", #  )
    "%2528", #  (
    "%26", #  &
    "%24", #  $
    "%3f", #  ?
    "%3b", #  ;
    "%3d"#  =
    ]
  
  $filename = str_replace($bad, '', $filename)
  
  return stripslashes($filename)
  }
  
  #
  # Limit the File Name Length
  #
  # @param  [String]    # @return	[String]
  #
  limit_filename_length($filename, $length)
  {
  if strlen($filename) < $length
    return $filename
    
  
  $ext = ''
  if $filename.indexOf('.') isnt -1
    $parts = explode('.', $filename)
    $ext = '.' + $parts.pop()
    $filename = implode('.', $parts)
    
  
  return substr($filename, 0, ($length - strlen($ext))) + $ext
  }
  
  #
  # Runs the file through the XSS clean function
  #
  # This prevents people from embedding malicious code in their files.
  # I'm not sure that it won't negatively affect certain files in unexpected ways,
  # but so far I haven't found that it causes trouble.
  #
  # @return [Void]  #
  do_xssClean()
  {
  $file = @file_temp
  
  if filesize($file) is 0
    return false
    
  
  if function_exists('memory_get_usage') and memory_get_usage() and ini_get('memory_limit') isnt ''
    $current = ini_get('memory_limit') * 1024 * 1024
    
    #  There was a bug/behavioural change in PHP 5.2, where numbers over one million get output
    #  into scientific notation.  number_format() ensures this number is an integer
    #  http://bugs.php.net/bug.php?id=43053
    
    $new_memory = number_format(ceil(filesize($file) + $current), 0, '.', '')
    
    ini_set('memory_limit', $new_memory)#  When an integer is used, the value is measured in bytes. - PHP.net
    
  
  #  If the file being uploaded is an image, then we should have no problem with XSS attacks (in theory), but
  #  IE can be fooled into mime-type detecting a malformed image as an html file, thus executing an XSS attack on anyone
  #  using IE who looks at the image.  It does this by inspecting the first 255 bytes of an image.  To get around this
  #  CI will itself look at the first 255 bytes of an image to determine its relative safety.  This can save a lot of
  #  processor power and time if it is actually a clean image, as it will be in nearly all instances _except_ an
  #  attempted XSS attack.
  
  if function_exists('getimagesize') and getimagesize($file) isnt false
    if ($file = fopen($file, 'rb')) is false#  "b" to force binary
      return false#  Couldn't open the file, return FALSE
      
    
    $opening_bytes = fread($file, 256)
    fclose($file)
    
    #  These are known to throw IE into mime-type detection chaos
    #  <a, <body, <head, <html, <img, <plaintext, <pre, <script, <table, <title
    #  title is basically just in SVG, but we filter it anyhow
    
    if not preg_match('/<(a|body|head|html|img|plaintext|pre|script|table|title)[\\s>]/i', $opening_bytes)?
      return true#  its an image, no "triggers" detected in the first 256 bytes, we're good
      
    
  
  if ($data = file_get_contents($file)) is false
    return false
    
  
  return @security.xssClean($data, true)
  }
  
  #
  # Set an error message
  #
  # @param  [String]    # @return [Void]  #
  set_error($msg)
  {
  $controller = Exspresso
  @i18n.load('upload')
  
  if is_array($msg)
    for $val in $msg
      $msg = if (@i18n.line($val) is false) then $val else @i18n.line($val)
      @error_msg.push $msg
      log_message('error', $msg)
      
    
  else 
    $msg = if (@i18n.line($msg) is false) then $msg else @i18n.line($msg)
    @error_msg.push $msg
    log_message('error', $msg)
    
  }
  
  #
  # Display the error message
  #
  # @param  [String]    # @param  [String]    # @return	[String]
  #
  display_errors($open = '<p>',$close = '</p>')
  {
  $str = ''
  for $val in @error_msg
    $str+=$open + $val + $close
    
  
  return $str
  }
  
  #
  # List of Mime Types
  #
  # This is a list of mime types.  We use it to validate
  # the "allowed types" set by the developer
  #
  # @param  [String]    # @return	[String]
  #
  mimes_types($mime)
  {
  exports.$mimes
  
  if count(@mimes) is 0
    if is_file(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
      require(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
      
    else if is_file(APPPATH + 'config/mimes' + EXT)
      require(APPPATH + 'config//mimes' + EXT)
      
    else 
      return false
      
    
    @mimes = $mimes
    delete $mimes
    
  
  return if ( not @mimes[$mime]? ) then false else @mimes[$mime]
  }
  
  #
  # Prep Filename
  #
  # Prevents possible script execution from Apache's handling of files multiple extensions
  # http://httpd.apache.org/docs/1.3/mod/mod_mime.html#multipleext
  #
  # @param  [String]    # @return	[String]
  #
  _prep_filename($filename)
    if $filename.indexOf('.') is -1 or @allowed_types is '*'
      return $filename


    $parts = explode('.', $filename)
    $ext = $parts.pop()
    $filename = $parts.shift()

    for $part in $parts
      if not in_array($part.toLowerCase(), @allowed_types) or @mimes_types($part.toLowerCase()) is false
        $filename+='.' + $part + '_'

      else
        $filename+='.' + $part



    $filename+='.' + $ext

    return $filename

module.exports = system.lib.Upload
#  END Upload Class

#  End of file Upload.php 
#  Location: ./system/lib/Upload.php