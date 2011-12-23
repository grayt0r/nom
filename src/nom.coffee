fs = require 'fs'
optimist = require 'optimist'
mkdirp = require 'mkdirp'

nom =
  version: '0.0.1'
  usage: 'Usage:\n  nom [OPTIONS]'

nom.run = ->
  # Parse the options based from the command line
  argv = optimist
    .usage(nom.usage)
    .option('help', { alias: 'h', default: false })
    .option('version', { alias: 'v', default: false })
    .argv
  
  name = argv._[0]
  
  if not name or argv.help
    console.log optimist.help()
    process.exit 0

  if argv.version
    console.log "nom v#{nom.version}"
    process.exit 0
  
  emptyDirectory name, (empty) ->
    if empty
      createModule name
    else
      program.confirm 'directory already exists, continue? ', (ok) ->
        if ok
          process.stdin.destroy()
          createModule name
        else
          abort 'aborting'

bin = (name) ->
  return """
    #!/usr/bin/env node

    var path = require('path');
    var fs   = require('fs');
    var lib  = path.join(path.dirname(fs.realpathSync(__filename)), '../lib');

    require(lib + '/#{name}').run();
  """

packageJson = (name) ->
  return """
    {
      "author": "Ross Grayton <rossgrayton@gmail.com>",
      "name": "#{name}",
      "description": "",
      "version": "0.0.1",
      "repository": {
        "type": "git",
        "url": "git://github.com/grayt0r/#{name}.git"
      },
      "bin": "./bin/#{name}",
      "main": "./lib/#{name}.js",
      "engines": {
        "node": "~0.6.5"
      },
      "dependencies": {},
      "devDependencies": {}
    }
  """

cakefile = (name) ->
  return """
    {spawn, exec} = require 'child_process'
    log = console.log

    task 'clean', ->
      run 'rm lib/*.js'

    task 'build', ->
      invoke 'clean'
      run 'coffee -j lib/#{name}.js -c src/*.coffee'

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
  """

gitIgnore = """
  .DS_Store
  node_modules/
  npm-*.log
  lib/*.js
  test/*.js
  test/screenshots/
"""

npmIgnore = """
  .DS_Store
  .git*
  *.coffee
  Cakefile
  docs/
  examples/
  src/
  test/
"""

mkdir = (name, fn) ->
  mkdirp name, 0755, (err) ->
    if err then throw err
    fn?()

emptyDirectory = (name, fn) ->
  fs.readdir name, (err, files) ->
    if err and err.code isnt 'ENOENT' then throw err
    fn err

createModule = (name) ->
  mkdir name, ->
    mkdir "#{name}/bin", ->
      fs.writeFile "#{name}/bin/#{name}", bin(name)
    mkdir "#{name}/docs"
    mkdir "#{name}/example"
    mkdir "#{name}/lib"
    mkdir "#{name}/src"
    mkdir "#{name}/test"
    
    fs.writeFile "#{name}/.gitIgnore", gitIgnore
    fs.writeFile "#{name}/.npmIgnore", npmIgnore
    fs.writeFile "#{name}/package.json", packageJson(name)
    fs.writeFile "#{name}/Cakefile", cakefile(name)

abort = (str) ->
  console.error str
  process.exit 1

module.exports = nom