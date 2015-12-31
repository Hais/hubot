# Description:
#   Deploy stuffs
#
# Author:
#   d.aitken@socialsuperstore.com

git = require('../lib/superstore/git')
deploy = require('../lib/superstore/deploy')
_ = require('lodash')

getOpts = (msg) -> {
    services: msg.match[1].replace(/[ ]/g, '').split(','),
    version: msg.match[2].trim(),
    env: msg.match[3].trim()
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

poll = (interval, timeout, f) ->
  times = Math.floor(timeout / interval)
  calls = _.times times, () -> f

  makeCall = () ->
    if calls.length > 0
      call = calls.pop()
      call()
      setTimeout(makeCall, interval * 1000)

  makeCall()

module.exports = (robot) ->
  robot.hear /for (.*)@(.*) on (.*): create rc/i, (msg) ->
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
            sent = msg.reply response

            if sent.rawMessage && sent.rawMessage.updateMessage
              forUpdate = msg.send "```...```"
              poll 10, 120, () ->
                deploy.kubectl opts.env, 'get pods', (err, output) ->
                  if (!err)
                    forUpdate.rawMessage.updateMessage output

  robot.hear /for (.*)@(.*) on (.*): delete rc/i, (msg) ->
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

  robot.hear /for (.*)@(.*) on (.*): point dark/i, (msg) ->
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

  robot.hear /for (.*)@(.*) on (.*): point light/i, (msg) ->
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
