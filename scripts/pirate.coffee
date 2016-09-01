

async = require 'async'

chats = {}

module.exports = (robot) ->

  translate = (text, cb) ->
    robot.http("http://isithackday.com/arrpi.php?text=" + text)
    .get() (err, res, body) ->
      return cb(err) if err
      cb null, body

  robot.respond /pirate (.*)/i, (msg) ->
    translate msg.match[1], (err, text) ->
      msg.send text

  robot.respond /talk pirate/i, (msg) ->
    chats[msg.message.user.room] = true
    msg.send "I will talk pirate from now on"

  robot.respond /talk english/i, (msg) ->
    chats[msg.message.user.room] = false
    msg.send "I will talk english from now on"

  robot.responseMiddleware (context, next, done) ->
    return next() unless chats[context.response.message.room]
    return unless context.plaintext?

    async.map context.strings, translate, (err, results) ->
      context.strings = results
      next()