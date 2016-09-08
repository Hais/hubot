# Description:
#   Locking magic
#
# Author:
#   s.doig@socialsuperstore.com
#
# Commands:
#   hubot ls locks - list #clojurians environment locks
#   lock <lock-name> - lock #clojurians lock
#   unlock <lock-name> - unlock #clojurians lock

lockables = {
  master: 'h?a?(?!.*beta).*(b|m|p)l?(e|i)*?(i|e)*?a*?s?a?(te)?r?a*?(rd)?|gandalf|:rich:',
  beta1: 'beta1',
  beta2: 'beta2',
  beta3: 'beta3',
  live: '(l(i|o)(v|c)e?|prod|light|dogs)',
  "those desks where the couch used to be": '(couch|zzz|bed|danilo)'
}

userDisplayName = (user) ->
  return user.name

userCanonName = (user) ->
  return user.name || user.real_name

isInDevRoom = (msg) ->
  return msg.message.room == 'clojurians'

grantLock = (robot, type, user) ->
  return robot.brain.set('clojurians-' + type + '-lock', {user: userCanonName(user), time: (new Date)})

getLock = (robot, type) ->
  return robot.brain.get('clojurians-' + type + '-lock')

releaseLock = (robot, type) ->
  return robot.brain.remove('clojurians-' + type + '-lock')

isLocked = (robot, type) ->
  return !!getLock(robot, type)

randInt = (min, max) ->
  return Math.floor(Math.random()*(max-1))+min

thumbsUp = () ->
  return ":thumbsup::skin-tone-" + randInt(2,6).toString() + ":"

module.exports = (robot) ->

  robot.respond /(ls)|(suck) (s|l|c)ocks/i, (msg) ->
    response = "Here you go:\n```"
    for type of lockables
      do (type) ->
        response += "\n - "
        if isLocked(robot, type)
          response += "#{type}: Locked by #{getLock(robot, type).user} since #{getLock(robot, type).time.toString()}"
        else
          response += "#{type}: Not locked"

    if not isInDevRoom(msg)
      response += "\n\n You're not in the dev room though, you clown."

    response += "\n```"
    msg.reply response

  for type, matcher of lockables
    do (type, matcher) ->

      robot.hear (new RegExp(("^((s|l)o(o|c)k|can i haz|i can haz)\\s+" + matcher), "i")), (msg) ->
        if isInDevRoom(msg)
          if isLocked(robot, type)
            if getLock(robot, type).user == userCanonName(msg.message.user)
              msg.send "`IllegalMonitorStateException: You've already got the lock you clown.`"
            else
              msg.send "`IllegalMonitorStateException: No can do! @" + getLock(robot, type).user + " has had the lock since " + getLock(robot, type).time.toString() + ".`"
          else
            grantLock(robot, type, msg.message.user)
            msg.send thumbsUp()

      robot.hear (new RegExp(("^(kthx|unlock(ing)?|releas(e|ing)|bonza)\\s+" + matcher), "i")), (msg) ->
        if isInDevRoom(msg)
          if isLocked(robot, type)
            if getLock(robot, type).user == userCanonName(msg.message.user)
              releaseLock(robot, type)
              msg.send thumbsUp()
            else
              msg.send "`IllegalMonitorStateException: Nice try " + userDisplayName(msg.message.user) + ", but you don't own this lock. " + getLock(robot, type).user + " does.`"
          else
            msg.send "`IllegalMonitorStateException: Nobody told me about a lock. Going back to sleep.`"

      robot.respond (new RegExp(("(kthx|unlock(ing)?|releas(e|ing))\\s+" + matcher), "i")), (msg) ->
        if isInDevRoom(msg)
          if isLocked(robot, type)
            msg.reply "Forcing unlock of " + type + " lock acquired by @" + getLock(robot, type).user + " at " + getLock(robot, type).time.toString() + ". He better not give me any shit."
            releaseLock(robot, type)
          else
            msg.reply "`IllegalMonitorStateException: Nobody told me about a lock. Going back to sleep.`"
