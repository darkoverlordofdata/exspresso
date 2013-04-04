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
fs = require('fs')


#
# Build the preview - requires valac
#
task "build:preview", "build webkit previewer", ->

  #
  # compile preview.vala
  #
  console.log 'Building bin/preview...'
  exec "valac --pkg gtk+-2.0 --pkg webkit-1.0 --thread bin/preview.vala --output=bin/preview", (err, output) ->
    console.log output
    if err?
      console.log err.message
    else
      console.log 'Ok.'


#
# Build the desktop file
#
task "build:desktop", "build desktop launcher", ->

  exspresso_path = process.cwd()

  #
  # create the shell file
  #
  console.log 'Building exspresso.sh...'
  bash = [
    "#!/usr/bin/env bash"
    "cd #{exspresso_path}"
    "/usr/bin/node #{exspresso_path}/exspresso --db postgres --preview"
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
    "Comment="
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
