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
# Push = require '../lib/Push'

bitbucketPushUrl = process.env.HUBOT_BITBUCKET_PUSH_URL or '/bitbucket/push/:room'
bitbucketPushEvent = process.env.HUBOT_BITBUCKET_PUSH_EVENT or 'bitbucketPushReceived'

module.exports = (robot) ->

  # Listen for bitbucket sending a commit
  #
  # The push listener will only parse the body and emit an event to be picked
  # up elsewhere
  robot.router.post bitbucketPushUrl, (req, res) ->
#    push = Push.parse req.body

    robot.emit bitbucketPushEvent,
      "res": req.body # in case you prefer using json response directly
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

    robot.messageRoom pushEvent.room, response

#    robot.emit 'slack.attachment',
#      message: msg.message
#      content:
#        fallback: fallback
#        title: "#{data.key.value}: #{data.summary.value}"
#        title_link: res.push.changes[0].links.html.href
#        text: data.description.value
#        fields: [
#          {
#            title: data.reporter.key
#            value: data.reporter.value
#            short: true
#          }
#          {
#            title: data.assignee.key
#            value: data.assignee.value
#            short: true
#          }
#          {
#            title: data.status.key
#            value: data.status.value
#            short: true
#          }
#          {
#            title: data.created.key
#            value: data.created.value
#            short: true
#          }
#        ]

