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

    today = new Date
    days= ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"]
    day = days[today.getDay()]

    if msg.match[1]=="me"
      user=msg.message.user.name
    else
      user=msg.match[1]

    lunches =
       bronsa:
         default: ['chicken katsu curry', 'pizza', 'a Clojure JIRA ticket']
       mikey:
         default: ['coffee', 'that one sandwich', 'nothing']
       daniel:
         default: ['salad bar', 'soup']
         thursday: ['something nice from that market near lazy bones']
         friday: ['salad bar', 'soup', 'meal deal', 'try and rouse people into a pub lunch']
       keigo: ['bench', 'potsu'],
       lee: ['salad bar', 'bench soup']

    if (lunches[user] == undefined && msg.match[1] == "me")
      msg.send "No lunches defined for you, you will have to go hungry"
    else if (lunches[user] == undefined && msg.match[1] != "me")
      msg.send "No lunches defined for " + user + " they will have to go hungry"
    else if (lunches[user][day] == undefined)
      msg.send msg.random lunches[user]["default"]
    else
      msg.send msg.random lunches[user][day]
