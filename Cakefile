fs     = require 'fs'
{spawn, exec} = require 'child_process'

appFiles  = [
  'src/backbone.shared_model.coffee'
  'src/backbone.shared_collection.coffee'
]

task 'build', 'Build single application file from source files', ->
  source = spawn 'coffee', ['-cwj', 'backbone.shared.js'].concat(appFiles)
  source.stdout.on 'data', (data) -> console.log data.toString().trim()


task 'build:examples', 'Build examples', ->
  examples = spawn 'coffee', ['-cw', '-o', 'examples/public/js', 'examples/src']
  examples.stdout.on 'data', (data) -> console.log data.toString().trim()

  source = spawn 'coffee', ['-cwj', 'examples/public/lib/backbone.shared.js'].concat(appFiles)
  source.stdout.on 'data', (data) -> console.log data.toString().trim()

  invoke('build')

task 'run:building', 'Run the example server while re-building everyting', ->
  invoke('build:examples')

  app = spawn 'node', ['examples/app.js']
  app.stdout.on 'data', (data) -> console.log data.toString().trim()