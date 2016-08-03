# Description:
#   Choose Nicola's lunch
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   lunch me
#
# Author:
#   daniel

module.exports = (robot) ->

  robot.hear /lunch me/, (msg) ->
    lunches = [
      'chicken katsu curry'
      'pizza'
    ]
    msg.send msg.random lunches
