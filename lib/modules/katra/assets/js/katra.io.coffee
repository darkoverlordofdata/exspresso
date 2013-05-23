#+--------------------------------------------------------------------+
#| io.coffee
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
# Module Katra.IO
#
#		Class Katra.IO.Input
#		Class Katra.IO.Output
#
##
class window.io
#
#	Class io.Input 
#
#		console input
#
class window.io.Input

	##
	#	Container element
	#
	#	@var object
	#
	win:	null
	##
	#	Input element
	#
	#	@var object
	#
	dom:	null
	
	##
	# Initialize the input console
	#
	# @param string		jQuery selector
	# @param object		owning object
	#
	constructor:	(selector, @parent) ->
		@win = $(selector)
		# import the jquery.console plugin
		@dom = $('<div class="runtime">')
		@win.append @dom
		
	##
	# Input list of variables from console.
	#
	# @param array	list of input variables
	#
	input: (p) ->
		@_io = @_input p, (iobuf) =>
			# callback to receive io
			@iobuf = iobuf
			return false
		return true
		
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

		io = @dom.console

			promptLabel: ">"
			continuedPromptLabel: ">>"
			promptHistory: true
			autofocus: true

			commandValidate: (line) ->
				if line is "" then return false else return true

			commandHandle: (line, report) ->
					io.continuedPrompt = false
					callback line
					return true
		
		return io


		
##
#
#	Class io.Output 
#
#		console output
#
class window.io.Output

	##
	#	Container element
	#
	#	@var object
	#
	win:	null
	##
	#	Input element
	#
	#	@var object
	#
	dom:	null
	
	##
	# Initialize the output console
	#
	# @param string		jQuery selector
	#
	constructor: (selector) ->
		@win = $(selector)
		@dom = $('<pre>')
		@win.append @dom
		
	##
	# scroll the window
	#
	scroll: () =>
		@win.scrollTop(99999999)

	##
	# Print line
	#
	#	@param	line to print
	#
	println: (line) =>
		line ?= ''
		@dom.append "#{line}\n"

	##
	# Print value
	#
	#	@param	value to print
	#
	print: (value) =>
		value ?= ''
		@dom.append value

