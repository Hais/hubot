# Description:
#   Listener for commits that are pushed to bitbucket
#
# Configuration:
#   HUBOT_BITBUCKET_PUSH_URL url to listen for
#   HUBOT_BITBUCKET_PUSH_EVENT event to emit when a push is made
#
# Commands:
#   None
#
# Author:
#   andrewtarry
#

moment = require('moment')

bitbucketPushUrl = process.env.HUBOT_BITBUCKET_PUSH_URL or '/bitbucket/push/:room'
bitbucketPushEvent = process.env.HUBOT_BITBUCKET_PUSH_EVENT or 'bitbucketPushReceived'

jiraUrl = process.env.HUBOT_JIRA_LOOKUP_URL
pattern = process.env.HUBOT_JIRA_PROJECTS || ""
jiraPattern = new RegExp "(#{pattern})-[0-9]{1,10}", 'gi'

timezone = process.env.HUBOT_BITBUCKET_TIMEZONE or "Europe/London"

module.exports = (robot) ->

  # Listen for bitbucket sending a commit
  #
  # The push listener will only parse the body and emit an event to be picked
  # up elsewhere
  robot.router.post bitbucketPushUrl, (req, res) ->
#    push = Push.parse req.body

    robot.emit bitbucketPushEvent,
      res: req.body # in case you prefer using json response directly
      room: req.params.room
    res.send 'OK'


  robot.on bitbucketPushEvent, (pushEvent) ->
    res = pushEvent.res # using json data directly here

    commit = res.push.changes[0].new

    title_link = res.push.changes[0].links.html.href if res.push.changes[0].links?.html?

    for change in res.push.changes
      fields = for commit in change.commits when commit.author?.user?
        title: commit.author.user.display_name
        value: "<#{commit.links.html.href}|" + commit.hash.substring(0, 7) + "> " + formatMessage commit.message
        short: false

      str = if change.truncated then "Several  new commits"
      else if change.commits.length > 1 then "#{change.commits.length} new commits"
      else "One new commit"

      title = "#{str} to #{change.new.type} `#{change.new.name}` - " + moment(change.new.target.date).tz(timezone).calendar()

      robot.emit 'slack.attachment',
        message: "Pushes"
        channel: "#" + pushEvent.room
        username: "BitBucket"
        icon_url: "https://slack.global.ssl.fastly.net/0c91/plugins/bitbucket/assets/service_128.png"
        content:
          title: title
          title_link: title_link
          fields: fields


  formatMessage = (msg) ->
    if pattern then msg .replace jiraPattern, (match) ->
         "<#{jiraUrl}/browse/#{match}|#{match}>"
    else msg
