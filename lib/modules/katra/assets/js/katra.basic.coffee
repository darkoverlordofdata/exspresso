#+--------------------------------------------------------------------+
#| basic.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# Class Katra.Basic
#
#	Parse a Basic program, producing a p-code object
#	that may be executed.
#

class window.Basic

	##
  #	token_type values:
	#
	DELIMITER	  =1
	IDENTIFIER 	=2
	NUMBER    	=3
	KEYWORD   	=4
	STRING		  =5
	##
	#	KEYWORDS
	#
	BASE 		    =1
	DATA 		    =2
	DEF    		  =3
	DIM  		    =4
	END   		  =5
	FOR  		    =6
	GOTO   		  =7
	GOSUB  		  =8
	IF   		    =9
	IMAGE		    =10
	INPUT 		  =11
	LET 		    =12
	MAT 		    =13
	NEXT		    =14
	PRINT		    =15
	RANDOMIZE	  =16
	READ		    =17
	REM			    =18
	RETURN		  =19
	STOP		    =20

	KEYWORDS = {

		BASE: 		BASE
		DATA: 		DATA
		DEF:		  DEF
		DIM:		  DIM
		END:		  END
		FOR:		  FOR	
		GOTO:		  GOTO
		GOSUB:		GOSUB
		IF:			  IF
		IMAGE:		IMAGE
		INPUT:		INPUT
		LET:		  LET
		MAT:		  MAT
		NEXT:		  NEXT
		PRINT:		PRINT
		RANDOMIZE:RANDOMIZE	
		READ:		  READ
		REM:		  REM
		RETURN:		RETURN
		STOP:		  STOP
	}

	##
	#	isalpha
	#
	#		@param 	c		character to test
	#		@return true	if in [a-zA-Z]
	#
	isalpha = (char) ->
		if (char >= 'a' and char <= 'z') or (char >= 'A' and char <= 'Z') then return true else return false

	##
	#	isdelim
	#
	#		@param 	c		character to test
	#		@return true	if char is a delimiter
	#
	isdelim = (char) ->
		if " .!;,+-<>'/*%^=()[]\t\r\n".indexOf(char) is -1 then return false else return true

	##
	#	isdigit
	#
	#		@param 	c		character to test
	#		@return true	if in [0-9]
	#
	isdigit = (char) ->
		if char >= '0' and char <= '9' then return true else return false

	##
	#	iswhite
	#
	#		@param 	c		character to test
	#		@return true	if char is space or tab
	#
	iswhite = (char) ->
		if char is " " or char is "\t" then return true else return false

	##
	#	Compiled p-code
	#
	#	@var object
	#
	pcode:		  []			  
	##
	#	Symbol list
	#
	#	@var object
	#
	sym:				[]
	##
	#	Line number index
	#
	#	@var object
	#
	labels:		  {}	      
	##
	#	Symbol table
	#
	#	@var object
	#
	symtbl:	    {}
	##
	#	Interface to the environment
	#
	#	@var object
	#
	env:				null			
	##
	#	DELIMITER, IDENTIFIER, NUMBER, KEYWORD, STRING
	#
	#	@var object
	#
	token_type: 0 			  
	##
	#	Token value
	#
	#	@var object
	#
	token:      0 			  
	##
	#	Current position in prog
	#
	#	@var object
	#
	pos: 		    0					
	##
	#	Line termination character
	#
	#	@var object
	#
	eol:		    "\n"		  
	##
	#	Buffer termination character
	#
	#	@var object
	#
	eot:		    "\x00"    
	##
	#	Exception
	#
	#	@var object
	#
	e:					''		
	##
	#	Debug flag
	#
	#	@var object
	#
	TRACE:		  false

	##
	#	BASIC Recursive descent parser
	#
	#	@param object		Interface to environment
	#	@param string		Basic program text
	#	@param boolean	debug flag
	#
	constructor: (@env, code, @TRACE = false) ->

		bench = new Benchmark()
		bench.mark 'start'
		@e = ''

		try

			@load code

		catch ex 

			@e = ex.message
			@env.disable()

		finally

			bench.mark 'end'
			x = bench.elapsed_time 'start','end'

			start_time = new Date(bench.marker['start'])
			end_time = new Date(bench.marker['end'])
			st = start_time.toLocaleTimeString() + (start_time.getMilliseconds()/1000).toString().substr(1)
			et = end_time.toLocaleTimeString() + (end_time.getMilliseconds()/1000).toString().substr(1)
			@env.logger.println "Start time: #{st}"
			@env.logger.println "End time  : #{et}"
			@env.logger.println ""
			@env.logger.println "     Symbols"
			@env.logger.println "name string array"
			@env.logger.println "================="
			for sym in @sym
				@env.logger.println "#{sym}    #{@symtbl[sym].string}  #{@symtbl[sym].array}"
			@env.logger.println ""
			@env.logger.println "Compiled #{@pcode.length} lines in #{x} ms."
			@env.logger.println "Exception   : #{@e}" unless @e is ''
			
				

	##
	#	An expression to the right of the equal sign
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return string	javascript expression
	#
	rvar: (tokens, types) ->

		isstring = false
		isarray = false
		for token, i in tokens
			if types[i] is STRING
				tokens[i] = "\"#{token}\""
				isstring = false
				isarray = false
			else 
				switch token
					when "=" 	then tokens[i] = "==="
					when "<>" 	then tokens[i] = "!=="
					when "AND"	then tokens[i] = "&&"
					when "NOT"	then tokens[i] = "!"
					when "OR"	then tokens[i] = "||"
					when ","	
						if isstring is false
							tokens[i] = "]["
					when "["
						if isstring
							tokens[i] = ".slice("
					when "]"
						if isstring
							if isarray
							 tokens[i] = ").join(\"\")"
							else
							 tokens[i] = ")"
							isstring = false
					else
						if types[i] is IDENTIFIER
							tokens[i] = "this.#{token}"
							if token.indexOf("$") isnt -1
								isstring = true
								if @symtbl[token]? then isarray = true else isarray = false

		return tokens.join("")

	##
	#	An expression to the left of the equal sign
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return string	javascript expression
	#
	lvar: (tokens, types) ->

		isstring = false
		for token, i in tokens
			switch token
				when "=" 	then tokens[i] = "==="
				when "<>" 	then tokens[i] = "!=="
				when "AND"	then tokens[i] = "&&"
				when "NOT"	then tokens[i] = "!"
				when "OR"	then tokens[i] = "||"
				when ","	
					if isstring is false
						tokens[i] = "]["
				when "["
					if isstring
						tokens[i] = "("
				when "]"
					if isstring
						tokens[i] = ""

				else
					if types[i] is IDENTIFIER
						tokens[i] = "this.#{token}"
						if token.indexOf("$") isnt -1
							isstring = true

		return tokens.join("")
	
	##
	# Decode a list of io items
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@param 	boolean	print using flag
	#	@return array		javascript expressions
	#
	iolist: (tokens, types, using) ->

		list = []
		item_tokens = []
		item_types = []
		indent = 0
		nocr = false
		#
		#	@iolist items are seperated by:
		#		beginning of new variable or constant
		#		or by , or ; when bracket indent is 0
		for token, i in tokens

			if types[i] is STRING
				while token.indexOf(" ") isnt -1
					token = token.replace(" ", "&nbsp;")

			if types[i] is DELIMITER and (token is "[" or token is "(")  then indent +=1

			if indent is 0

				if types[i] isnt DELIMITER
					if item_tokens.length > 0
						list.push @rvar(item_tokens, item_types)
						item_tokens = []
						item_types = []
						nocr = false

				if types[i] is DELIMITER and token is ","

					list.push "\t" unless using
					nocr = true

				else if types[i] is DELIMITER and token is ";"
 
					nocr = true

				else

					item_tokens.push token
					item_types.push types[i]

			else

				item_tokens.push token
				item_types.push types[i]

			if types[i] is DELIMITER and (token is "]" or token is ")") then indent -=1

		if item_tokens.length > 0
			list.push @rvar(item_tokens, item_types)
		list.push "\"<br/>\"" unless nocr or using
		return list

	##
	# Execute the program
	#
	run: () =>

		rte = new Runtime(@env, @pcode, @TRACE)
		rte._run()

	##
	#	Load - scan program text into parsed-code
	#
	#	@param 	string	Basic program text
	#
	load: (text) ->

		# What is the end of line byte sequence?
		if text.indexOf('\r\n') >= 0		#	CRLF
			@eol = "\r"
			@eol_len = 2
		else if text.indexOf('\r') >= 0	#	CR
			@eol = "\r"
			@eol_len = 1
		else if text.indexOf('\n') >= 0	#	LF
			@eol = "\n"
			@eol_len = 1
		else	# *** Unknown ***
			throw Error("No EOL found")

		@pcode = []
		@prog = text.split("")
		@prog.push @eot
		@pos = 0
		keyword = ""

		while keyword isnt "END"

			switch @get_token()
				when NUMBER

					lineno = @token
					switch @get_token() 
						when KEYWORD
							keyword = @token
						when IDENTIFIER
							keyword = "LET"
							@put_back()
						else
							throw "Expected KEYWORD or IDENTIFIER, found #{@token}"

				when KEYWORD
					
					lineno = ""
					keyword = @token

				when IDENTIFIER

					lineno = ""
					keyword = "LET"
					@put_back()

				when DELIMITER

					switch @token
						when @eol
							lineno = ""
							keyword = ""
						when @eot
							return
						else
							throw "Expected EOL, found #{@token}"


				else
					throw "Expected KEYWORD or IDENTIFIER, found #{@token}"

			tokens = []
			types = []

			while @token isnt @eol
				@get_token()
				if @token isnt @eol
					types.push @token_type
					tokens.push @token

			# log.println "|#{lineno}|#{keyword}|#{tokens.join('|')}|"

			if keyword isnt ""

				@labels[lineno] = @pcode.length

				@pcode.push {

					lineno:		lineno
					keyword: 	keyword
					src:			tokens.join(" ")

					opcode:		KEYWORDS[keyword]
					data:			@[keyword](tokens, types)
				}

		# dereference target labels
		for line in @pcode

			switch line.opcode

				when GOSUB
					line.data.pc = @labels[line.data.lineno]

				when GOTO
					line.data.pc[i] = @labels[lineno] for lineno, i in line.data.lineno

				when IF
					line.data.pc = @labels[line.data.lineno]

				when PRINT
					if line.data.lineno isnt ""
						line.data.pc = @labels[line.data.lineno]

	##
	# Put the last token back on the code text stream
	#
	put_back: () ->
		@pos = @pos - @token.length


	##
	# Get the next token from the code text stream
	#
	get_token: () ->

		@token = ""
		@token_type = 0

		# skip leading white space
		@pos+=1 while iswhite(@prog[@pos])

		# check for end of line
		char = @prog[@pos]
		if char is @eol
			@token = @eol
			@pos+=@eol_len
			return @token_type = DELIMITER

		# check for end of program
		if char is @eot
			@token = @eot
			return @token_type = DELIMITER

		# check for multi-character operators (<= >= <>)
		switch char

			when "<"

				if @prog[@pos+1] is "="
					@token = "<="
					@pos+=2
					return @token_type = DELIMITER

				if @prog[@pos+1] is ">"
					@token = "<>"
					@pos+=2
					return @token_type = DELIMITER

			when ">"

				if @prog[@pos+1] is "="
					@token = ">="
					@pos+=2
					return @token_type = DELIMITER

		# check for other operators or delimiters
		if isdelim(char)

			@token = char
			@pos+=1
			return @token_type = DELIMITER

		# token is a quoted string
		if char is "\""

			@pos+=1
			temp = []
			while (@prog[@pos] isnt "\"")
				temp.push @prog[@pos]
				@pos+=1
				if @prog[@pos] is "\\"
					temp.push @prog[@pos]

			@pos+=1
			@token = temp.join("")
			return @token_type = STRING

		# token is a number
		if isdigit(char)

			temp = []
			while isdigit(@prog[@pos])
				temp.push @prog[@pos]
				@pos+=1
			@token = temp.join("")
			return @token_type = NUMBER

		# token is either a keyword or identifier
		if isalpha(char)

			temp = []
			until isdelim(@prog[@pos])
				temp.push @prog[@pos]
				@pos+=1
			@token = temp.join("")

			if KEYWORDS[@token]?
				@token_type = KEYWORD
			else
				@token_type = IDENTIFIER

		return @token_type

	##
	#	The following methods all compile individual keyword statements:
	#

	##
	# Parse the expression to define the option base
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	BASE: (tokens, types) ->
		return  {
			base: tokens[1]
		}

	##
	# Embedded data.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	DATA: (tokens, types) ->
		for token, i in tokens
			if types[i] is STRING
				tokens[i] = "\"#{token}\""
		return {
			items: tokens
		}

	##
	# Define a function. 1 line functions only are allowed.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	DEF: (tokens, types) ->
		return {
			name: 	tokens[0]
			param:	tokens[2]
			body:	"return #{@rvar(tokens.slice(5), types.slice(5))};"
		}


	##
	# Declare array arrays and strings.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	DIM: (tokens, types) ->
		data = []
		i = 0
		v = 0

		while i < tokens.length

			name = tokens[i]
			isstring = name.indexOf("$") != -1
			if isstring then v = " "
			@sym.push name
			@symtbl[name] = {
				name:	name
				string:	isstring
				array:	true
			}

			if tokens[i+3] is ","
				data.push {
					name:	name
					string:	isstring
					init: v
					dims:	[parseInt(tokens[i+2], 10)+1, parseInt(tokens[i+4], 10)+1]
				}
				i+=7
			else
				data.push {
					name:	name
					string:	isstring
					init: v
					dims:	[parseInt(tokens[i+2], 10)+1]
				}
				i+=5

		return data

	##
	# End should be the last statement in the data.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	END: (tokens, types) ->	

	##
	# Head of FOR..NEXT loop
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	FOR: (tokens, types) ->
		for i in [2..tokens.length-1]

			if tokens[i] is "TO"
				return {
					name: 	tokens[0]
					start: 	@rvar(tokens.slice(2, i), types.slice(2, i))
					end:	@rvar(tokens.slice(i+1), types.slice(i+1))
					step:	"1"
				}

	##
	# Call subroutine. No parameters are passed.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	GOSUB: (tokens, types) ->
		return {
			lineno: tokens[0]
			pc: 	tokens[0]
		}

	##
	# Jump to LineNo
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	GOTO: (tokens, types) ->
		if tokens.length is 1
			return {
				lineno: [tokens[0]]
				pc: 	[tokens[0]]
				x:		0
			}

		for token, i in tokens
			if token is "OF"
				return {
					lineno: tokens.slice(i+1).join("").split(",")
					pc: 	tokens.slice(i+1).join("").split(",")
					x:		@rvar(tokens.slice(0, i), types.slice(0, i))
				}

	##
	# Conditional Goto
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	IF: (tokens, types) ->
		for token, i in tokens
			if token is "THEN" or token is "GOTO"
				return {
					lineno:	tokens[i+1]
					pc:		tokens[i+1]
					if:		@rvar(tokens.slice(0, i), types.slice(0, i))
				}


	##
	# Print Using Template
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	IMAGE: (tokens, types) ->

		mask = "<%= io[..] %>"
		index = 0
		list = []
		parens = false
		i = 0
		while i < types.length

			switch types[i] 

				when STRING
					list.push tokens[i]
					i +=1

				when DELIMITER

					if tokens[i] is ")"

						c = group.join("")
						list.push c for k in [1..count]
						parens = false

					i +=1

				when NUMBER

					j = i+1
					if types[j] is DELIMITER and tokens[j] is "("

						count = tokens[i]
						parens = true
						group = []

					else

						switch tokens[j]
							when "A" then c = mask
							when "D" then c = mask
							when "X"
								c = []
								c.push " " for k in [1..tokens[i]]
								c = c.join("")


						if parens then group.push c else list.push c

					i+= 2

				else

					switch tokens[i]
						when "A" then c = mask
						when "D" then c = mask
						when "X" then c = " "

					if parens then group.push c else list.push c
					i +=1


		index = 0
		list = list.join("")
		while list.indexOf(mask) isnt -1
			list = list.replace(mask,"<%= io[#{index}] %>")
			index +=1

		return {
			"template": _.template(list)
		}

	##
	# Accept input from the user.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	INPUT: (tokens, types) ->
		vars = []

		for token in tokens
			vars.push token unless token is "," 
		return {
			vars: vars
		}


	##
	# Assign value to variable storage.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	LET: (tokens, types) ->
		list = []
		item_tokens = []
		item_types = []

		for token, i in tokens

			if token is "="
				list.push @lvar(item_tokens, item_types)
				item_tokens = []
				item_types = []
			else
				item_tokens.push token
				item_types.push types[i]

		value = @rvar(item_tokens, item_types)

		isstring = false
		if @symtbl[tokens[0]]?
			sy = @symtbl[tokens[0]]
			isstring = sy.string and sy.array

		if isstring
			strs = []
			for item in list
				if item.indexOf("(") is -1
					strs.push("#{item}.$(1,#{value})")
				else
					a = item.split("(")
					strs.push("#{a[0]}.$(#{a[1]},#{value})")
			return {
				x:	strs.join(";")
			}
		else
			list.push value
			return {
				x:	list.join("=")
			}


	##
	# Matrix manipulation
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	MAT: (tokens, types) ->
		return {
			name:	tokens[0]
			value:	tokens[2]
		}

	##
	# Foot of FOR..NEXT loop
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	NEXT: (tokens, types) ->
		return {
			name:	tokens[0]
		}

	##
	# Display variables and/or text
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	PRINT: (tokens, types) ->
		if tokens[0] is "USING"
			return {
				lineno: tokens[1]
				iolist:	@iolist(tokens.slice(3), types.slice(3), true)
			}
		else
			return {
				lineno:	""
				iolist:	@iolist(tokens, types, false)
			}

	##
	# Seed the random number generator.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	RANDOMIZE: (tokens, types) ->

	##
	# Read embeded data into list of variables.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	READ: (tokens, types) ->

	##
	# Comments.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	REM: (tokens, types) ->

	##
	# Return from GOSUB
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	RETURN: (tokens, types) ->

	##
	# Stop Execution before END is reached.
	#
	#	@param 	array		list of parsed tokens
	#	@param 	array		parsed token types
	#	@return array		parsed code
	#
	STOP: (tokens, types) ->

