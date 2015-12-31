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
  return (msg.message.room == 'Shell' or msg.message.room == 'tech-deploys' or msg.message.room == msg.message.user.name)

formatCommit = (commitDetails) ->
  sha = commitDetails.sha.slice(0, 7)
  commitMessage = commitDetails.commit.message
  return "`* #{sha} #{commitMessage}`"

formatServices = (services, commitDetails) ->
  sha = commitDetails.sha.slice(0, 7)
  formatted = _.map services, (s) ->
    "`#{s}@#{sha}`"

  formatted.join(', ')

module.exports = (robot) ->

  robot.hear /deploying (.*)@(.*) to (.*): create rc/i, (msg) ->
    if (shouldDeploy msg)
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

  robot.hear /deploying (.*)@(.*) to (.*): delete rc/i, (msg) ->
    if (shouldDeploy msg)
      opts = getOpts msg
      pluralisation = if opts.services.length == 1 then '' else 's'
      msg.send "Deleting replication controller#{pluralisation}..."

      deploy.deleteRC opts, (err, result) ->
        if (err)
          msg.reply 'Error: ' + err.message
        else
          serviceList = formatServices opts.services, result.commitDetails
          msg.reply "Deleted on #{opts.env}: #{serviceList}"

  robot.hear /deploying (.*)@(.*) to (.*): point dark/i, (msg) ->
    if (shouldDeploy msg)
      opts = getOpts msg
      pluralisation = if opts.services.length == 1 then '' else 's'
      msg.send "Pointing dark service#{pluralisation}..."

      deploy.pointDark opts, (err, result) ->
        if (err)
          msg.reply 'Error: ' + err.message
        else
          serviceList = formatServices opts.services, result.commitDetails
          sha = result.commitDetails.sha.slice(0, 7)
          response = "Repointed on #{opts.env}:"
          _.forEach result.urls, (url, service) ->
            response += "\n`#{url}` → `#{service}@#{sha}`"

          msg.reply response

  robot.hear /deploying (.*)@(.*) to (.*): point light/i, (msg) ->
    if (shouldDeploy msg)
      opts = getOpts msg
      pluralisation = if opts.services.length == 1 then '' else 's'
      msg.send "Pointing light service#{pluralisation}..."

      deploy.pointLight opts, (err, result) ->
        if (err)
          msg.reply 'Error: ' + err.message
        else
          serviceList = formatServices opts.services, result.commitDetails
          sha = result.commitDetails.sha.slice(0, 7)
          response = "Repointed on #{opts.env}:"
          _.forEach result.urls, (url, service) ->
            response += "\n`#{url}` → `#{service}@#{sha}`"

          msg.reply response
