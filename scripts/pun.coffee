# Description:
#   pun
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   [pun word] -
#
# Author:
#   Daniel Neal <daniel.neal@socialsuperstore.com>

module.exports = (robot) ->

  robot.hear /pun (.*)/i, (msg) ->
    robot.http("dadjokes.org/pun/" + msg.match[1] + "/json")
    .get() (err, res, body) ->
      return if err
      response = JSON.parse(body)
      return if !response.success
      pun = response.data.pun
      msg.send pun
