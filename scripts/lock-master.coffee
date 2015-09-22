# Description:
#   Master locking magic
#
# Author:
#   s.doigsocialsuperstore.com

userDisplayName = (user) ->
  return user.name

userCanonName = (user) ->
  return user.name || user.real_name

isInDevRoom = (msg) ->
  return msg.message.room == 'dev-team'

grantLock = (robot, user) ->
  return robot.brain.set('dev-team-master-lock', {user: userCanonName(user), time: (new Date)})

getLock = (robot) ->
  return robot.brain.get('dev-team-master-lock')

releaseLock = (robot) ->
  return robot.brain.remove('dev-team-master-lock')

isLocked = (robot) ->
  return !!getLock(robot)

module.exports = (robot) ->

  robot.hear /^lock\s+mast(er|a+)/i, (msg) ->
    if isInDevRoom(msg)
      if isLocked(robot)
        if getLock(robot).user == userCanonName(msg.message.user)
          msg.send "You've already got the lock you stupid man."
        else
          msg.send "No can do! " + getLock(robot).user + " has had the lock since " + getLock(robot).time.toString() + "!"
      else
        grantLock(robot, msg.message.user)
        msg.send "Lock granted to " + userDisplayName(msg.message.user) + ".  Make it snappy."

  robot.hear /^(unlock(ing)?|releas(e|ing))\s+mast(er|a+)/i, (msg) ->
    if isInDevRoom(msg)
      if isLocked(robot)
        if getLock(robot).user == userCanonName(msg.message.user)
          releaseLock(robot)
          msg.send "I hath released yo' lock on master, dawg."
        else
          msg.send "Nice try " + userDisplayName(msg.message.user) + ", but you don't own this lock. " + getLock(robot).user + " does."
      else
        msg.send "Nobody told me about a lock.  Going back to sleep."

  robot.respond /unlock\s+master/i, (msg) ->
    if isInDevRoom(msg)
      if isLocked(robot)
        msg.reply "Forcing unlock of master lock acquired by " + getLock(robot).user + " at " + getLock(robot).time.toString() + ".  He better not give me any shit."
        releaseLock(robot)
      else
        msg.reply "Nobody told me about a lock.  Going back to sleep."



