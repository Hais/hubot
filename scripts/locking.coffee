# Description:
#   Locking magic
#
# Author:
#   s.doigsocialsuperstore.com

lockables = {
  master: 'mast(er|a+)',
  beta1: 'beta1',
  beta2: 'beta2'
}

userDisplayName = (user) ->
  return user.name

userCanonName = (user) ->
  return user.name || user.real_name

isInDevRoom = (msg) ->
  return msg.message.room == 'dev-team'

grantLock = (robot, type, user) ->
  return robot.brain.set('dev-team-' + type + '-lock', {user: userCanonName(user), time: (new Date)})

getLock = (robot, type) ->
  return robot.brain.get('dev-team-' + type + '-lock')

releaseLock = (robot, type) ->
  return robot.brain.remove('dev-team-' + type + '-lock')

isLocked = (robot, type) ->
  return !!getLock(robot, type)

randInt = (min, max) ->
  return Math.floor(Math.random()*(max-1))+min

thumbsUp = () ->
  return ":thumbsup::skin-tone-" + randInt(2,6).toString() + ":"

module.exports = (robot) ->

  robot.respond /^ls locks/i, (msg) ->
    response = "Locks:"
    for type of lockables
      do (type) ->
        response += "\n"
        if isLocked(robot, type):
          response += "#{type}: Locked by #{getLock(robot, type).user} since #{getLock(robot, type).time.toString()}"
        else
          response += "#{type}: Not locked"

    msg.reply response

  for type, matcher of lockables
    do (type, matcher) ->

      robot.hear (new RegExp(("^lock\\s+" + matcher), "i")), (msg) ->
        if isInDevRoom(msg)
          if isLocked(robot, type):
            if getLock(robot, type).user == userCanonName(msg.message.user)
              msg.send "You've already got the lock you clown."
            else
              msg.send "No can do! " + getLock(robot, type).user + " has had the lock since " + getLock(robot, type).time.toString() + "!"
          else
            grantLock(robot, type, msg.message.user)
            msg.send thumbsUp()

      robot.hear (new RegExp(("^(unlock(ing)?|releas(e|ing))\\s+" + matcher), "i")), (msg) ->
        if isInDevRoom(msg)
          if isLocked(robot, type)
            if getLock(robot, type).user == userCanonName(msg.message.user)
              releaseLock(robot, type)
              msg.send thumbsUp()
            else
              msg.send "Nice try " + userDisplayName(msg.message.user) + ", but you don't own this lock. " + getLock(robot, type).user + " does."
          else
            msg.send "Nobody told me about a lock.  Going back to sleep."

      robot.respond (new RegExp(("unlock\\s+" + matcher), "i")), (msg) ->
        if isInDevRoom(msg)
          if isLocked(robot, type)
            msg.reply "Forcing unlock of " + type + " lock acquired by " + getLock(robot, type).user + " at " + getLock(robot, type).time.toString() + ".  He better not give me any shit."
            releaseLock(robot, type)
          else
            msg.reply "Nobody told me about a lock.  Going back to sleep."
