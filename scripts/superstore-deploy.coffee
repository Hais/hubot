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
    version: msg.match[2],
    env: msg.match[3]
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

  robot.hear /create rc for (.*) at (.*) on (.*)/i, (msg) ->
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

  robot.hear /delete rc for (.*) at (.*) on (.*)/i, (msg) ->
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

  robot.hear /point dark for (.*) at (.*) on (.*)/i, (msg) ->
    if (shouldDeploy msg)
      opts = getOpts msg
      pluralisation = if opts.services.length == 1 then '' else 's'
      msg.send "Pointing dark service#{pluralisation}..."

      deploy.pointDark opts, (err, result) ->
        if (err)
          msg.reply 'Error: ' + err.message
        else
          serviceList = formatServices opts.services, result.commitDetails
          response = "Pointed dark on #{opts.env} at : #{serviceList}\n"
          response += formatCommit result.commitDetails
          _.forEach result.urls, (url, service) ->
            response += "\n`#{service}: #{url}`"

          msg.reply response

  robot.hear /point light for (.*) at (.*) on (.*)/i, (msg) ->
    if (shouldDeploy msg)
      opts = getOpts msg
      pluralisation = if opts.services.length == 1 then '' else 's'
      msg.send "Pointing light service#{pluralisation}..."

      deploy.pointLight opts, (err, result) ->
        if (err)
          msg.reply 'Error: ' + err.message
        else
          serviceList = formatServices opts.services, result.commitDetails
          response = "Pointed light on #{opts.env} at : #{serviceList}\n"
          response += formatCommit result.commitDetails
          _.forEach result.urls, (url, service) ->
            response += "\n`#{service}: #{url}`"

          msg.reply response
