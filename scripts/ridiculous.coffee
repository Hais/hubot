# Description:
#   An account class?  That's ridiculous.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Author:
#   Sean Doig (s.doig@socialsuperstore.com)

module.exports = (robot) ->
  robot.hear /(that'?s|it'?s|this\s+is)\s+ridiculous/i, (msg) ->
    msg.send "https://s3-eu-west-1.amazonaws.com/socialhubot/hickey.jpeg"