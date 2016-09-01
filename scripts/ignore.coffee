# Description:
#   Fuckin' thing sucks
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   ignore <user>
#   forgive <user>
#
# Author:
#   hais
#

BLACKLISTED_USERS = {}

module.exports = (robot) ->

  robot.respond /ignore (.*)/i, (msg) ->
    id = msg.match[1]
    BLACKLISTED_USERS[msg.message.user.room] ||= {}
    if robot.brain.users()[id]
      BLACKLISTED_USERS[msg.message.user.room][id] = true
      msg.send "Yeah, fuck #{id}!"

  robot.respond /forgive (.*)/i, (msg) ->
    id = msg.match[1]
    BLACKLISTED_USERS[msg.message.user.room] ||= {}
    if BLACKLISTED_USERS[msg.message.user.room][id]
      BLACKLISTED_USERS[msg.message.user.room][id] = false
      msg.send "All is forgiven #{id}."

  robot.receiveMiddleware (context, next, done) ->
    BLACKLISTED_USERS[context.response.message.room] ||= {}
    if BLACKLISTED_USERS[context.response.message.user.id]
      # Don't process this message further.
      context.response.message.finish()
      if context.response.message.text?.match(robot.respondPattern(''))
        context.response.reply ":fu:"
      done()
    else
      next(done)