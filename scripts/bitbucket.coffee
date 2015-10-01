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

    repo_name = res.repository.full_name
    repo_url = res.repository.links.html.href
    commits_url = res.push.changes[0].links.html.href

    response = "[#{repo_name}] #{repo_url}\n"

    commit = res.push.changes[0].new

    new_commit_author_username = commit.target.author.user.username
    new_commit_author_display_name = commit.target.author.user.display_name
    new_commit_author_url = commit.target.author.user.links.html.href
    new_commit_hash = commit.target.hash
    new_commit_hash_short = new_commit_hash.substring 0,7
    new_commit_message = commit.target.message

    new_commit_type = commit.type
    new_commit_name = commit.name
    new_commit_on = new_commit_type + " " + new_commit_name

    response += "New commit(s) on #{new_commit_on}\n"
    response += "#{commits_url}\n"
    response += "#{new_commit_hash_short} #{new_commit_message}\n"
    response += " - #{new_commit_author_display_name} (#{new_commit_author_username})\n"

    fallback = response

    title_link = res.push.changes[0].links.html.href

    for change in res.push.changes
      fields = for commit in change.commits
        {
          title: commit.author.user.display_name
          value: "<" + commit.links.html.href + "|" + commit.hash.substring(0, 7) + "> " + formatMessage commit.message
          short: false
        }
      suffix = (change.truncated ? "+ new commits" : " new commit")
      length = change.commits.length
      title = "#{length}#{suffix}" + change.new.name + " - " + moment(change.new.target.date).fromNow()

      console.log robot.emit 'slack.attachment',
        message: "Pushes"
        channel: "#" + pushEvent.room
        username: "BitBucket"
        icon_url: "https://slack.global.ssl.fastly.net/0c91/plugins/bitbucket/assets/service_128.png"
        content:
          fallback: fallback
          title: title
          title_link: title_link
          fields: fields


  formatMessage = (msg) ->
    if pattern
      msg = msg .replace jiraPattern, (match) ->
         "<#{jiraUrl}/browse/#{match}|#{match}>"
    msg
