#+--------------------------------------------------------------------+
# Cakefile
#+--------------------------------------------------------------------+
# Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# Cakefile
#
{exec} = require "child_process"
bcrypt = require('bcrypt')
fs = require('fs')

# ANSI Terminal Colors.
bold = ''
red = ''
green = ''
reset = ''
unless process.env.NODE_DISABLE_COLORS
  bold  = '\x1B[0;1m'
  red   = '\x1B[0;31m'+bold
  green = '\x1B[0;32m'+bold
  reset = '\x1B[0m'

#
# generate password salt & hash values
#
option '-p', '--pwd [PWD]', 'password value'
option '-d', '--db [sqlite]', 'datbase group to use'

task "generate:password", "password data generator", (options) ->

  pwd = options.pwd or 'password'

  salt = bcrypt.genSaltSync(10)
  hash = bcrypt.hashSync(pwd, salt)

  console.log red+'salt = |'+green+salt+red+'|'
  console.log red+'hash = |'+green+hash.substr(salt.length)+red+'|'+reset


#
# Build the preview - requires valac
#
task "build:preview", "build webkit previewer", ->

  #
  # compile desktop.vala
  #
  console.log 'Building bin/preview...'
  exec "valac --pkg gtk+-3.0 --pkg webkitgtk-3.0 --thread src/preview.vala --output=bin/preview", (err, output) ->
    console.log output
    if err?
      console.log err.message
    else
      console.log 'Ok.'


#
# Build the desktop app  - requires valac
#
task "build:desktop", "build desktop launcher", (options) ->

  options.db = 'sqlite' unless options.db?
  #
  # compile desktop.vala
  #
  console.log 'Building bin/desktop...'
  exec "valac --pkg gtk+-3.0 --pkg webkitgtk-3.0 --thread src/desktop.vala --output=bin/desktop", (err, output) ->
    console.log output
    if err?
      console.log err.message
    else

      exspresso_path = process.cwd()

      #
      # create the shell file
      #
      console.log 'Building exspresso.sh...'
      bash = [
        "#!/usr/bin/env bash"
        "cd #{exspresso_path}"
        "/usr/bin/node #{exspresso_path}/exspresso --db #{options.db} --desktop"
      ].join('\n')

      fs.writeFileSync  "#{exspresso_path}/exspresso.sh", bash
      fs.chmodSync      "#{exspresso_path}/exspresso.sh", 0o0775

      #
      # create the desktop icon
      #
      console.log 'Building Exspresso.desktop...'
      desktop = [
        "[Desktop Entry]"
        "Version=1.0"
        "Type=Application"
        "Name=Exspresso"
        "Comment=Exspresso Demo Application"
        "Exec=#{exspresso_path}/exspresso.sh"
        "Icon=#{exspresso_path}/bin/icons/128.png"
        "Path="
        "Terminal=false"
        "StartupNotify=false"
      ].join('\n')

      fs.writeFileSync  "#{exspresso_path}/Exspresso.desktop", desktop

      #
      # put it on the desktop, too
      #
      if process.env['USER']?
        user = process.env['USER']
        desktop_path = "/home/#{user}/Desktop"
        if fs.existsSync(desktop_path)
          fs.writeFileSync  "#{desktop_path}/Exspresso.desktop", desktop


    console.log 'Ok.'


#
# Build cdn assets
#
task "build:assets", "build assets for cdn upload", (options) ->

  fs = require('fs')

  src = __dirname+'/lib/application/assets/'
  dst = __dirname+'/lib/assets/'
  #
  # compile assets for upload to CDN
  #
  console.log 'Building assets...'
  assets = require('./cdn-assets.coffee')

  for name, group of assets
    for type, files of group
      files = [files] if not Array.isArray(files)
      source = []
      for file in files
        source.push fs.readFileSync "#{src}#{file}", 'utf-8'
      console.log "writing #{dst}#{type}/#{name}.#{type} ..."
      fs.writeFileSync "#{dst}#{type}/#{name}.#{type}", source.join('')
      switch type

        when 'css'
          exec "lessc --yui-compress #{dst}#{type}/#{name}.css > #{dst}#{type}/#{name}.min.css", (err, output) ->
            console.log err.message if err?

        when 'js'
          exec "uglifyjs #{dst}#{type}/#{name}.js --compress --output #{dst}#{type}/#{name}.min.js", (err, output) ->
            console.log err.message if err?

  console.log 'Ok.'
