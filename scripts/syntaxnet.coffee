# Description:
#   Parsey McParseface
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot syntaxnet <text> - process with Parsey McParseface
#
# Author:
#   hais
#

tensorflowmodels = process.env.HUBOT_TENSORFLOW_MODELS_PATH || '~/models'
syntaxnet = "#{tensorflowmodels}/syntaxnet"
syntaxnetdemo = "#{syntaxnet}/syntaxnet/demo.sh"
exec = require('child_process').exec

module.exports = (robot) ->
  robot.respond /syntaxnet (.*)/i, (msg) ->
    text = msg.match[1]
    cmd = "cat /tmp/foobar | #{syntaxnetdemo}"
    child = exec cmd, [],
      cwd: syntaxnet
      timeout: 10000
    , (err, stdout, stderr) ->
      console.log err
      console.log
      #console.log "done #{stderr}"
      robot.send "```#{stdout}```" if stdout.length
#    child.stdin.setEncoding('utf-8');
#    child.stdin.write "#{text}\n"
#    child.stdin.close()
    child.stdout.on 'data', (data) ->
      console.log data
    child.stderr.on 'data', (data) ->
      console.log data