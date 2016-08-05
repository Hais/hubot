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
         default: ["chicken katsu curry", "pizza", "a Clojure JIRA ticket"]
       mikey:
         default: ["coffee", "that one sandwich", "nothing"]
       daniel:
         default: ["salad bar", "soup", "meal deal", "rice bowl"]
         thursday: ["something nice from that market near lazy bones"]
         friday: ["salad bar", "soup", "sainsbury's meal deal", "try and rouse people into a pub lunch"]
       george:
         default: ["bench", "i dunno, a burger or something"]
         thursday: ["something nice from that market near lazy bones. and doughnuts."]
       dave:
         default: ["lamb and halloumi box", "coco de mama pasta", "pret a manger sandwich", "a cheeky nandos", "vape juice", "a devops card", ":jenkins_is_angry:"]
       james:
         default: ["pret a manger sandwich", "coco de mama pasta", "subway"]
       tomcruise:
         default: ["salad bar", "hmm... salad bar"]
         monday: ["boots o2 special"]
       keigo:
         default: ["pretend to get soup from bench but switch to salad and quiche", "potsu"],
         thursday: ["something nice from that market near lazy bones"]
       mrlee:
         default: ["salad bar", "bench soup", "tom yum soup", "lamb and halloumi box"]

    if (lunches[user] == undefined && msg.match[1] == "me")
      msg.send "No lunches defined for you, you will have to go hungry"
    else if (lunches[user] == undefined && msg.match[1] != "me")
      msg.send "No lunches defined for " + user + " they will have to go hungry"
    else if (lunches[user][day] == undefined)
      msg.send msg.random lunches[user]["default"]
    else
      msg.send msg.random lunches[user][day]
