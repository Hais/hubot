# Description:
#   simsimi
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   simsimi
#
# Author:
#   hais

async = require 'async'

chats = {}
module.exports = (robot) ->

  create =
    (msg) ->
      (cb) ->
        return cb null, chats[msg.message.user.room], msg if chats[msg.message.user.room]?
        robot.http("http://simsimi.com/getUUID")
        .get() (err, res, body) ->
          return cb(err) if err
          result = JSON.parse body
          uuid = result.uuid
          chats[msg.message.user.room] = uuid
          cb null, result.uuid, msg

  chat = (token, msg, cb) ->
    text = msg.match[1]
    robot.http("http://simsimi.com/getRealtimeReq?uuid=#{token}&lc=en&ft=1&reqText=#{text}&status=W")
    .get() (err, res, body) ->
      return cb(err) if err
      result = JSON.parse body
      cb null, result.respSentence

  run = (msg) ->
    async.waterfall [create(msg), chat], (err, result) ->
      return msg.send "Error #{err}" if err
      if process.env.HUBOT_SLACK_INCOMING_WEBHOOK?
        robot.emit 'slack.attachment',
          message: result
          icon_url: "http://simsimi.com/image/simsimi_logo_1.4k.png"
          username: "SimSimi"
      else
        msg.send result

  robot.hear /^(simsimi|~) (.*)/i, (msg) ->
    run msg

  robot.respond /~ (.*)/i, (msg) ->
    run msg