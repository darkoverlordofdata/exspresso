#+--------------------------------------------------------------------+
#| katra.coffee
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
#	The Katra Application
#
#

##
#
#	Class CodeModel 
#
#		load and execute basic code.
#
class CodeModel extends Backbone.Model

	# Default attributes for the CodeModel.
	defaults:
      source: ''
			prog:		null

	##
	# Execute the code
	#
	run: () ->
		# queue the program to run:
		window.setTimeout @get('prog').run, 10
		
	##
	# Load the source code
	#
	#	@param object		interface to environment
	# @param string		program source code
	#
	load: (env, source) ->
		@set 'source' : source
		@set 'prog': new Basic(env, source, true)
		return @get('prog')
		
class Console

	constructor: (node) ->
		dom = $('<div class="runtime">')
		$(node).append dom
		@con = dom.console
			promptLabel: "repl>"
			continuedPromptLabel: "repl>>"
			welcomeMessage: "*** Katra Basic REPL ***"
			promptHistory: true
			autofocus: true
			commandValidate: @commandValidate
			commandHandle: @commandHandle

	print: (str) => 
		str ?= ''
		mesg = $('<div class="jquery-console-message"></div>')
		mesg.filledText(str).hide()
		@con.inner.append(mesg)
		mesg.show()

	println: (str) => 
		str ?= ''
		@print "#{str}\n"
	
	read: (@callback) =>
	
	commandHandle: (line, report) =>
		if @callback? then @callback line

	commandValidate: (line) ->
		if line is "" then return false else return true


## 
#
#	Class MainView 
#
#
class MainView extends Backbone.View

	##
	#	@var object
	#
	input:	null
	##
	#	@var object
	#
	output:	null
	##
	#	@var object
	#
	logger:	null
	##
	#	@var boolean
	#
	enabled:	true
	##
	#	@var object
	#
	el: $('#katra-menu')

	##
	#	@var object
	#
	events: 
		'click .katra-run':		'run'

	##
	# Set up the environment
	#
	#	@param object		code model
	#
	initialize: (@model) ->
		# logging
		@logger = new io.Output('.katra-logger-panel')
		# repl i/o
		@read = new io.Input('.katra-read-panel')
		@print = new io.Output('.katra-print-panel')
		# program i/o
		@input = $('<div class="runtime">')
		$('.katra-input-panel').append @input
		@output = new io.Output('.katra-output-panel')
		@prog = @model.load @, $('#katra-source').text()
		@repl()
		
	##
	# Render the view
	#
	render: () ->
		# nothing to do

	##
	# REPL - Read/Eval/Print Loop
	#
	repl: () =>
		dom = $('<div class="runtime">')
		$('.katra-repl-panel').append dom
		@console = dom.console
			promptLabel: "repl>"
			continuedPromptLabel: "repl>>"
			welcomeMessage: "*** Katra Basic REPL ***"
			promptHistory: true
			autofocus: true
			commandValidate: @commandValidate
			commandHandle: @commandHandle
			

	commandHandle: (line, report) ->
		inner = $('div .jquery-console-inner')
		mesg = $('<div class="jquery-console-message"></div>')
		mesg.filledText("some more data\n\n").hide()
		inner.append(mesg)
		mesg.show()
		inner.append 
		try
			ret = eval(line)
			if ret?	then return "\nand the answer is #{ret.toString()} ..." else return true
		catch e
			return e.toString()

	commandValidate: (line) ->
		if line is "" then return false else return true


	##
	# UI Event Handler
	#
	#	@param object		event object
	#
	run: (event) =>
		if @enabled is true
			# Make sure we can't click run again
			@enabled = false
			# run the code model
			window.setTimeout @prog.run, 10
			#@model.run() 
		
	##
	# Disable run
	#
	disable: () ->
		@enabled = false
		
##
#	Main application routing.
#
#
class Main extends Backbone.Router

	##
	#	@var object
	#
	routes: 
		''		: 'index'

	##
	# Index
	#
	index: ->
		@mainView.render()
		
	##
	# Initialize the application
	#
	initialize: ->
		@code = new CodeModel 
		@mainView = new MainView @code

##
# Start the application on document ready
$ ->
	main = new Main
	Backbone.history.start()
	prettyPrint()
