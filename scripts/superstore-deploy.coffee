# Description:
#   Deploy stuffs
#
# Author:
#   d.aitken@socialsuperstore.com

git = require('../lib/superstore/git')
deploy = require('../lib/superstore/deploy')
_ = require('lodash')
util = require('util')

getOpts = (msg) -> {
    env: msg.match[1].trim(),
    services: msg.match[2].replace(/[ ]/g, '').split(','),
    version: msg.match[3].trim(),
  }

shouldDeploy = (msg) ->
  room = msg.message.room
  user = msg.message.user
  return room == 'Shell' or room == 'tech-deploys' or room == user.name

isAllowed = (robot, msg) ->
  user = msg.message.user
  return robot.auth.hasRole(user, 'deploy')

formatCommit = (commitDetails) ->
  sha = commitDetails.sha.slice(0, 7)
  commitMessage = commitDetails.commit.message
  return "`* #{sha} #{commitMessage}`"

formatServices = (services, commitDetails) ->
  sha = commitDetails.sha.slice(0, 7)
  formatted = _.map services, (s) ->
    "`#{s}@#{sha}`"

  formatted.join(', ')

sendUpdates = (robot, msg, interval, duration, f) ->
  end = Date.now() + duration * 1000 

  sendMessage = msg.send.bind(msg)
  counter = '.'
  if robot.adapter.constructor.name == 'SlackBot'
    sentMessage = null
    sendMessage = (text) ->
      if sentMessage
        sentMessage.updateMessage(text)
      else
        sentMessage = _.first(robot.adapter.send msg.envelope, text)

  makeCall = () ->
    f (err, text) ->
      if (err)
        sendMessage err.message
      else
        sendMessage "`#{counter}`\n#{text}"
        if (Date.now() < end)
          counter += '.'
          setTimeout makeCall, (interval * 1000)

  makeCall()

module.exports = (robot) ->

  robot.hear /on (.*): create rc for (.*)@(.*)/i, (msg) ->
    if (shouldDeploy msg)
      unless isAllowed robot, msg
        msg.reply "Taking no action - please ask for permission"
      else
        opts = getOpts msg
        pluralisation = if opts.services.length == 1 then '' else 's'
        msg.send "Creating replication controller#{pluralisation}..."

        deploy.createRC opts, (err, result) ->
          if (err)
            msg.reply "Error: ```#{err.message}```"
          else
            serviceList = formatServices opts.services, result.commitDetails
            response = "Created on #{opts.env}: #{serviceList}\n"
            response += formatCommit result.commitDetails
            msg.reply response

            sendUpdates robot, msg, 5, 120, (cb) ->
              deploy.kubectl opts.env, 'get pods', (err, output) ->
                cb err, "```#{output}```"

  robot.hear /on (.*): delete rc for (.*)@(.*)/i, (msg) ->
    if (shouldDeploy msg)
      unless isAllowed robot, msg
        msg.reply "Taking no action - please ask for permission"
      else
        opts = getOpts msg
        pluralisation = if opts.services.length == 1 then '' else 's'
        msg.send "Deleting replication controller#{pluralisation}..."

        deploy.deleteRC opts, (err, result) ->
          if (err)
            msg.reply "Error: ```#{err.message}```"
          else
            serviceList = formatServices opts.services, result.commitDetails
            msg.reply "Deleted on #{opts.env}: #{serviceList}"

            sendUpdates robot, msg, 5, 120, (cb) ->
              deploy.kubectl opts.env, 'get pods', (err, output) ->
                cb err, "```#{output}```"

  robot.hear /on (.*): migrate db@(.*)/i, (msg) ->
    if (shouldDeploy msg)
      unless isAllowed robot, msg
        msg.reply "Taking no action - please ask for permission"
      else
        env = msg.match[1]
        version = msg.match[2]
        opts = {
          env: msg.match[1],
          version: msg.match[2]
        }
        msg.send "Migrating db..."

        deploy.migrateDB opts, (err, result) ->
          if (err)
            msg.reply "Error: ```#{err.message}```"
          else
            serviceList = formatServices opts.services, result.commitDetails
            msg.reply "DB migration scheduled"

            sendUpdates robot, msg, 5, 120, (cb) ->
              deploy.kubectl opts.env, 'get jobs -l db-migration-job', (err, output) ->
                cb err, "```#{output}```"

  robot.hear /on (.*): point dark at (.*)@(.*)/i, (msg) ->
    if (shouldDeploy msg)
      unless isAllowed robot, msg
        msg.reply "Taking no action - please ask for permission"
      else
        opts = getOpts msg
        pluralisation = if opts.services.length == 1 then '' else 's'
        msg.send "Pointing dark service#{pluralisation}..."

        deploy.pointDark opts, (err, result) ->
          if (err)
            msg.reply "Error: ```#{err.message}```"
          else
            serviceList = formatServices opts.services, result.commitDetails
            sha = result.commitDetails.sha.slice(0, 7)
            response = "Repointed on #{opts.env}:"
            _.forEach result.urls, (url, service) ->
              response += "\n`#{url}` → `#{service}@#{sha}`"

            msg.reply response

  robot.hear /on (.*): point light at (.*)@(.*)/i, (msg) ->
    if (shouldDeploy msg)
      unless isAllowed robot, msg
        msg.reply "Taking no action - please ask for permission"
      else
        opts = getOpts msg
        pluralisation = if opts.services.length == 1 then '' else 's'
        msg.send "Pointing light service#{pluralisation}..."

        deploy.pointLight opts, (err, result) ->
          if (err)
            msg.reply "Error: ```#{err.message}```"
          else
            serviceList = formatServices opts.services, result.commitDetails
            sha = result.commitDetails.sha.slice(0, 7)
            response = "Repointed on #{opts.env}:"
            _.forEach result.urls, (url, service) ->
              response += "\n`#{url}` → `#{service}@#{sha}`"

            msg.reply response

  robot.hear /on (.*): kubectl get -w (.*)/i, (msg) ->
    if (shouldDeploy msg)
      unless isAllowed robot, msg
        msg.reply "Taking no action - please ask for permission"
      else
        msg.finish

        env = msg.match[1]
        args = msg.match[2]

        cmd = 'get ' + args
        sendUpdates robot, msg, 5, 120, (cb) ->
          deploy.kubectl env, cmd, (err, output) ->
            cb err, "```#{output}```"

  robot.hear /on (.*): kubectl (.*)/i, (msg) ->
    if (shouldDeploy msg)
      unless isAllowed robot, msg
        msg.reply "Taking no action - please ask for permission"
      else
        env = msg.match[1]
        args = msg.match[2]
        deploy.kubectl env, args, (err, output) ->
          if (err)
            msg.reply "Error: ```#{err.message}```"

          msg.send "```#{output}```"
