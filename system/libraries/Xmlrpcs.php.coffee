#+--------------------------------------------------------------------+
#  Xmlrpcs.coffee
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
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @license		MIT License
# @link		http://darkoverlordofdata.com
# @since		Version 1.0
# @filesource
#

if not function_exists('xml_parser_create')
  show_error('Your PHP installation does not support XML')
  

if not class_exists('Exspresso_Xmlrpc')
  show_error('You must load the Xmlrpc class before loading the Xmlrpcs class in order to create a server.')
  

#  ------------------------------------------------------------------------

#
# XML-RPC server class
#
# @package		Exspresso
# @subpackage	Libraries
# @category	XML-RPC
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/xmlrpc.html
#
class Exspresso_Xmlrpcs extends Exspresso_Xmlrpc

  methods: {}# array of methods mapped to function names and signatures
  debug_msg: ''#  Debug Message
  system_methods: {}#  XML RPC Server methods
  controller_obj: {}
  
  object: false
  
  #
  # Constructor
  #
  __construct($config = {})
  {
  parent::__construct()
  @set_system_methods()
  
  if $config['functions']?  and is_array($config['functions'])
    @methods = array_merge(@methods, $config['functions'])
    
  
  log_message('debug', "XML-RPC Server Class Initialized")
  }
  
  #
  # Initialize Prefs and Serve
  #
  # @access	public
  # @param	mixed
  # @return	void
  #
  initialize : ($config = {}) ->
    if $config['functions']?  and is_array($config['functions'])
      @methods = array_merge(@methods, $config['functions'])
      
    
    if $config['debug']? 
      @debug = $config['debug']
      
    
    if $config['object']?  and is_object($config['object'])
      @object = $config['object']
      
    
    if $config['xss_clean']? 
      @xss_clean = $config['xss_clean']
      
    
  
  #
  # Setting of System Methods
  #
  # @access	public
  # @return	void
  #
  set_system_methods :  ->
    @methods = 
      'system.listMethods':
        'function':'this.listMethods', 
        'signature':[[@xmlrpcArray, @xmlrpcString], [@xmlrpcArray]], 
        'docstring':'Returns an array of available methods on this server', 
      'system.methodHelp':
        'function':'this.methodHelp', 
        'signature':[[@xmlrpcString, @xmlrpcString]], 
        'docstring':'Returns a documentation string for the specified method', 
      'system.methodSignature':
        'function':'this.methodSignature', 
        'signature':[[@xmlrpcArray, @xmlrpcString]], 
        'docstring':'Returns an array describing the return type and required parameters of a method', 
      'system.multicall':
        'function':'this.multicall', 
        'signature':[[@xmlrpcArray, @xmlrpcArray]], 
        'docstring':'Combine multiple RPC calls in one request. See http://www.xmlrpc.com/discuss/msgReader$1208 for details'
      
    
  
  #
  # Main Server Function
  #
  # @access	public
  # @return	void
  #
  serve :  ->
    $r = @parseRequest()
    $payload = '<?xml version="1.0" encoding="' + @xmlrpc_defencoding + '"?' + '>' + "\n"
    $payload+=@debug_msg
    $payload+=$r.prepare_response()
    
    header("Content-Type: text/xml")
    header("Content-Length: " + strlen($payload))
    die $payload
    
  
  #
  # Add Method to Class
  #
  # @access	public
  # @param	string	method name
  # @param	string	function
  # @param	string	signature
  # @param	string	docstring
  # @return	void
  #
  add_to_map : ($methodname, $function, $sig, $doc) ->
    @methods[$methodname] = 
      'function':$function, 
      'signature':$sig, 
      'docstring':$doc
      
    
  
  #
  # Parse Server Request
  #
  # @access	public
  # @param	string	data
  # @return	object	xmlrpc response
  #
  parseRequest : ($data = '') ->
    exports.$HTTP_RAW_POST_DATA
    
    # -------------------------------------
    #   Get Data
    # -------------------------------------
    
    if $data is ''
      $data = $HTTP_RAW_POST_DATA
      
    
    # -------------------------------------
    #   Set up XML Parser
    # -------------------------------------
    
    $parser = xml_parser_create(@xmlrpc_defencoding)
    $parser_object = new XML_RPC_Message("filler")
    
    $parser_object.xh[$parser] = {}
    $parser_object.xh[$parser]['isf'] = 0
    $parser_object.xh[$parser]['isf_reason'] = ''
    $parser_object.xh[$parser]['params'] = {}
    $parser_object.xh[$parser]['stack'] = {}
    $parser_object.xh[$parser]['valuestack'] = {}
    $parser_object.xh[$parser]['method'] = ''
    
    xml_set_object($parser, $parser_object)
    xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, true)
    xml_set_element_handler($parser, 'open_tag', 'closing_tag')
    xml_set_character_data_handler($parser, 'character_data')
    # xml_set_default_handler($parser, 'default_handler');
    
    
    # -------------------------------------
    #   PARSE + PROCESS XML DATA
    # -------------------------------------
    
    if not xml_parse($parser, $data, 1)
      #  return XML error as a faultCode
      $r = new XML_RPC_Response(0, @xmlrpcerrxml + xml_get_error_code($parser), sprintf('XML error: %s at line %d', xml_error_string(xml_get_error_code($parser)), xml_get_current_line_number($parser)))
      xml_parser_free($parser)
      
    else if $parser_object.xh[$parser]['isf']
      return new XML_RPC_Response(0, @xmlrpcerr['invalid_return'], @xmlrpcstr['invalid_return'])
      
    else 
      xml_parser_free($parser)
      
      $m = new XML_RPC_Message($parser_object.xh[$parser]['method'])
      $plist = ''
      
      for ($i = 0$i < count($parser_object.xh[$parser]['params'])$i++)
      {
      if @debug is true
        $plist+="$i - " + print_r(get_object_vars($parser_object.xh[$parser]['params'][$i]), true) + ";\n"
        
      
      $m.addParam($parser_object.xh[$parser]['params'][$i])
      }
      
      if @debug is true
        echo "<pre>"
        echo "---PLIST---\n" + $plist + "\n---PLIST END---\n\n"
        echo "</pre>"
        
      
      $r = @_execute($m)
      
    
    # -------------------------------------
    #   SET DEBUGGING MESSAGE
    # -------------------------------------
    
    if @debug is true
      @debug_msg = "<!-- DEBUG INFO:\n\n" + $plist + "\n END DEBUG-->\n"
      
    
    return $r
    
  
  #
  # Executes the Method
  #
  # @access	protected
  # @param	object
  # @return	mixed
  #
  _execute : ($m) ->
    $methName = $m.method_name
    
    #  Check to see if it is a system call
    $system_call = if (strncmp($methName, 'system', 5) is 0) then true else false
    
    if @xss_clean is false
      $m.xss_clean = false
      
    
    # -------------------------------------
    #   Valid Method
    # -------------------------------------
    
    if not @methods[$methName]['function']? 
      return new XML_RPC_Response(0, @xmlrpcerr['unknown_method'], @xmlrpcstr['unknown_method'])
      
    
    # -------------------------------------
    #   Check for Method (and Object)
    # -------------------------------------
    
    $method_parts = explode(".", @methods[$methName]['function'])
    $objectCall = if ($method_parts['1']?  and $method_parts['1'] isnt "") then true else false
    
    if $system_call is true
      if not is_callable([@, $method_parts['1']])
        return new XML_RPC_Response(0, @xmlrpcerr['unknown_method'], @xmlrpcstr['unknown_method'])
        
      
    else 
      if $objectCall and  not is_callable([$method_parts['0'], $method_parts['1']])
        return new XML_RPC_Response(0, @xmlrpcerr['unknown_method'], @xmlrpcstr['unknown_method'])
        
      else if not $objectCall and  not is_callable(@methods[$methName]['function'])
        return new XML_RPC_Response(0, @xmlrpcerr['unknown_method'], @xmlrpcstr['unknown_method'])
        
      
    
    # -------------------------------------
    #   Checking Methods Signature
    # -------------------------------------
    
    if @methods[$methName]['signature']? 
      $sig = @methods[$methName]['signature']
      for ($i = 0$i < count($sig)$i++)
      {
      $current_sig = $sig[$i]
      
      if count($current_sig) is count($m.params) + 1
        for ($n = 0$n < count($m.params)$n++)
        {
        $p = $m.params[$n]
        $pt = if ($p.kindOf() is 'scalar') then $p.scalarval() else $p.kindOf()
        
        if $pt isnt $current_sig[$n + 1]
          $pno = $n + 1
          $wanted = $current_sig[$n + 1]
          
          return new XML_RPC_Response(0, @xmlrpcerr['incorrect_params'], @xmlrpcstr['incorrect_params'] + ": Wanted {$wanted}, got {$pt} at param {$pno})")
          
        }
        
      }
      
    
    # -------------------------------------
    #   Calls the Function
    # -------------------------------------
    
    if $objectCall is true
      if $method_parts[0] is "this" and $system_call is true
        return call_user_func([@, $method_parts[1]], $m)
        
      else 
        if @object is false
          $Exspresso = Exspresso
          return $Exspresso[$method_parts]['1']($m)
          
        else 
          return @object[$method_parts]['1']($m)
          # return call_user_func(array(&$method_parts['0'],$method_parts['1']), $m);
          
        
      
    else 
      return call_user_func(@methods[$methName]['function'], $m)
      
    
  
  #
  # Server Function:  List Methods
  #
  # @access	public
  # @param	mixed
  # @return	object
  #
  listMethods : ($m) ->
    $v = new XML_RPC_Values()
    $output = {}
    
    for $key, $value of @methods
      $output.push new XML_RPC_Values($key, 'string')
      
    
    for $key, $value of @system_methods
      $output.push new XML_RPC_Values($key, 'string')
      
    
    $v.addArray($output)
    return new XML_RPC_Response($v)
    
  
  #
  # Server Function:  Return Signature for Method
  #
  # @access	public
  # @param	mixed
  # @return	object
  #
  methodSignature : ($m) ->
    $parameters = $m.output_parameters()
    $method_name = $parameters[0]
    
    if @methods[$method_name]? 
      if @methods[$method_name]['signature']
        $sigs = {}
        $signature = @methods[$method_name]['signature']
        
        for ($i = 0$i < count($signature)$i++)
        {
        $cursig = {}
        $inSig = $signature[$i]
        for ($j = 0$j < count($inSig)$j++)
        {
        $cursig.push new XML_RPC_Values($inSig[$j], 'string')
        }
        $sigs.push new XML_RPC_Values($cursig, 'array')
        }
        $r = new XML_RPC_Response(new XML_RPC_Values($sigs, 'array'))
        
      else 
        $r = new XML_RPC_Response(new XML_RPC_Values('undef', 'string'))
        
      
    else 
      $r = new XML_RPC_Response(0, @xmlrpcerr['introspect_unknown'], @xmlrpcstr['introspect_unknown'])
      
    return $r
    
  
  #
  # Server Function:  Doc String for Method
  #
  # @access	public
  # @param	mixed
  # @return	object
  #
  methodHelp : ($m) ->
    $parameters = $m.output_parameters()
    $method_name = $parameters[0]
    
    if @methods[$method_name]? 
      $docstring = if @methods[$method_name]['docstring']?  then @methods[$method_name]['docstring'] else ''
      
      return new XML_RPC_Response(new XML_RPC_Values($docstring, 'string'))
      
    else 
      return new XML_RPC_Response(0, @xmlrpcerr['introspect_unknown'], @xmlrpcstr['introspect_unknown'])
      
    
  
  #
  # Server Function:  Multi-call
  #
  # @access	public
  # @param	mixed
  # @return	object
  #
  multicall : ($m) ->
    #  Disabled
    return new XML_RPC_Response(0, @xmlrpcerr['unknown_method'], @xmlrpcstr['unknown_method'])
    
    $parameters = $m.output_parameters()
    $calls = $parameters[0]
    
    $result = {}
    
    for $value in $calls
      # $attempt = $this->_execute(new XML_RPC_Message($value[0], $value[1]));
      
      $m = new XML_RPC_Message($value[0])
      $plist = ''
      
      for ($i = 0$i < count($value[1])$i++)
      {
      $m.addParam(new XML_RPC_Values($value[1][$i], 'string'))
      }
      
      $attempt = @_execute($m)
      
      if $attempt.faultCode() isnt 0
        return $attempt
        
      
      $result.push new XML_RPC_Values([$attempt.value(]), 'array')
      
    
    return new XML_RPC_Response(new XML_RPC_Values($result, 'array'))
    
  
  #
  #  Multi-call Function:  Error Handling
  #
  # @access	public
  # @param	mixed
  # @return	object
  #
  multicall_error : ($err) ->
    $str = if is_string($err) then @xmlrpcstr["multicall_${err}"] else $err.faultString()
    $code = if is_string($err) then @xmlrpcerr["multicall_${err}"] else $err.faultCode()
    
    $struct['faultCode'] = new XML_RPC_Values($code, 'int')
    $struct['faultString'] = new XML_RPC_Values($str, 'string')
    
    return new XML_RPC_Values($struct, 'struct')
    
  
  #
  #  Multi-call Function:  Processes method
  #
  # @access	public
  # @param	mixed
  # @return	object
  #
  do_multicall : ($call) ->
    if $call.kindOf() isnt 'struct'
      return @multicall_error('notstruct')
      
    else if not $methName = $call.me['struct']['methodName'])
      $msg.params.push $params.me['array'][$i]
      
    
    $result = @_execute($msg)
    
    if $result.faultCode() isnt 0
      return @multicall_error($result)
      
    
    return new XML_RPC_Values([$result.value(]),'array')
    
  
  

register_class 'Exspresso_Xmlrpcs', Exspresso_Xmlrpcs
module.exports = Exspresso_Xmlrpcs
#  END XML_RPC_Server class


#  End of file Xmlrpcs.php 
#  Location: ./system/libraries/Xmlrpcs.php 