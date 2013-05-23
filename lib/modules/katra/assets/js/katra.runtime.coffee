#+--------------------------------------------------------------------+
#| runtime.coffee
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
# Class Katra.Runtine
#
#	Basic p-code runtime.
# Executes the parsed code object.
#
#

class window.Runtime

	##
	# Constants:
	#
	GOSUB      = 1     #	Stack frame identifier: Gosub..Return
	FOR        = 2     #	Stack frame identifier: For..Next


	##
	# protected instance members. 
	#		other than the constructor, all public members 
	#		are Basic keywords, functions, or variables.
	#
	
	##
	#	End of program flag
	#
	#	@var object
	#
	_eop:     false   
	##
	#	Option base value
	#
	#	@var object
	#
	_base:    0				
	##
	#	Program counter
	#
	#	@var object
	#
	_pc:      0       
	##
	#	Program stack
	#
	#	@var object
	#
	_stack:   []      
	##
	#	Parsed code
	#
	#	@var object
	#
	_pcode:   []      
	##
	#	Exception
	#
	#	@var object
	#
	_e:       "" 
	##
	#	Throttle
	#
	#	@var object
	#
	_limit:   -1
	##
	#	Benchmarker
	#
	#	@var object
	#
	_bench:   null    
	##
	# Input handler
	#
	#	@var object
	#
	_io:			null		
	##
	# Environment
	#
	#	@var object
	#
	_env:			null		
	##
	#	Debug flag
	#
	#	@var object
	#
	_TRACE:		false		

	##
	#	LET helper for string declared with DIM statement
	#
	#		@param 	start	Start character position
	#		@param 	end		End character position
	#		@param 	value	New value
	#		@return this
	#
	#
	Array::$ = (start, end, value) ->

		if not value?
			value = end
			end = value.length-1

		if typeof value is "string"

			for char in value.split("")
				if start <= end
					this[start++] = char
		else
		
			for char in value
				if start <= end
					this[start++] = char

		return this

	##
	#	Create new Basic Runtime
	#
	#	@param	object	environment
	#	@param	array		parsed code array
	#
	constructor: (@_env, @_pcode, @_TRACE) ->


	##
	# Print to log
	#
	#	@param	line to log
	#
	_log: (line) ->
		@_env.logger.println line

	##
	# Print to basic console.
	#
	#	@param	value to print
	#
	_print: (value) ->
		if typeof value is "number"
			@_env.output.print " #{value}"
		else
			@_env.output.print value

	##
	#	Input - Perform basic console input; callback when done.
	#
	#	@param	array			list of variables
	# @param	function	completion callback 
	# @return input handler
	#
	_input: (p, callback) ->
	
		io_buf = []
		if @_io? then return @_io

		io = @_env.input.console

			promptLabel: ">"
			continuedPromptLabel: ">>"
			promptHistory: true
			autofocus: true

			commandValidate: (line) ->
				if line is "" then return false else return true

			commandHandle: (line, report) ->
				io_buf.push item for item in line.split(",")
				if io_buf.length < p.vars.length
					io.continuedPrompt = true
					return 
				else
					io.continuedPrompt = false
					callback line.split(",")
					return true
		
		return io
		
	##
	#	Run - execute the compiled code
	#
	#	@param	boolean		(Optional) Set true when waiting for I/O 
	#
	_run: (wait) =>

		if not wait? # the first time run, wait is undefined

			@_bench = new Benchmark()
			@_bench.mark 'start'

		wait = false
		try
			until @_eop or wait

				code 	= @_pcode[@_pc]
				@_pc 	= @_pc + 1

				if @_TRACE
					@_log "#{code.lineno} #{code.keyword} #{code.src}"
					#@_log "\t#{JSON.stringify(code.data)}" if code.data?

				wait = @[code.keyword](code.data)
				@_eop = true if @_pc >= @_pcode.length

				if @_limit >= 0
					@_limit -=1
					@_eop = true if @_limit < 0

		catch ex 

			@_e = "#{ex.message} at line #{code.lineno}\n#{code.lineno} #{code.keyword} #{code.src}"
			wait = false

		@_env.output.scroll()
		@_env.logger.scroll()
		
		if not wait

			@_bench.mark 'end'
			x = @_bench.elapsed_time 'start','end'

			if @_TRACE
				@_log @_bench.marker['start']
				@_log @_bench.marker['end']
				@_log "Elapsed: #{x} ms"
			if @_e isnt ""
				if @_TRACE
					@_log "Exception : #{@_e}"
				for e in @_e.split("\n")
					@_io.notice e if e?

	##
	# The following methods execute built in Basic functions:
	#

	ABS: (n) ->
		return Math.abs(n)
	ATN: (n) ->
		return Math.atan(n)
	COS: (n) ->
		return Math.cos(n)
	EXP: (n) ->
		return Math.exp(n)
	INT: (n) ->
		return Math.floor(n)
	LOG: (n) ->
		return Math.log(n)
	RND: (n) ->
		return Math.random()
	SGN: (n) ->
		if n < 0
			return -1
		else if n > 0
			return 1
		else
			return 0
	SIN: (n) ->
		return Math.sin(n)
	SQR: (n) ->
		return Math.sqrt(n)
	SUBSTR: (str, start, end) ->
		return str.slice(start, end)
	TAB: (n) ->
		t = []
		t[i] = " " for i in [0..n-1]
		return t.join('') 
	TAN: (n) ->
		return Math.tan(n)
	TIM: (n) ->
		d = new Date()
		if n is 0
			return d.getMinutes()
		else 
			return d.getSeconds()

	##
	# The following methods execute Basic keywords:
	#

	##
	# Sets basic's option base. Typically set to zero, 
	# this is the index of the first available array element.
	#
	#	@param array	parameter list
	#
	BASE: (p) ->
		@_base = p.base
		return false

	##
	# Declare embeded data values.
	#
	#	@param array	parameter list
	#
	DATA: (p) ->
		return false

	##
	# Define a named function.
	#
	#	@param array	parameter list
	#
	DEF: (p) ->
		@[p.name] = new Function(p.param, p.body)
		return false

	##
	# Dimension array variable.
	#
	#	@param array	parameter list
	#
	DIM: (p) ->
		for array in p
			name = array.name
			dims = array.dims		
			init = array.init
			@[name] = []
			switch dims.length
				when 1
					for dim1 in [@_base..dims[0]]
						@[name][dim1] = init
				when 2
					for dim1 in [@_base..dims[0]]
						@[name][dim1] = []
						for dim2 in [@_base..dims[1]]
							@[name][dim1][dim2] = init
		return false

	##
	# End of program.
	#
	#	@param array	parameter list
	#
	END: (p) ->
		@_eop = true
		return false

	##
	# For..Next Loop
	#
	#	@param array	parameter list
	#
	FOR: (p) ->
		@[p.name] = eval(p.start)
		@_stack.push {
			id:		FOR
			pc:		@_pc
			name: 	p.name
			end:	eval(p.end)
			step:	eval(p.step)
		}
		return false

	##
	# Gosub
	#
	#	@param array	parameter list
	#
	GOSUB: (p) ->
		@_stack.push {
			id:		GOSUB
			pc:		@_pc
		}
		@_pc = p.pc
		return false

	##
	# Goto
	#
	#	@param array	parameter list
	#
	GOTO: (p) ->
		@_pc = p.pc[eval(p.x)]
		return false

	##
	# If condition:
	#
	#	@param array	parameter list
	#
	IF: (p) ->
		if eval(p.if) then @_pc = p.pc
		return false

	##
	# Image has no runtime behavior.
	#
	#	@param array	parameter list
	#
	IMAGE: (p) ->
		return false

	##
	# Input list of variables from console.
	#
	#	@param array	parameter list
	#
	INPUT: (p) ->
		@_io = @_input p, (iobuf) =>
			# callback to receive io
			if iobuf?
				for name, i in p.vars
					@[name] = iobuf[i]
				@_print "\n"
			@_eop = false
			@_run true
			return false
		return true

	##
	# Let variable assignment.
	#
	#	@param array	parameter list
	#
	LET: (p) ->
		eval(p.x)
		return false

	##
	# Mat matrix assignment.
	#
	#	@param array	parameter list
	#
	MAT: (p) ->
		switch p.value
			when "ZER" then v = 0
			else return false

		name = p.name
		if @[name]?
			for i in [0..@[name].length-1]
				if Array.isArray(@[name][i])
					for j in [0..@[name][i].length-1]
						@[name][i][j] = v
				else
					@[name][i] = v
		else
		# default array size is 10
			@[name] = [v,v,v,v,v,v,v,v,v,v,v]
		return false

	##
	# For..Next Loop
	#
	#	@param array	parameter list
	#
	NEXT: (p) ->
		frame = @_stack[@_stack.length-1]

		if frame.id isnt FOR
			throw "Next without for"

		name = p.name
		if frame.name isnt name
			throw "Mismatched For/Next #{name}"

		counter = @[name] + frame.step
		@[name] = counter

		if counter > eval(frame.end)
			@_stack.pop()
		else
			@_pc = frame.pc
		return false

	##
	# Print list of items
	#
	#	@param array	parameter list
	#
	PRINT: (p) ->
		if p.lineno is ""
			for item in p.iolist
				if item.length is 1
					@_print item
				else
					@_print eval(item)
		else
			template = @_pcode[p.pc].p.template
			io = []
			for item in p.iolist
				io.push eval(item)
			@_print template({io:io})
		return false

	##
	# Randomize has no runtime behavior
	#
	#	@param array	parameter list
	#
	RANDOMIZE: (p) ->
		return false

	##
	# Comment has no runtime behavior
	#
	#	@param array	parameter list
	#
	REM: (p) ->
		return false

	##
	# Read embedded data into variable list
	#
	#	@param array	parameter list
	#
	READ: (p) ->
		return false

	##
	# Return from gosub
	#
	#	@param array	parameter list
	#
	RETURN: (p) ->
		frame = @_stack.pop()
		while frame.id isnt GOSUB
			frame = @_stack.pop()
		@_pc = frame.pc
		return false

	##
	# Stop program execution
	#
	#	@param array	parameter list
	#
	STOP: (p) ->
		@_eop = true
		throw Error("STOP")
		return false

