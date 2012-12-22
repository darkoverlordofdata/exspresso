<?php
/*
+--------------------------------------------------------------------+
| Parser.php
+--------------------------------------------------------------------+
| Copyright DarkOverlordOfData (c) 2012
+--------------------------------------------------------------------+
|                                                                    
| This file is a part of Exspresso
|                                                                    
| Exspresso is free software; you can copy, modify, and distribute
| it under the terms of the MIT License
|                                                                    
+--------------------------------------------------------------------+
*/
/**
 *	Parser Class
 *
 *    A recurive descent parser that reformats php to coffee-script
 *
 */
class Parser {
  
  // Token Types:
  const TT_END            = 0;
  const TT_DELIMITER      = 1;
  const TT_IDENTIFIER     = 2;
  const TT_NUMBER         = 3;
  const TT_KEYWORD        = 4;
  const TT_STRING         = 5;
  const TT_COMMENT        = 6;
  const TT_MARKUP         = 7;
  const TT_IGNORE         = 99;

  const SCOPE_SUPERGLOBAL = 0;
  const SCOPE_GLOBAL      = 1;
  const SCOPE_FUNCTION    = 2;
  const SCOPE_CLASS       = 3;
  
	/** 
   * Symbol tables by scope
   * 
   * @var array  
   */
  private $var_def = array(
    array(),    // SCOPE_SUPERGLOBAL
    array(),    // SCOPE_GLOBAL
    array(),    // SCOPE_FUNCTION
    array(),    // SCOPE_CLASS
  );
  
	/** 
   * Token type map - maps Zend tokens to token type
   * 
   * @var array  
   */
  private $tt_map = array(
    '&'                           => Parser::TT_DELIMITER,
    '|'                           => Parser::TT_DELIMITER,
    '+'                           => Parser::TT_DELIMITER,
    '-'                           => Parser::TT_DELIMITER,
    '*'                           => Parser::TT_DELIMITER,
    '/'                           => Parser::TT_DELIMITER,
    '<'                           => Parser::TT_DELIMITER,
    '>'                           => Parser::TT_DELIMITER,
    '('                           => Parser::TT_DELIMITER,
    ')'                           => Parser::TT_DELIMITER,
    '{'                           => Parser::TT_DELIMITER,
    '}'                           => Parser::TT_DELIMITER,
    '['                           => Parser::TT_DELIMITER,
    ']'                           => Parser::TT_DELIMITER,
    '='                           => Parser::TT_DELIMITER,
    ','                           => Parser::TT_DELIMITER,
    '.'                           => Parser::TT_DELIMITER,
    '!'                           => Parser::TT_DELIMITER,
    '?'                           => Parser::TT_DELIMITER,
    ':'                           => Parser::TT_DELIMITER,
    '"'                           => Parser::TT_DELIMITER,
    'T_ABSTRACT'                  => Parser::TT_IGNORE,
    'T_AND_EQUAL'                 => Parser::TT_DELIMITER,
    'T_ARRAY'                     => Parser::TT_KEYWORD,
    'T_ARRAY_CAST'                => Parser::TT_IGNORE,
    'T_AS'                        => Parser::TT_KEYWORD,
    'T_BOOLEAN_AND'               => Parser::TT_DELIMITER,
    'T_BOOLEAN_OR'                => Parser::TT_DELIMITER,
    'T_BOOL_CAST'                 => Parser::TT_IGNORE,
    'T_BREAK'                     => Parser::TT_KEYWORD,
    'T_CASE'                      => Parser::TT_KEYWORD,
    'T_CATCH'                     => Parser::TT_KEYWORD,
    'T_CLASS'                     => Parser::TT_KEYWORD,
    'T_CLASS_C'                   => Parser::TT_IGNORE,
    'T_CLONE'                     => Parser::TT_KEYWORD,
    'T_CLOSE_TAG'                 => Parser::TT_MARKUP,
    'T_COMMENT'                   => Parser::TT_COMMENT,
    'T_CONCAT_EQUAL'              => Parser::TT_DELIMITER,
    'T_CONST'                     => Parser::TT_KEYWORD,
    'T_CONSTANT_ENCAPSED_STRING'  => Parser::TT_STRING,
    'T_CONTINUE'                  => Parser::TT_KEYWORD,
    'T_CURLY_OPEN'                => Parser::TT_DELIMITER,
    'T_DEC'                       => Parser::TT_DELIMITER,
    'T_DECLARE'                   => Parser::TT_KEYWORD,
    'T_DEFAULT'                   => Parser::TT_KEYWORD,
    'T_DIR'                       => Parser::TT_KEYWORD,
    'T_DIV_EQUAL'                 => Parser::TT_DELIMITER,
    'T_DNUMBER'                   => Parser::TT_NUMBER,
    'T_DOC_COMMENT'               => Parser::TT_COMMENT,
    'T_DO'                        => Parser::TT_KEYWORD,
    'T_DOLLAR_OPEN_CURLY_BRACES'  => Parser::TT_DELIMITER,
    'T_DOUBLE_ARROW'              => Parser::TT_DELIMITER,
    'T_DOUBLE_CAST'               => Parser::TT_DELIMITER,
    'T_DOUBLE_COLON'              => Parser::TT_DELIMITER,
    'T_ECHO'                      => Parser::TT_KEYWORD,
    'T_ELSE'                      => Parser::TT_KEYWORD,
    'T_ELSEIF'                    => Parser::TT_KEYWORD,
    'T_EMPTY'                     => Parser::TT_KEYWORD,
    'T_ENCAPSED_AND_WHITESPACE'   => Parser::TT_STRING,
    'T_ENDDECLARE'                => Parser::TT_KEYWORD,
    'T_ENDFOR'                    => Parser::TT_KEYWORD,
    'T_ENDFOREACH'                => Parser::TT_KEYWORD,
    'T_ENDIF'                     => Parser::TT_KEYWORD,
    'T_ENDSWITCH'                 => Parser::TT_KEYWORD,
    'T_ENDWHILE'                  => Parser::TT_KEYWORD,
    'T_END_HEREDOC'               => Parser::TT_KEYWORD,
    'T_EVAL'                      => Parser::TT_KEYWORD,
    'T_EXIT'                      => Parser::TT_KEYWORD,
    'T_EXTENDS'                   => Parser::TT_KEYWORD,
    'T_FILE'                      => Parser::TT_KEYWORD,
    'T_FINAL'                     => Parser::TT_KEYWORD,
    'T_FOR'                       => Parser::TT_KEYWORD,
    'T_FOREACH'                   => Parser::TT_KEYWORD,
    'T_FUNCTION'                  => Parser::TT_KEYWORD,
    'T_FUNC_C'                    => Parser::TT_KEYWORD,
    'T_GLOBAL'                    => Parser::TT_KEYWORD,
    'T_GOTO'                      => Parser::TT_KEYWORD,
    'T_HALT_COMPILER'             => Parser::TT_KEYWORD,
    'T_IF'                        => Parser::TT_KEYWORD,
    'T_IMPLEMENTS'                => Parser::TT_KEYWORD,
    'T_INC'                       => Parser::TT_DELIMITER,
    'T_INCLUDE'                   => Parser::TT_KEYWORD,
    'T_INCLUDE_ONCE'              => Parser::TT_KEYWORD,
    'T_INLINE_HTML'               => Parser::TT_MARKUP,
    'T_INSTANCEOF'                => Parser::TT_KEYWORD,
    'T_INSTEADOF'                 => Parser::TT_KEYWORD,
    'T_INT_CAST'                  => Parser::TT_IGNORE,
    'T_INTERFACE'                 => Parser::TT_KEYWORD,
    'T_ISSET'                     => Parser::TT_KEYWORD,
    'T_IS_EQUAL'                  => Parser::TT_DELIMITER,
    'T_IS_GREATER_OR_EQUAL'       => Parser::TT_DELIMITER,
    'T_IS_IDENTICAL'              => Parser::TT_DELIMITER,
    'T_IS_NOT_EQUAL'              => Parser::TT_DELIMITER,
    'T_IS_NOT_IDENTICAL'          => Parser::TT_DELIMITER,
    'T_IS_SMALLER_OR_EQUAL'       => Parser::TT_DELIMITER,
    'T_LINE'                      => Parser::TT_KEYWORD,
    'T_LIST'                      => Parser::TT_KEYWORD,
    'T_LNUMBER'                   => Parser::TT_NUMBER,
    'T_LOGICAL_AND'               => Parser::TT_DELIMITER,
    'T_LOGICAL_OR'                => Parser::TT_DELIMITER,
    'T_LOGICAL_XOR'               => Parser::TT_DELIMITER,
    'T_METHOD_C'                  => Parser::TT_KEYWORD,
    'T_MINUS_EQUAL'               => Parser::TT_DELIMITER,
    'T_MOD_EQUAL'                 => Parser::TT_DELIMITER,
    'T_MUL_EQUAL'                 => Parser::TT_DELIMITER,
    'T_NAMESPACE'                 => Parser::TT_KEYWORD,
    'T_NS_C'                      => Parser::TT_KEYWORD,
    'T_NS_SEPARATOR'              => Parser::TT_DELIMITER,
    'T_NEW'                       => Parser::TT_KEYWORD,
    'T_NUM_STRING'                => Parser::TT_STRING,
    'T_OBJECT_CAST'               => Parser::TT_IGNORE,
    'T_OBJECT_OPERATOR'           => Parser::TT_DELIMITER,
    'T_OPEN_TAG'                  => Parser::TT_MARKUP,
    'T_OPEN_TAG_WITH_ECHO'        => Parser::TT_MARKUP,
    'T_OR_EQUAL'                  => Parser::TT_DELIMITER,
    'T_PAAMAYIM_NEKUDOTAYIM'      => Parser::TT_DELIMITER,
    'T_PLUS_EQUAL'                => Parser::TT_DELIMITER,
    'T_PRINT'                     => Parser::TT_KEYWORD,
    'T_PRIVATE'                   => Parser::TT_IGNORE,
    'T_PUBLIC'                    => Parser::TT_IGNORE,
    'T_PROTECTED'                 => Parser::TT_IGNORE,
    'T_REQUIRE'                   => Parser::TT_KEYWORD,
    'T_REQUIRE_ONCE'              => Parser::TT_KEYWORD,
    'T_RETURN'                    => Parser::TT_KEYWORD,
    'T_SL'                        => Parser::TT_DELIMITER,
    'T_SL_EQUAL'                  => Parser::TT_DELIMITER,
    'T_SR'                        => Parser::TT_DELIMITER,
    'T_SR_EQUAL'                  => Parser::TT_DELIMITER,
    'T_START_HEREDOC'             => Parser::TT_DELIMITER,
    'T_STATIC'                    => Parser::TT_KEYWORD, 
    'T_STRING'                    => Parser::TT_IDENTIFIER,
    'T_STRING_CAST'               => Parser::TT_KEYWORD,
    'T_STRING_VARNAME'            => Parser::TT_STRING,
    'T_SWITCH'                    => Parser::TT_KEYWORD,
    'T_THROW'                     => Parser::TT_KEYWORD,
    'T_TRAIT'                     => Parser::TT_KEYWORD,
    'T_TRAIT_C'                   => Parser::TT_KEYWORD,
    'T_TRY'                       => Parser::TT_KEYWORD,
    'T_UNSET'                     => Parser::TT_KEYWORD,
    'T_UNSET_CAST'                => Parser::TT_KEYWORD,
    'T_USE'                       => Parser::TT_KEYWORD,
    'T_VAR'                       => Parser::TT_KEYWORD,
    'T_VARIABLE'                  => Parser::TT_IDENTIFIER,
    'T_WHILE'                     => Parser::TT_KEYWORD,
    'T_WHITESPACE'                => Parser::TT_DELIMITER,
    'T_XOR_EQUAL'                 => Parser::TT_DELIMITER,
  );
  
	/** 
   * Tokens of the php file being converted
   * 
   * @var array  
   */
	private $tokens = array();
	/** 
   * The current token index
   * 
   * @var int 
   */
	private $pos = 0;
	/** 
   * The current scope level
   * 
   * @var int 
   */
	private $brace = 0;
	/** 
   * The class name being defined
   * 
   * @var int 
   */
	private $class_name = '';
	/** 
   * The function name being defined
   * 
   * @var int 
   */
	private $func_name = '';
	/** 
   * The arg def of function being defined
   * 
   * @var int 
   */
	private $arg_def = FALSE;
	/** 
   * The arg def of function being defined
   * 
   * @var int 
   */
	private $scope = Parser::SCOPE_GLOBAL;

  private $is_config = FALSE;

	/**
	 * Convert
	 *
	 * @param string $path path to php source
	 */
  public function convert($path) {

    try {

      $filename = basename($path, '.php');

$header = <<<DOC
#+--------------------------------------------------------------------+
#  {$filename}.coffee
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


DOC;

      if (strpos($path, '/config/') !== FALSE) {
        $this->is_config = TRUE;
      }
      elseif (strpos($path, '/language/') !== FALSE) {
        $this->is_config = TRUE;
      }

      $this->load($path);
      if (DUMP) $this->dump($path, $this->tokens);
      $cs = $this->parse(0, count($this->tokens));
      $cs = str_replace('parent::__construct', 'super', $cs);

      if (HTML) {
        return $cs;
      }
      else {
        return $header.$cs;
      }
    }
    catch (Exception $e) {

      echo $e->getMessage().' at '.$e->getLine().PHP_EOL;
      echo $e->getTraceAsString();

    }

  }

	/**
	 * load - loads the token array
   * normalize whitespace
	 *
	 * @param string $path path to php source
	 */
  function load($path) {
    /*
     * Remove leading white space
     * Leading white space will be reconstructed 
     * for proper nesting in resultant coffee-script
     */
    $src = array();
    foreach (explode(PHP_EOL, file_get_contents($path)) as $line) {
      if (HTML) {
        $src[] = $line;
      }
      else {
        $src[] = trim($line);
      }
    }
    /*
     * Generate tokens using the built-in php lexer
     */
    $txt = implode(PHP_EOL, $src);
    $txt = str_replace('**/', '*/', $txt);
    $txt = str_replace('<?php echo', '<?=', $txt);


		$tokens = token_get_all($txt);
    /*
     * Normalize whitespace: one character per token
     * Normalize double-quoted strings: de-parse back into whole string.
     *
     */
    $this->tokens = array();
    $in_quote = FALSE;
    $qu_value = "";

    foreach ($tokens as $token) {
      if (is_array($token)) {
        if ($in_quote) {
          $qu_value .= $token[1];
        }
        else {

          if ($token[0] == T_COMMENT
           || $token[0] == T_DOC_COMMENT) {
            if (substr($token[1], -1) == PHP_EOL) {
              $token[1] = trim($token[1]);
              $this->tokens[] = $token;
              $this->tokens[] = array(T_WHITESPACE, PHP_EOL);
            }
            else {
              $this->tokens[] = $token;
            }

          }
          elseif ($token[0] == T_WHITESPACE) {
            $chars = str_split($token[1]);
            foreach ($chars as $ch) {
              $this->tokens[] = array(T_WHITESPACE, $ch);
            }
          }
          else {
            $this->tokens[] = $token;
          }
        }
      }
      else {
        if ($token === '"') $in_quote = ! $in_quote;
        if ($in_quote) {
          if ($token == '{') $token = '#{';
          $qu_value .= $token;
        }
        else {
          $this->tokens[] = $qu_value.$token;
          $qu_value = '';
        }

      }
    }
  }
  
	/**
	 * dump 
	 *
	 * @param string $path path to dump output
   * @param array $tokens
	 */
  function dump($path, $tokens) {
    
    $out = array();
    $index = 0;
    foreach ($tokens as $token) {
      if (is_array($token)) {
        $value = $token[1];
        $token = trim(token_name($token[0]));
        $value = str_replace(PHP_EOL, '\n', $value);
        $value = str_replace("\r", '\r', $value);
        $value = str_replace("\t", '\t', $value);
        $out[] = "$index) $token||$value||\n";
      }
      else {
        $token = trim($token);
        $value = '';
        $out[] = "$index) $token\n";
      }
      $index++;
    }
    echo implode($out).PHP_EOL;
  }
  
  

  /**
	 * parse - entry point into the
   * recursive descent parser. 
	 *
	 * @param int $from
	 * @param int $to
   * @return string output
	 */
  function parse($start, $end, $indent = 0) {
    
    if (TRACE) echo "--- parse($start, $end, $indent)\n";
    
    $cs = array();
    $this->pos = $start;
    $this->brace += $indent;

    $tt = $this->get_token($token, $value);
    while ($this->pos <= $end) {
      if ($tt == 0) break;
      $cs[] = $this->parse_token($tt, $token, $value);
      $tt = $this->get_next_token($token, $value);
    }
    $this->brace -= $indent;
    return implode($cs);
  }
  
	/**
	 * get_next_token - get the next token from the
   * token stream $tokens. When there are no more 
   * tokens, returns TT_END.
	 *
	 * @param string $token
   * @param string $value
   * @return int token value
	 */
  function get_next_token(& $token, & $value) {
    
    while (isset($this->tokens[++$this->pos])) {
      $tt = $this->get_token($token, $value);
      if ($value != " " && $value != "\t") {
        return $tt;
      }
    }
    $token = '';
    $value = '';
    return Parser::TT_END; 
    
  }

  /**
	 * put_back - decrements pos
   * so that get_next_token can be
   * called again
	 *
	 */
  function put_back() {
    $this->pos -=1;
  }

  /**
	 * get_token - decodes the current token
   * from the input token stream.
	 *
	 * @param string $token
   * @param string $value
   * @return int token value
	 */
  function get_token(& $token, & $value, $index=0) {

    $token = $this->tokens[$this->pos+$index];
    if (is_string($token)) {
      $token = $token;
      $value = '';
      if (strlen($token) == 1)
        return Parser::TT_DELIMITER;
      else
        $value = $token;
        $token = '"';
        return Parser::TT_STRING;
    }
    else {
      $value = $token[1];
      $token = token_name($token[0]);
      return $this->tt_map[$token];
    }
  }
  
	/**
	 * is_next_token - get's the next token,
   * checking if it matches the passed token. 
   * Returns true/false, or raises an exception. 
	 *
	 * @param string $token
	 * @param boolean $raise
	 * @return boolean true if match
	 */
  function is_next_token($token, $raise = FALSE) {
    
    $tt = $this->get_next_token($next_token, $next_value);
      
    if ($token == $next_token) {
      return TRUE;
    }
    if ($raise == TRUE) {
      throw new Exception("Expected '$token', found '$next_token'");
    }
    return FALSE;
    
  }

	/**
	 * find_token - look ahead for a token,
   * and return found at.
	 *
	 * @param string $check
   * @param int $until
	 * @return string
	 */
  function find_token($check, $until = -1) {

    $until = $until == -1 ? count($this->tokens)-1: $until;
    $mark = $this->pos;

    while ($this->pos < $until) {
      $tt = $this->get_next_token($token, $value);
      if ($check == $token) {
        $index = $this->pos;
        $this->pos = $mark;
        return $index;
      }
    }
    $this->pos = $mark;
    return -1;
    
  }
  

	/**
	 * parse_token - start parsing the current token
	 *
   * @param int $tt token type
	 * @param string $token
   * @param string $value
   * @return string output
	 */
  function parse_token($tt, $token, $value) {
    
    if (TRACE) echo "--- parse_token($tt, $token, $value)\n";
    
    switch($tt) {
      case Parser::TT_COMMENT:
        return $this->parse_comment($token, $value);
        
      case Parser::TT_DELIMITER:
        return $this->parse_delimiter($token, $value);
        
      case Parser::TT_IDENTIFIER:
        return $this->parse_identifier($token, $value);
        
      case Parser::TT_KEYWORD:
        return $this->parse_keyword($token, $value);
        
      case Parser::TT_MARKUP:
        return $this->parse_markup($token, $value);
        
      case Parser::TT_NUMBER:
        return $this->parse_number($token, $value);
        
      case Parser::TT_STRING:
        return $this->parse_string($token, $value);
        
    }
    
    return '';
  }
  
	/**
	 * parse_comment - 
	 *
	 * @param string $value
	 * @return string
	 */
  function parse_comment($token, $value) {

    if (TRACE) echo "--- parse_comment($token, $value)\n";
    
    // Single line comment
    if (substr($value, 0, 2) == '//') {
      return '# '.substr($value, 2);
    }

    // Single line comment
    $lines = explode(PHP_EOL, $value);
    if (count($lines) == 1) {
      $line = $lines[0];
      $line = str_replace('/**', '', $line);
      $line = str_replace('/*', '', $line);
      $line = str_replace('*/', '', $line);
      
      return '# '.$line;
    }

    // Multi line comment
    for ($i=0; $i<count($lines); $i++) {
      if (($lines[$i] == '/**') 
      || ($lines[$i] == '/*') 
      || ($lines[$i] == ' */') 
      || ($lines[$i] == '*/')) {
        $lines[$i] = '';
      }
      if (substr($lines[$i], 0, 1) == '*') {
        $lines[$i] = substr($lines[$i], 1); 
      }
      if ($i == 0) {
        $lines[$i] = '#'.$lines[$i];
      }
      else {
        $lines[$i] = str_repeat(TABS, $this->brace).'#'.$lines[$i];
      }
    }
    return implode(PHP_EOL, $lines);

  }
  
	/**
	 * parse_delimiter - 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_delimiter($token, $value) {

    if (TRACE) echo "--- parse_delimiter($token, $value)\n";
    
    switch($token) {
      case '+':   return ' + '; 
      case '-':   return ' - '; 
      case '*':   return ' * ';
      case '/':   return ' / ';
      case '>':   return ' > ';
      case '<':   return ' < ';
      case ')':   return ')';
      case ']':   return ']';
      case ',':   return ', ';
      case '=':   return $this->parse_let($value);
      case '(':   return '(';
      case '{':   return '{';
      case '}':   return '}';
      case '[':   return $this->parse_open_bracket($value);
      case '.':   return ' + ';
      case '&':   return ' and ';
      case '|':   return ' or ';
      case '!':   return ' not ';
      case '?':   return ' then ';
      case ':':   return ' else ';  
      case '"':   return '"';
      case 'T_AND_EQUAL':
        return '&=';
      case 'T_BOOLEAN_AND':
        return ' and ';
      case 'T_BOOLEAN_OR':
        return ' or ';
      case 'T_CONCAT_EQUAL':
        return '+=';
      case 'T_CURLY_OPEN':
        return '#{';
      case 'T_DEC':
        return '--';
      case 'T_DIV_EQUAL':
        return '/=';
      case 'T_DOLLAR_OPEN_CURLY_BRACES':
        return '#{';
      case 'T_DOUBLE_ARROW':
        return ':';
      case 'T_DOUBLE_COLON':
        return '::';
      case 'T_INC':
        return '++';
      case 'T_IS_EQUAL':
        return ' is ';
      case 'T_IS_GREATER_OR_EQUAL':
        return '>=';
      case 'T_IS_IDENTICAL':
        return ' is ';
      case 'T_IS_NOT_EQUAL':
        return ' isnt ';
      case 'T_IS_NOT_IDENTICAL':
        return ' isnt ';
      case 'T_IS_SMALLER_OR_EQUAL':
        return '<=';
      case 'T_LOGICAL_AND':
        return ' and ';
      case 'T_LOGICAL_OR':
        return ' or ';
      case 'T_LOGICAL_XOR':
        return '^|';
      case 'T_MINUS_EQUAL':
        return '-=';
      case 'T_MOD_EQUAL':
        return '%=';
      case 'T_MUL_EQUAL':
        return '*=';
      case 'T_NS_SEPARATOR':
        return '.';
      case 'T_OBJECT_OPERATOR':
        return '.';
      case 'T_OR_EQUAL':
        return '|=';
      case 'T_PAAMAYIM_NEKUDOTAYIM':
        return '::';
      case 'T_PLUS_EQUAL':
        return '+=';
      case 'T_SL':
        return '<<';
      case 'T_SL_EQUAL':
        return '<<=';
      case 'T_SR':
        return '>>';
      case 'T_SR_EQUAL':
        return '>>=';
      case 'T_START_HEREDOC':
        return '"""';
      case 'T_WHITESPACE':
        if ($value == PHP_EOL) {
          $value .= str_repeat(TABS, $this->brace);
        }
        return $value;
      case 'T_XOR_EQUAL':
        return '^=';
    }
  }  

	/**
	 * parse_identifier - 
   * 
   * function names, variable names
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_identifier($token, $value) {

    if (TRACE) echo "--- parse_identifier($token, $value)\n";
    
    switch ($token) {
      case 'T_STRING':
        if ($value == 'TRUE') {
          return 'true';
        }
        elseif ($value == 'FALSE') {
          return 'false';
        }
        elseif ($value == 'NULL') {
          return 'null';
        }
        elseif ($value == 'func_num_args') {
          $this->is_next_token('(', TRUE);
          $this->is_next_token(')', TRUE);
          return 'arguments.length';
        }
        elseif ($value == 'func_get_args') {
          $this->is_next_token('(', TRUE);
          $this->is_next_token(')', TRUE);
          return 'arguments';
        }
        elseif ($value == 'func_get_arg') {
          $this->is_next_token('(', TRUE);
          $cs = $this->parse_until(')');
          return 'arguments['.$cs.']';
        }
        elseif ($value == '__construct') {
          return 'constructor';
        }

        return $value;
      case 'T_VARIABLE':
				if ($value == '$this') {
          $tt = $this->get_next_token($token, $value);
          if ($token != 'T_OBJECT_OPERATOR') {
            $this->put_back();
          }
          else {
            //  get member name
            $tt = $this->get_next_token($token, $value);
            $this->put_back();
          }
					return '@';
				}
				else {
					$def = '';
					if ($this->is_config == TRUE && $this->scope == Parser::SCOPE_GLOBAL) {
					  if ($value == '$config' || $value == '$lang') {
  					  $value = 'exports';
					  }
					}
					return $def.$value;
				}
    }
    return '';
  }  

	/**
	 * parse_markup - 
   * 
   * TODO: Map php view template to .eco format
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_markup($token, $value) {

    if (TRACE) echo "--- parse_markup($token, $value)\n";

    switch($token) {
      case 'T_INLINE_HTML':         return $value;
      case 'T_OPEN_TAG':            return '<% ';
      case 'T_OPEN_TAG_WITH_ECHO':  return '<%- ';
      case 'T_CLOSE_TAG':           return ' %>';
    }
    return '';
  }

	/**
	 * parse_number - 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_number($token, $value) {

    if (TRACE) echo "--- parse_number($token, $value)\n";

    if ($value == '0') return $value;
    if (substr($value,0,1) == '0') {
      // Fix Octal value:
      $value = '0o'.$value;
    }
    return $value;

  }  

	/**
	 * parse_string - 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_string($token, $value) {

    if (TRACE) echo "--- parse_string($token, $value)\n";
    return $value;
    
  }  

  /**
	 * parse_keyword -  the heavy lifting
   * of converting the php to coffee-script.
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_keyword($token, $value) {
    
    if (TRACE) echo "--- parse_keyword($token, $value)\n";
    
    switch ($token) {
      case 'T_ARRAY':
        return $this->parse_array($value);
      case 'T_AS':
        return 'in';
      case 'T_BREAK':
        return 'break';
      case 'T_CASE':
        return '';
      case 'T_CATCH':
        return 'catch '.$this->parse_parens();
      case 'T_CLASS':
        return $this->parse_class($value);
      case 'T_CLONE':
        return 'clone('.$this->parse_parens().')';
      case 'T_CONST':
        return '';
      case 'T_CONTINUE':
        return 'continue';
      case 'T_DECLARE':
        return '';
      case 'T_DEFAULT':
        return 'else';
      case 'T_DIR':
        return '__dirname';
      case 'T_DO':
        return $this->parse_do($value);
      case 'T_ECHO':
        return 'echo '.$this->parse_statement();
      case 'T_ELSE':
        if ($this->is_next_token('T_IF'))  {
          return 'else '.$this->parse_if($value);
        }
        else {
          $this->put_back();
          $this->parse_block($comment, $body);
          return 'else '.$comment.$body;
        }
      case 'T_ELSEIF':
        return 'else '.$this->parse_if($value);
      case 'T_EMPTY':
        return 'empty';
      case 'T_ENDDECLARE':
        return '';
      case 'T_ENDFOR':
        return 'end';
      case 'T_ENDFOREACH':
        return 'end';
      case 'T_ENDIF':
        return 'end';
      case 'T_ENDSWITCH':
        return 'end';
      case 'T_ENDWHILE':
        return '';
      case 'T_END_HEREDOC':
        return '"""';
      case 'T_EVAL':
        return 'eval'.$this->parse_parens();
      case 'T_EXIT':
        return 'die ';

        $cs = $this->parse_statement();
        if ($cs == '') 
          return 'die()';
        else
          return 'die '.$cs;
      case 'T_EXTENDS':
        return ' extends';
      case 'T_FILE':
        return '__filename';
      case 'T_FOR':
        return 'for ';
        return $this->parse_for($value);
      case 'T_FOREACH':
        return $this->parse_foreach($value);
      case 'T_FUNCTION':
        return $this->parse_function($value);
      case 'T_GLOBAL':
        return 'exports.';
      case 'T_IF':
        return $this->parse_if($value);
      case 'T_IMPLEMENTS':
        return '';
      case 'T_INCLUDE':
        return 'require';//('.$this->parse_statement().')';
      case 'T_INCLUDE_ONCE':
        return 'require';//('.$this->parse_statement().')';
      case 'T_INSTANCEOF':
        return 'instanceof';
      case 'T_INSTEADOF':
        return '';
      case 'T_INTERFACE':
        return '';
      case 'T_ISSET':
        return $this->parse_isset($value);
      case 'T_LINE':
        return '';
      case 'T_LIST':
				return $this->parse_list($value);
      case 'T_NAMESPACE':
        return 'namespace ';
      case 'T_NEW':
        return 'new ';
      case 'T_PRINT':
        return 'print';// '.$this->parse_statement();
      case 'T_PRIVATE':
        return $this->parse_member();
      case 'T_PUBLIC':
        return $this->parse_member();
      case 'T_PROTECTED':
        return $this->parse_member();
      case 'T_REQUIRE':
        return 'require';//('.$this->parse_statement().')';
      case 'T_REQUIRE_ONCE':
        return 'require';//('.$this->parse_statement().')';
      case 'T_RETURN':
        return 'return '.$this->parse_expression();
      case 'T_STATIC':
        return $this->parse_static($value);
      case 'T_STRING_CAST':
        return "''+";
      case 'T_SWITCH':
        return $this->parse_switch($value);
      case 'T_THROW':
        return 'throw' ;
      case 'T_TRY':
        return 'try '.$this->parse_parens();
      case 'T_UNSET':
        return $this->parse_unset($value);
      case 'T_USE':
        return 'use ';
      case 'T_VAR':
        return $this->parse_var();
      case 'T_WHILE':
        return $this->parse_while($value);
    }
    return '';
  }
  
  /**
	 * parse_block - return the block following
   * keywords in the following idioms:
   * 
   *  keyword (...) [comment] body;
   * 
   *  keyword (...) [comment]
   *    body;
	 *
   *  keyword (...) [comment] {
   *    body;
   *    body;
   *  }
   * 
   *  keyword (...) [comment] 
   *  {
   *    body;
   *    body;
   *  }
   *
   *  keyword (...) : ?>
   *  ...
   *  <?php end<keyword> ?>
   *
   *
   *
	 * @return string output
	 */
  function parse_block(& $comment, & $body) {
    
    if (TRACE) echo "--- parse_block()\n";
    // After we skip optional white space,
    // including possible line-feed
    $comment = '';
    $body = '';
    
    $tt = $this->get_next_token($token, $value);
    // find the next semicolon.
    while ($token != ';') {

      // found alternative syntax - :
      if ($token == ':') {
        $body = ':';
        return;
      }
      
      // found brace first
      if ($token == '{') {
        $start = $this->pos;
        $brace = 1;
        // Find the matching closing brace '}':
        while ($brace > 0) {
          $tt = $this->get_next_token($token, $value);
          if ($token == '{') $brace++;
          if ($token == '}') $brace--;
        }
        $end = $this->pos;
        $body = $this->parse($start+1, $end-1, 1);
        if (TRACE) echo "--- parse_blend()\n$body\n---";
        return;
      }
      if ($tt == 0) break;
      // extract comments
      if ($tt == Parser::TT_COMMENT) {
        $comment .= $this->parse_comment($token, $value); 
      }
      elseif ($value != PHP_EOL) {
        $body .= $this->parse_token($tt, $token, $value);
      }
      $tt = $this->get_next_token($token, $value);
    }
    return;
  }

	/**
	 * parse_member - define a member variable
   * or function on a class.
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_member() {

    if (TRACE) echo "--- parse_member()\n";
    
    $tt = $this->get_next_token($token, $value);
    if ($token == 'T_FUNCTION') {
      return '';
    }
    if ($token != 'T_VARIABLE') {
      throw new Exception("Expected 'T_VARIABLE', found '$token'");
    }

    $this->put_back();
    return $this->parse_var();
    
  }    
  
	/**
	 * parse_arglist
   * - parses function def argument list
	 *
	 * @return string output
	 */
  function parse_arglist() {
    
    if (TRACE) echo "--- parse_arglist()\n";
    //
    //
    $this->is_next_token('(', TRUE);
    $this->arg_def = TRUE;
    $cs = '';
    $tt = $this->get_next_token($token, $value);
    while ($token != ')') {
      if ($token == 'T_VARIABLE') {
        $this->var_def[$this->scope][$value] = 0;
      }
      if ($tt == 0) break;
      $cs .= $this->parse_token($tt, $token, $value);
      $tt = $this->get_next_token($token, $value);
      if ($tt == 0) break;
    }
    $this->arg_def = FALSE;
    if ($cs == '') {
      return ' ';
    }
    else {
      return '('.$cs.') ';
    }
  }
  

	/**
	 * parse_brackets
   * - parses balanced brackets [...]
	 *
	 * @return string output
	 */
  function parse_brackets() {
    
    if (TRACE) echo "--- parse_brackets()\n";
    
    if (! $this->is_next_token('['))  {
      $this->put_back();
      return '';
    }

    $start = $this->pos;
    $cs = '';
    $bracket = 1;
    // Find the matching close bracket ']':
    while ($bracket > 0) {
      $tt = $this->get_next_token($token, $value);
      if ($token == '[') $bracket++;
      if ($token == ']') $bracket--;
    }
    $end = $this->pos;
    $cs = $this->parse($start, $end);
    $tt = $this->get_token($token, $value);
    $this->put_back();
    return $cs;
    
  }
  
	/**
	 * parse_expression
   * - parses expression
	 *
   * @param int $end
	 * @return string output
	 */
  function parse_expression($end = -1) {

    if (TRACE) echo "--- parse_expression()\n";
    
    $cs = '';
    $done = FALSE;
    $ternary = FALSE;
    $array_def = FALSE;
    $parens = 0;
    $end = ($end == -1) ? $this->find_token(';') : $end;

    $tt = $this->get_next_token($token, $value);
  
    while (!$done) {
      
        if ($token == '(') $parens++;
        if ($token == ')') $parens--;
        if ($token == ';') $done = TRUE;
        if ($token == ',' && $parens == 0) {
          $done = TRUE;
          $cs .= $token;
        }
        if ($parens < 0) {
          $done = TRUE;
          if ($this->pos < $end) $cs .= $token;
        }
        if ($this->pos >= $end) $done = TRUE;
        
        if (!$done) {
          if ($token == '?') $ternary = TRUE;
          //  put all of the expression on one line?
          if ($token == 'T_ARRAY') $array_def = TRUE;
          if (($value == PHP_EOL) && ($array_def == FALSE)) $token = '';
        
          if ($tt == 0) break;
          $cs .= $this->parse_token($tt, $token, $value);
          $tt = $this->get_next_token($token, $value);

        }
    }
		return $ternary ? 'if '.$cs : $cs;
  }
  
	/**
	 * parse_parens
   * - parses balanced parenthesis (...)
	 *
	 * @return string output
	 */
  function parse_parens() {
    
    if (TRACE) echo "--- parse_parens()\n";
    // After we skip optional white space,
    //  the next token is open parenthesis '(':
    
    $this->is_next_token('(', TRUE);
    $start = $this->pos;
    $cs = '';
    $cm = '';
    $paren = 1;
    // Find the matching close parenthesis ')':
    while ($paren > 0) {
      $tt = $this->get_next_token($token, $value);
      if ($token == '(') $paren++;
      if ($token == ')') $paren--;

      //   move all comments to the next line
      if ($tt == Parser::TT_COMMENT) {
        $cm .= PHP_EOL.$this->parse_comment($token, $value);
        $this->tokens[$this->pos] = '';
      }
    }
    $end = $this->pos;
    
    $this->pos = $start;
    while ($this->pos < $end-1) {
      $cs .= $this->parse_expression($end);
    }
    $this->pos++;
    return $cs.$cm;
  }
  /**
	 * parse_statement - language constructs such
   * as echo do not require parenthesis.
	 *
	 * @param string $eq
   * @return string output
	 */
  function parse_statement() {
    
    if (TRACE) echo "--- parse_statement()\n";
    // After we skip optional white space,
    //  the next token is an optional open parenthesis '(':
    
    $cs = '';
    $tt = $this->get_next_token($token, $value);
    while ($token != ';') {
      if ($tt == 0) break;
      $cs .= $this->parse_token($tt, $token, $value);
      $tt = $this->get_next_token($token, $value);
    }
    $this->put_back();
    
    if (substr($cs,0,1) == "(") {
      $cs = substr($cs,1,strlen($cs)-2);
    }

    return $cs;
  }


	/**
	 * parse_until token is found
	 *
	 * @param string $eq
   * @return string output
	 */
  function parse_until($eq) {
    
    if (TRACE) echo "--- parse_until($eq)\n";
    
    $cs = '';
    $tt = $this->get_token($token, $value);
    
    while ($token != $eq) {
        if ($tt == 0) break;
        $cs .= $this->parse_token($tt, $token, $value);
        $tt = $this->get_next_token($token, $value);
    }
		return $cs;
  }

  /*
	 * parse_variable 
	 *
   * @return string output
	 */
  function parse_variable() {

    if (TRACE) echo "--- parse_variable()\n";

    $tt = $this->get_next_token($token, $value);
    $cs = $value.$this->parse_brackets();
    return $cs;
  }  
	/**
	 * parse_array - Supports both single and associative
	 *
	 * @param string $value
	 * @return string output
	 */
	function parse_array($value) {

    if (TRACE) echo "--- parse_array($value)\n";
    /*
     * array(
     *     key  => value,
     *     key2 => value2,
     *     key3 => value3,
     *     ...
     * )
     */
    
    $cs = '';
    $paren = 1;
    $hash = FALSE;
    $this->get_next_token($skip_token, $skip_value);
    $this->brace++;
    
    while ($paren > 0) {
      $tt = $this->get_next_token($token, $value);
      if ($token == ')') {
        $paren--;
      }
      else {
        if ($token == 'T_DOUBLE_ARROW') $hash = TRUE;
        if ($token == ',') {
          $this->get_next_token($next_token, $next_value);
          $this->put_back();
          if ($next_value != PHP_EOL)
            if ($tt == 0) break;
            $cs .= $this->parse_token($tt, $token, $value);
        }
        else {
          if ($tt == 0) break;
          $cs .= $this->parse_token($tt, $token, $value);
        }
      }
    }
    $this->brace--;
    if ($cs == '') $hash = TRUE;
    if ($hash) {
      if ($cs == '')
        return '{'.$cs.'}';
      else
        return $cs;
    }
    else {
      return '['.$cs.']';
    }
  }

	/**
	 * parse_case - 
   * 
   * reduce stacked case statements to:
   *  when value1, value2, ...
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_case() {
    
    if (TRACE) echo "--- parse_case()\n";
    
    $cs = array();
    $cm = array();
    $done = FALSE;
    $tt = $this->get_token($token, $value);
    while (!$done) {
      if ($token == 'T_CASE') {
        $tt = $this->get_next_token($token, $value);
        if ($tt == 0) break;
        $cs[] = $this->parse_token($tt, $token, $value);
        $this->is_next_token(':', TRUE);
        
        $mark = $this->pos;
        $tt = $this->get_next_token($token, $value);
        while ($token == 'T_COMMENT'
            || $token == 'T_WHITESPACE') {
          if ($value != PHP_EOL)
            $cm[] = $this->parse_token($tt, $token, $value);
          $tt = $this->get_next_token($token, $value);
        }
        if ($token != 'T_CASE') {
          $this->pos = $mark;
          $done = TRUE;
        }
      }
    }
    return 'when '.implode(',', $cs).implode($cm);
  }
  
	/**
	 * parse_class - 
	 *
	 * @param string $value
	 * @return string output
	 */
	function parse_class($value) {

    if (TRACE) echo "--- parse_class($value)\n";
    
    $this->scope = Parser::SCOPE_CLASS;
    $this->var_def[$this->scope] = array();

    $tt = $this->get_next_token($token, $value);
    
    if ($tt != Parser::TT_IDENTIFIER) {
      throw new Exception("Expected IDENTIFIER, found $value");
    }
    
    $cs = 'class '.$value;
    $this->class_name = $value;

    $tt = $this->get_next_token($token, $value);
    if ($token == 'T_EXTENDS') {
      $tt = $this->get_next_token($token, $value);
      if ($tt != Parser::TT_IDENTIFIER) {
        throw new Exception("Expected IDENTIFIER, found $value");
      }
      $cs .= ' extends '.$value;
    }
    else {
      $this->put_back();
    }

		$tt = $this->get_next_token($token, $value);
		while ($token != '{') {
      if ($tt == 0) break;
			$cs .= $this->parse_token($tt, $token, $value);
			$tt = $this->get_next_token($token, $value);
		}

		$brace = 1;
		$start = $this->pos;
		// Find the matching closing brace '}':
		while ($brace > 0) {
			$tt = $this->get_next_token($token, $value);
			if ($token == '{') $brace++;
			if ($token == '}') $brace--;
		}
		$end = $this->pos;
		$cs .= $this->parse($start+1, $end-1, 1);
		$cs .= "\nmodule.exports = {$this->class_name}";
    $this->class_name = '';
		return $cs;

  }

	/**
	 * parse_do - 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_do($value) {

    if (TRACE) echo "--- parse_do($value)\n";
    /*
     * do {
     *     statement;
     * } while (condition);
     */
    
    $this->parse_block($comment, $body);
    $tt = $this->get_next_token($token, $value);
    while ($token != 'T_WHILE') {
        $tt = $this->get_next_token($token, $value);
    }
    $cond = $this->parse_parens();
    return 'loop'.$body.'break unless '.$cond;
    
  }    

  /**
	 * parse_for - 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_for($value) {

    if (TRACE) echo "--- parse_for($value)\n";
    /*
     * for (expr1; expr2; expr3)
     *     statement
     *
     *
     *  for
     *
     */
    
  }    

	/**
	 * parse_function - 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_function($value) {

    if (TRACE) echo "--- parse_function($value)\n";
    
    $this->scope = Parser::SCOPE_FUNCTION;
    $this->var_def[$this->scope] = array();
    
    $this->get_next_token($token, $value);
    if ($token == '&') {
      $this->get_next_token($token, $value);
    }
		if ($value == '__construct') {
			$value = 'constructor';
		}

		if ($this->class_name != '') {
      $cs = "$value : ";
      $arrow = '->';
    }
    else {
      $cs = "exports.$value = $value = ";
      $arrow = '->';
    }
    $this->func_name = $value;
		if ($this->func_name == '__construct') {
			$this->func_name = 'constructor';
		}
    $args = $this->parse_arglist();
    $this->parse_block($comment, $body);
    return $cs.$args.$arrow.$comment.$body;
    
  }    

  /**
	 * parse_foreach - 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_foreach($value) {

    if (TRACE) echo "--- parse_foreach($value)\n";
    /*
     *  foreach (array_expression as $value)
     *    statement
     *
     *  foreach (array_expression as $key => $value)
     *    statement
     */    
    
    $with_key = FALSE;
    $key = '';
    $this->is_next_token('(', TRUE);
    $tt = $this->get_next_token($token, $value);
    $array = '';
		while ($token != 'T_AS') {
      if ($tt == 0) break;
			$array .= $this->parse_token($tt, $token, $value);
			$tt = $this->get_next_token($token, $value);
		}
//    if ($token == 'T_ARRAY') {
//      $array = $this->parse_token($tt, $token, $value);
//    }
		//TODO: Parse until T_AS

    //$this->is_next_token('T_AS', TRUE);
    $tt = $this->get_next_token($token, $value);
    
    if ($this->is_next_token('T_DOUBLE_ARROW')) {
      $key = $value;
      $tt = $this->get_next_token($token, $value);
      $with_key = TRUE;
    }
    else $this->put_back ();
    
    $this->is_next_token(')', TRUE);
    
    if ($with_key == TRUE) {
      $cs = "for $key, $value of $array";
    }
    else {
      $cs = "for $value in $array";
    }
    $this->parse_block($comment, $body);
    return $cs.$comment.$body;
  }    

	/**
	 * parse_if - 
   * 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_if($value) {

    if (TRACE) echo "--- parse_if($value)\n";
    
    // parse parens for conditional check
    $cond = ltrim($this->parse_parens());

    if ($this->parse_block($comment, $body)) {
      return 'if '.$cond.$comment.$body;
    }
    else {
      return 'if '.$cond.' then '.$body.$comment;
    }
    
  }
  
	/**
	 * parse_isset - 
   * 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_isset($value) {

    if (TRACE) echo "--- parse_isset($value)\n";

		$tt = $this->get_next_token($token, $value);
		if ($token != '(') throw new Exception("Expected (, found '$token'");

		$cs = '';
		$tt = $this->get_next_token($token, $value);
		while ($token != ')') {
      if ($tt == 0) break;
			$cs .= $this->parse_token($tt, $token, $value);
			$tt = $this->get_next_token($token, $value);
		}
    return $cs.'? ';
  }

	/**
	 * parse_list -
	 *
	 *
	 * @param string $value
	 * @return string output
	 */
	function parse_list($value) {

		if (TRACE) echo "--- parse_list($value)\n";

		$tt = $this->get_next_token($token, $value);
		if ($token != '(') throw new Exception("Expected (, found '$token'");

		$cs = '';
		$tt = $this->get_next_token($token, $value);
		while ($token != ')') {
      if ($tt == 0) break;
			$cs .= $this->parse_token($tt, $token, $value);
			$tt = $this->get_next_token($token, $value);
		}
		return '['.$cs.']';


	}
	/**
	 * parse_unset - 
   * 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_unset($value) {

    if (TRACE) echo "--- parse_unset($value)\n";
		$tt = $this->get_next_token($token, $value);
		if ($token != '(') throw new Exception("Expected (, found '$token'");

		$cs = '';
		$tt = $this->get_next_token($token, $value);
		while ($token != ')') {
      if ($tt == 0) break;
			$cs .= $this->parse_token($tt, $token, $value);
			$tt = $this->get_next_token($token, $value);
		}
		return 'delete '.$cs;

  }
  
	/**
	 * parse_static - emulate static declaration
   * 
   *  static x = array();
   * 
   *  exports.x = exports.x ? {}
   * 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_static($value) {

    if (TRACE) echo "--- parse_static($value)\n";
    
    if ($this->scope == Parser::SCOPE_CLASS) {
      $tt = $this->get_next_token($token, $value);
      return "@$value = @$value ? {}";
      
    }
    else {
      $this->var_def[Parser::SCOPE_SUPERGLOBAL][$value] = 0;

      $tt = $this->get_next_token($token, $value);
      if ($this->is_next_token('=')) {
        return "exports.$value = $value ? {}";
      }
      else {
        $this->put_back();
        return "exports.$value = $value ? {}";
      }
    }
  }
  
	/**
	 * parse_switch - 
	 *
	 * @param string $value
	 * @return string output
	 */
	function parse_switch($value) {
    
    if (TRACE) echo "--- parse_switch($value)\n";
    
    // parse parens for switch expression
    $cs[] = 'switch '.ltrim($this->parse_parens());
    // skip ahead to opening brace
    $tt = $this->get_next_token($token, $value);
    while ($token != '{') {
      if ($tt == 0) break;
      $cs[] = $this->parse_token($tt, $token, $value);
      $tt = $this->get_next_token($token, $value);
    }
    // find ending brace
    $start = $this->pos;
    $brace = 1;
    
    while ($brace > 0) {
      $tt = $this->get_next_token($token, $value);
      if ($token == '{') $brace++;
      if ($token == '}') $brace--;
    }
    $end = $this->pos;

    $this->pos = $start;
    $this->brace +=2;
    $incase = FALSE;
    
    $tt = $this->get_next_token($token, $value);
    while ($this->pos < $end) {
      
      if ($token == ':') {
        $token = '';
      }
      elseif ($token == 'T_BREAK') {
        $token = '';
      }
      elseif ($token == 'T_CASE') {
        $cs[] = $this->parse_case();
        $this->brace++;
        
      }
      elseif ($token == 'T_DEFAULT') {
        $this->brace++;
      }
      elseif ($value == PHP_EOL) {
        $this->get_next_token($next_token, $next_value);
        $this->put_back();
        if ($next_token == 'T_CASE' || $next_token == 'T_DEFAULT') {
          $this->brace--;
        }
      }
      if ($tt == 0) break;
      $cs[] = $this->parse_token($tt, $token, $value);
      $tt = $this->get_next_token($token, $value);

    }
    $this->brace -=2;
    return implode($cs);
  }
  
	/**
	 * parse_var - Member variables
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_var() {
    
    if (TRACE) echo "--- parse_var()\n";

    $tt = $this->get_next_token($token, $value);
    $value = substr($value,1);
    if ($this->is_next_token(';')) {
      $this->put_back();
			return $value.': {}';
    }
    else {
      $this->put_back();
      $this->is_next_token('=', TRUE);
      return $value.': '.$this->parse_expression();
    }
  }
  
	/**
	 * parse_while - 
   * 
	 *
	 * @param string $value
	 * @return string output
	 */
  function parse_while($value) {

    if (TRACE) echo "--- parse_while($value)\n";
    
    // parse parens for conditional check
    $cond = ltrim($this->parse_parens());
    $this->parse_block($comment, $body);
    return 'while '.$cond.$comment.$body;
  }

  /**
	 * parse_let
	 *
	 * @param string $value
	 * @return string
	 */
	function parse_let($value) {
    
    if (TRACE) echo "--- parse_let($value)\n";
    
    
    if ($this->arg_def == TRUE) {
      return ' = ';
    }
    // Skip reference operator = &
    $tt = $this->get_next_token($token, $value);
    if ($token != '&') $this->put_back ();
    return ' = '.$this->parse_expression();
  }
  
	/**
	 * open_bracket
	 *
	 * @param string $value
	 * @return string
	 */
	function parse_open_bracket($value) {
    
    if (TRACE) echo "--- parse_open_bracket($value)\n";
    
    if (!$this->is_next_token(']')) {
      $this->put_back();
      return '[';
    }
    
    if (!$this->is_next_token('=')) {
      $this->put_back();
      return '[]';
    }
    
    return '.push ';
  }
  
}
/* End of file Parser.php */
/* Location: ./tools/lib/Parser.php */
