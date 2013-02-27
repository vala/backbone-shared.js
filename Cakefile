fs     = require 'fs'
{spawn, exec} = require 'child_process'

appFiles  = [
  'src/backbone.shared_model.coffee'
  'src/backbone.shared_collection.coffee'
]

# ANSI Terminal Colors.
bold = red = green = reset = ''
unless process.env.NODE_DISABLE_COLORS
  bold  = '\x1B[0;1m'
  red   = '\x1B[0;31m'
  green = '\x1B[0;32m'
  reset = '\x1B[0m'

log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

uglify = (input, output) ->
  min = spawn 'uglifyjs', ['-v', '--stats', input, '-o', output]
  min.stderr.on 'data', (data) -> log data.toString().trim(), bold

task 'build', 'Build single application file from source files', ->
  source = spawn 'coffee', ['-cwj', 'backbone.shared.js'].concat(appFiles)
  source.stdout.on 'data', (data) -> log data.toString().trim(), green
  uglify 'backbone.shared.js', 'backbone.shared-min.js'

task 'build:examples', 'Build examples', ->
  examples = spawn 'coffee', ['-cw', '-o', 'examples/public/js', 'examples/src']
  examples.stdout.on 'data', (data) -> log data.toString().trim(), green

  source = spawn 'coffee', ['-cwj', 'examples/public/lib/backbone.shared.js'].concat(appFiles)
  source.stdout.on 'data', (data) -> log data.toString().trim(), green

  uglify 'backbone.shared.js', 'examples/public/lib/backbone.shared-min.js'

  invoke('build')

task 'run:building', 'Run the example server while re-building everyting', ->
  invoke('build:examples')

  app = spawn 'node', ['examples/app.js']
  app.stdout.on 'data', (data) -> log data.toString().trim(), bold

