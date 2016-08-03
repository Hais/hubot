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

  robot.hear /lunch (.*)/, (msg) ->
    if msg.match[1]=="me"
      user=msg.message.user.name
    else
      user=msg.match[1]

    lunches =
       bronsa: ['chicken katsu curry', 'pizza', 'a Clojure JIRA ticket']
       mikey: ['coffee', 'that one sandwich', 'nothing']
       daniel: ['salad bar', 'soup']
       keigo: ['bench', 'potsu'],
       lee: ['salad bar','bench soup']
    if (lunches[user] == undefined && msg.match[1] == "me")
      msg.send "No lunches defined for you, you will have to go hungry"
    else if (lunches[user] == undefined && msg.match[1] != "me")
      msg.send "No lunches defined for " + user + " they will have to go hungry"
    else
      msg.send msg.random lunches[user]
