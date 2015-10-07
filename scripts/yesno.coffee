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
#   hubot yes or no - Decide yes or no
#
# Author:
#   None

respond = (robot, msg, force = null) ->
  robot
    .http('http://yesno.wtf/api' + (if force? then "?force=#{force}" else "" ))
    .get() (err, res, body) ->
      return console.log(err) if err
      response = JSON.parse(body)
      msg.send (if !response.force then "#{response.answer}! " else "") + response.image

module.exports = (robot) ->

  robot.respond /yes(?: \s+)?(?:or)?(?: \s+)?no/i, (msg) ->
    respond robot, msg

  robot.respond /\b(yes|no|maybe)\b/i, (msg) ->
    respond robot, msg, msg.match[1]

  robot.hear /^(yes|no|maybe)!$/i, (msg) ->
    respond robot, msg, msg.match[1]