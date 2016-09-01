
BLACKLISTED_USERS = {}

module.exports = (robot) ->

  robot.respond /ignore (.*)/i, (msg) ->
    id = msg.match[1]
    if robot.brain.users()[id]
      BLACKLISTED_USERS[id] = true
      msg.send "Yeah, fuck #{id}!"

  robot.respond /forgive (.*)/i, (msg) ->
    id = msg.match[1]
    if BLACKLISTED_USERS[id]
      BLACKLISTED_USERS[id] = false
      msg.send "All is forgiven #{id}."

  robot.receiveMiddleware (context, next, done) ->
    if BLACKLISTED_USERS[context.response.message.user.id]
      # Don't process this message further.
      context.response.message.finish()
      if context.response.message.text?.match(robot.respondPattern(''))
        context.response.reply ":fu:"
      done()
    else
      next(done)