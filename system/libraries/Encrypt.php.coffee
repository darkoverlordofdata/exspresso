#+--------------------------------------------------------------------+
#  Encrypt.coffee
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
# Exspresso Encryption Class
#
# Provides two-way keyed encoding using XOR Hashing and Mcrypt
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Libraries
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/encryption.html
#
class Exspresso_Encrypt
  
  Exspresso: {}
  encryption_key: ''
  _hash_type: 'sha1'
  _mcrypt_exists: false
  _mcrypt_cipher: {}
  _mcrypt_mode: {}
  
  #
  # Constructor
  #
  # Simply determines whether the mcrypt library exists.
  #
  #
  __construct()
  {
  @Exspresso = Exspresso
  @_mcrypt_exists = if ( not function_exists('mcrypt_encrypt')) then false else true
  log_message('debug', "Encrypt Class Initialized")
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch the encryption key
  #
  # Returns it as MD5 in order to have an exact-length 128 bit key.
  # Mcrypt is sensitive to keys that are not the correct length
  #
  # @access	public
  # @param	string
  # @return	string
  #
  get_key : ($key = '') ->
    if $key is ''
      if @encryption_key isnt ''
        return @encryption_key
        
      
      $Exspresso = Exspresso
      $key = $Exspresso.config.item('encryption_key')
      
      if $key is false
        show_error('In order to use the encryption class requires that you set an encryption key in your config file.')
        
      
    
    return md5($key)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set the encryption key
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_key : ($key = '') ->
    @encryption_key = $key
    
  
  #  --------------------------------------------------------------------
  
  #
  # Encode
  #
  # Encodes the message string using bitwise XOR encoding.
  # The key is combined with a random hash, and then it
  # too gets converted using XOR. The whole thing is then run
  # through mcrypt (if supported) using the randomized key.
  # The end result is a double-encrypted message string
  # that is randomized with each call to this function,
  # even if the supplied message and key are the same.
  #
  # @access	public
  # @param	string	the string to encode
  # @param	string	the key
  # @return	string
  #
  encode : ($string, $key = '') ->
    $key = @get_key($key)
    
    if @_mcrypt_exists is true
      $enc = @mcrypt_encode($string, $key)
      
    else 
      $enc = @_xor_encode($string, $key)
      
    
    return base64_encode($enc)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Decode
  #
  # Reverses the above process
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	string
  #
  decode : ($string, $key = '') ->
    $key = @get_key($key)
    
    if preg_match('/[^a-zA-Z0-9\/\+=]/', $string)
      return false
      
    
    $dec = base64_decode($string)
    
    if @_mcrypt_exists is true
      if ($dec = @mcrypt_decode($dec, $key)) is false
        return false
        
      
    else 
      $dec = @_xor_decode($dec, $key)
      
    
    return $dec
    
  
  #  --------------------------------------------------------------------
  
  #
  # Encode from Legacy
  #
  # Takes an encoded string from the original Encryption class algorithms and
  # returns a newly encoded string using the improved method added in 2.0.0
  # This allows for backwards compatibility and a method to transition to the
  # new encryption algorithms.
  #
  # For more details, see http://darkoverlordofdata.com/user_guide/installation/upgrade_200.html#encryption
  #
  # @access	public
  # @param	string
  # @param	int		(mcrypt mode constant)
  # @param	string
  # @return	string
  #
  encode_from_legacy : ($string, $legacy_mode = MCRYPT_MODE_ECB, $key = '') ->
    if @_mcrypt_exists is false
      log_message('error', 'Encoding from legacy is available only when Mcrypt is in use.')
      return false
      
    
    #  decode it first
    #  set mode temporarily to what it was when string was encoded with the legacy
    #  algorithm - typically MCRYPT_MODE_ECB
    $current_mode = @_get_mode()
    @set_mode($legacy_mode)
    
    $key = @get_key($key)
    
    if preg_match('/[^a-zA-Z0-9\/\+=]/', $string)
      return false
      
    
    $dec = base64_decode($string)
    
    if ($dec = @mcrypt_decode($dec, $key)) is false
      return false
      
    
    $dec = @_xor_decode($dec, $key)
    
    #  set the mcrypt mode back to what it should be, typically MCRYPT_MODE_CBC
    @set_mode($current_mode)
    
    #  and re-encode
    return base64_encode(@mcrypt_encode($dec, $key))
    
  
  #  --------------------------------------------------------------------
  
  #
  # XOR Encode
  #
  # Takes a plain-text string and key as input and generates an
  # encoded bit-string using XOR
  #
  # @access	private
  # @param	string
  # @param	string
  # @return	string
  #
  _xor_encode : ($string, $key) ->
    $rand = ''
    while strlen($rand) < 32
      $rand+=mt_rand(0, mt_getrandmax())
      
    
    $rand = @hash($rand)
    
    $enc = ''
    for ($i = 0$i < strlen($string)$i++)
    {
    $enc+=substr($rand, ($istrlen($rand)), 1) + (substr($rand, ($istrlen($rand)), 1)substr($string, $i, 1))
    }
    
    return @_xor_merge($enc, $key)
    
  
  #  --------------------------------------------------------------------
  
  #
  # XOR Decode
  #
  # Takes an encoded string and key as input and generates the
  # plain-text original message
  #
  # @access	private
  # @param	string
  # @param	string
  # @return	string
  #
  _xor_decode : ($string, $key) ->
    $string = @_xor_merge($string, $key)
    
    $dec = ''
    for ($i = 0$i < strlen($string)$i++)
    {
    $dec+=(substr($string, $i++, 1)substr($string, $i, 1))
    }
    
    return $dec
    
  
  #  --------------------------------------------------------------------
  
  #
  # XOR key + string Combiner
  #
  # Takes a string and key as input and computes the difference using XOR
  #
  # @access	private
  # @param	string
  # @param	string
  # @return	string
  #
  _xor_merge : ($string, $key) ->
    $hash = @hash($key)
    $str = ''
    for ($i = 0$i < strlen($string)$i++)
    {
    $str+=substr($string, $i, 1)substr($hash, ($istrlen($hash)), 1)
    }
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Encrypt using Mcrypt
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	string
  #
  mcrypt_encode : ($data, $key) ->
    $init_size = mcrypt_get_iv_size(@_get_cipher(), @_get_mode())
    $init_vect = mcrypt_create_iv($init_size, MCRYPT_RAND)
    return @_add_cipher_noise($init_vect + mcrypt_encrypt(@_get_cipher(), $key, $data, @_get_mode(), $init_vect), $key)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Decrypt using Mcrypt
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	string
  #
  mcrypt_decode : ($data, $key) ->
    $data = @_remove_cipher_noise($data, $key)
    $init_size = mcrypt_get_iv_size(@_get_cipher(), @_get_mode())
    
    if $init_size > strlen($data)
      return false
      
    
    $init_vect = substr($data, 0, $init_size)
    $data = substr($data, $init_size)
    return rtrim(mcrypt_decrypt(@_get_cipher(), $key, $data, @_get_mode(), $init_vect), "\0")
    
  
  #  --------------------------------------------------------------------
  
  #
  # Adds permuted noise to the IV + encrypted data to protect
  # against Man-in-the-middle attacks on CBC mode ciphers
  # http://www.ciphersbyritter.com/GLOSSARY.HTM#IV
  #
  # Function description
  #
  # @access	private
  # @param	string
  # @param	string
  # @return	string
  #
  _add_cipher_noise : ($data, $key) ->
    $keyhash = @hash($key)
    $keylen = strlen($keyhash)
    $str = ''
    
    for ($i = 0,$j = 0,$len = strlen($data)$i < $len++$i, ++$j)
    {
    if $j>=$keylen
      $j = 0
      
    
    $str+=chr((ord($data[$i]) + ord($keyhash[$j]))256)
    }
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Removes permuted noise from the IV + encrypted data, reversing
  # _add_cipher_noise()
  #
  # Function description
  #
  # @access	public
  # @param	type
  # @return	type
  #
  _remove_cipher_noise : ($data, $key) ->
    $keyhash = @hash($key)
    $keylen = strlen($keyhash)
    $str = ''
    
    for ($i = 0,$j = 0,$len = strlen($data)$i < $len++$i, ++$j)
    {
    if $j>=$keylen
      $j = 0
      
    
    $temp = ord($data[$i]) - ord($keyhash[$j])
    
    if $temp < 0
      $temp = $temp + 256
      
    
    $str+=chr($temp)
    }
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set the Mcrypt Cipher
  #
  # @access	public
  # @param	constant
  # @return	string
  #
  set_cipher : ($cipher) ->
    @_mcrypt_cipher = $cipher
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set the Mcrypt Mode
  #
  # @access	public
  # @param	constant
  # @return	string
  #
  set_mode : ($mode) ->
    @_mcrypt_mode = $mode
    
  
  #  --------------------------------------------------------------------
  
  #
  # Get Mcrypt cipher Value
  #
  # @access	private
  # @return	string
  #
  _get_cipher :  ->
    if @_mcrypt_cipher is ''
      @_mcrypt_cipher = MCRYPT_RIJNDAEL_256
      
    
    return @_mcrypt_cipher
    
  
  #  --------------------------------------------------------------------
  
  #
  # Get Mcrypt Mode Value
  #
  # @access	private
  # @return	string
  #
  _get_mode :  ->
    if @_mcrypt_mode is ''
      @_mcrypt_mode = MCRYPT_MODE_CBC
      
    
    return @_mcrypt_mode
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set the Hash type
  #
  # @access	public
  # @param	string
  # @return	string
  #
  set_hash : ($type = 'sha1') ->
    @_hash_type = if ($type isnt 'sha1' and $type isnt 'md5') then 'sha1' else $type
    
  
  #  --------------------------------------------------------------------
  
  #
  # Hash encode a string
  #
  # @access	public
  # @param	string
  # @return	string
  #
  hash : ($str) ->
    return if (@_hash_type is 'sha1') then @sha1($str) else md5($str)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Generate an SHA1 Hash
  #
  # @access	public
  # @param	string
  # @return	string
  #
  sha1 : ($str) ->
    if not function_exists('sha1')
      if not function_exists('mhash')
        require(BASEPATH + 'libraries/Sha1' + EXT)
        $SH = new Exspresso_SHA
        return $SH.generate($str)
        
      else 
        return bin2hex(mhash(MHASH_SHA1, $str))
        
      
    else 
      return sha1($str)
      
    
  
  

register_class 'Exspresso_Encrypt', Exspresso_Encrypt
module.exports = Exspresso_Encrypt

#  END Exspresso_Encrypt class

#  End of file Encrypt.php 
#  Location: ./system/libraries/Encrypt.php 