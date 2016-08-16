# Description:
#   Record good ideas
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   ideas
#
# Author:
#   daniel

last_message = "";

module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.ideas || = {}

  robot.hear /^((?!hubot)(?!.*\.txt).+)/i, (msg) ->
    store msg

  robot.hear /^\`?([a-zA-Z0-9_]*)\.txt\`?/i, (msg) ->
    msg.send "saving " + last_message + " to `" + msg.match[1] + ".txt`"
    robot.brain.data.ideas[msg.match[1]] || = []
    robot.brain.data.ideas[msg.match[1]].push last_message

  robot.respond /cat \`?(.*)\`?\.txt/i, (msg) ->
    if (ideas = robot.brain.data.ideas[msg.match[1]])
      msg.send "`" + msg.match[1] + ".txt`"
      for idea in ideas
        msg.send idea

store = (msg) ->
  last_message = msg.match[1]
