{spawn, exec} = require 'child_process'
log = console.log

task 'clean', ->
  run 'rm lib/*.js'
      
task 'build', ->
  invoke 'clean'
  run 'coffee -j lib/nom.js -c src/*.coffee'
    
task 'test', ->
  run 'coffee tests/index.coffee'
    
task 'docs', ->
  run 'docco src/*.coffee'

task 'install', ->
  invoke 'build'
  run 'npm install -g .'

run = (command) ->
  cmd = spawn '/bin/sh', ['-c', command]
  cmd.stdout.on 'data', (data) -> process.stdout.write data
  cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', -> cmd.kill()