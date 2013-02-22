fs     = require 'fs'
{exec} = require 'child_process'

appFiles  = [
  'src/backbone.shared_model'
  'src/backbone.shared_collection'
]

task 'build', 'Build single application file from source files', ->
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile 'build/backbone.shared.coffee', appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee --compile build/backbone.shared.coffee', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr


task 'build:examples', 'Build examples', ->
  exec 'coffee --compile --output examples/js examples/src/test.coffee'