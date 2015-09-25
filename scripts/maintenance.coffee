# Description:
#   Maintenance scripts
#
# Commands:
#   hubot update and restart - Fetch, install & reload
#   hubot update git - Perform git pull
#   hubot show version - Show git revision
#   hubot check for updates - Inspects NPM for package updates
#
#
# Author:
#   h.deakin@quidco.com

spawn = require('child_process').spawn

gitPath = process.env.HUBOT_GIT_PATH
checkUpdatesPath = process.env.HUBOT_CHECK_UPDATES_PATH
uptimePath = process.env.HUBOT_UPTIME_PATH

delay = (ms, func) -> setTimeout func, ms

timeout = 3

sleep = (ms) ->
  start = new Date().getTime()
  continue while new Date().getTime() - start < ms

isRestarting = false

runCmd = (robot, room, cmd, args, next) ->
  args ?= []
  child = spawn cmd, args
  #robot.messageRoom(room, "Running `" + cmd + " " + args.join(" ") + "`")
  output = ""
  child.stdout.on('data', (data) ->
    output += data
  )
  child.stderr.on('data', (data) ->
    output += data
  )
  child.on('close', (code) ->
    if (output.length)
      robot.messageRoom(room, "```" + output + "```")
    if (code != 0)
      robot.messageRoom(room, "`" + cmd + " " + args.join(" ") + "` Failed (" + code + ")")
    else
      if next
        next(robot, room, next)
#      else
#        robot.messageRoom(room, "Success")
  )

updateGit = (robot, room, next) ->
  runCmd(robot, room, gitPath, ["pull"], next)

getRevision = (robot, room, next) ->
  runCmd(robot, room, gitPath, ["log", "--oneline", "-n", "1"])

getCheckUpdates = (robot, room, next) ->
  runCmd(robot, room, checkUpdatesPath)

getServerUptime = (robot, room, next) ->
  runCmd(robot, room, uptimePath)

respawnBot = (robot, room) ->
  robot.messageRoom room, "Restarting in #{timeout} seconds..."
  isRestarting = true
  robot.brain.set "maintenanceReloadRoom", room
  robot.brain.save()
  robot.shutdown()
  setTimeout () ->
    console.log "Restarting!"
    process.exit()
  , timeout * 1000


module.exports = (robot) ->
  robot.respond /update git/i, (msg) ->
    room = msg.message.user.room
    updateGit robot, room

  robot.respond /update and restart/i, (msg) ->
    room = msg.message.user.room
    updateGit(robot, room, (robot, room, next) ->
      respawnBot(robot, room)
    )

  robot.respond /show version/i, (msg) ->
    room = msg.message.user.room
    getRevision(robot, room)

  robot.respond /check for updates/i, (msg) ->
    room = msg.message.user.room
    getCheckUpdates(robot, room)

  robot.respond /respawn/i, (msg) ->
    room = msg.message.user.room
    respawnBot(robot, room)

  robot.respond /server health/i, (msg) ->
    room = msg.message.user.room
    getServerUptime(robot, room)

  robot.brain.on 'loaded', =>
    room = robot.brain.get "maintenanceReloadRoom"
    if (!isRestarting && room != null && room.length)
      robot.messageRoom room, "Restart complete. I'm back online!"
      getRevision robot, room
      robot.brain.set "maintenanceReloadRoom", ""