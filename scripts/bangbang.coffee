# Description:
#   None
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot !! - Repeat the last command directed at hubot
#   hubot blame - Say who requested the last command
#
# Author:
#   None


moment = require('moment')

last_command = {}

module.exports = (robot) ->
  robot.respond /blame/i, (msg) ->
    if last_command[msg.message.room]?
      cmd = last_command[msg.message.room]
      userName = cmd.user['real_name'] or cmd.user.name
      msg.send ">#{cmd.cmd} \n by *#{userName}* _" + moment(cmd.date).fromNow() + "_"

  robot.respond /(.+)/i, (msg) ->
    store msg

  robot.respond /!!$/i, (msg) ->
    if last_command[msg.message.room]?
      msg.send last_command[msg.message.room].cmd
      msg['message']['text'] = "#{robot.name} #{last_command.cmd}"
      robot.receive(msg['message'])
      msg['message']['done'] = true
    else
      msg.send "i don't remember hearing anything."

store = (msg) ->
  command = msg.match[1].trim()
  last_command ||= {}
  last_command[msg.message.room] = {cmd: command, date: new Date, user: msg.message.user} unless command == '!!'