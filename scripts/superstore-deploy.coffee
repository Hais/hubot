# Description:
#   Deploy stuffs
#
# Author:
#   d.aitken@socialsuperstore.com

git = require('../lib/superstore/git')
deploy = require('../lib/superstore/deploy')
_ = require('lodash')

getOpts = (msg) ->
  opts = {
    services: msg.match[1].replace(/[ ]/g, ''),
    sha: msg.match[2],
    env: msg.match[3]
  }

shouldDeploy = (msg) ->
  return (msg.message.room == 'Shell' or msg.message.room == 'tech-deploys' or msg.message.room == msg.message.user.name)

darkUrls = (opts) ->
  services = opts.services.split(',')
  env = opts.env
  sha = opts.sha

  urls = '```\n'
  _.forEach services, (s) ->
   if s == 'api'
     if env == 'live'
       urls += "api@#{sha}: https://api-dark.socialsuperstore.com\n"
     else
       urls += "api@#{sha}: https://#{env}-api-dark.socialsuperstore.com\n"

    if s == 'app'
      if env == 'live'
        urls += "app@#{sha}: https://dark.socialsuperstore.com\n"
      else
        urls += "app@#{sha}: https://#{env}-dark.socialsuperstore.com\n"
  
  urls += '```'
  return urls

lightUrls = (opts) ->
  services = opts.services.split(',')
  env = opts.env
  sha = opts.sha

  urls = '```\n'
  _.forEach services, (s) ->
   if s == 'api'
     if env == 'live'
       urls += "api@#{sha}: https://api.socialsuperstore.com\n"
     else
       urls += "api@#{sha}: https://#{env}-api.socialsuperstore.com\n"

    if s == 'app'
      if env == 'live'
        urls += "app@#{sha}: https://socialsuperstore.com\n"
      else
        urls += "app@#{sha}: https://#{env}.socialsuperstore.com\n"
  
  urls += '```'
  return urls

module.exports = (robot) ->

  robot.hear /create rc for (.*) at (.*) on (.*)/i, (msg) ->
    if (shouldDeploy msg)
      opts = getOpts msg
      msg.send 'Creating RC...'
      deploy.deployCmd 'create-rc', opts, (err) ->
        if (err)
          msg.reply 'Error: ' + err.message
        else
          msg.reply 'Replication controller created'

  robot.hear /delete rc for (.*) at (.*) on (.*)/i, (msg) ->
    if (shouldDeploy msg)
      opts = getOpts msg
      msg.send 'Deleting RC...'
      deploy.deployCmd 'delete-rc', opts, (err) ->
        if (err)
          msg.reply 'Error: ' + err.message
        else
          msg.reply 'Replication controller deleted'

  robot.hear /point dark for (.*) at (.*) on (.*)/i, (msg) ->
    if (shouldDeploy msg)
      opts = getOpts msg
      msg.send 'Pointing dark...'
      deploy.deployCmd 'point-dark', opts, (err) ->
        if (err)
          msg.reply 'Error: ' + err.message
        else
          msg.reply 'Complete'
          msg.send(darkUrls opts)

  robot.hear /point light for (.*) at (.*) on (.*)/i, (msg) ->
    if (shouldDeploy msg)
      opts = getOpts msg
      msg.send 'Pointing light...'
      deploy.deployCmd 'point-light', opts, (err) ->
        if (err)
          msg.reply 'Error: ' + err.message
        else
          msg.reply 'Complete'
          msg.send(lightUrls opts)
