{exec} = require 'child_process'

handle_errors = (err, stdout, stderr) ->
  throw err if err
  console.log stdout + stderr

task 'build', 'Create compiled HTML/CSS output', ->
  console.log 'build her a cake or something...'

  exec 'coffee -o lib -c src', handle_errors
