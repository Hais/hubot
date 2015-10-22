# Description:
#   Statuspage thingey
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Author:
#   Hais


moment = require('moment')

timezone = process.env.HUBOT_STATUSPAGE_TIMEZONE or "Europe/London"

module.exports = (robot) ->
  return robot.logger.error "Missing configuration HUBOT_STATUSPAGE_ROOM" unless process.env.HUBOT_STATUSPAGE_ROOM?

  room = process.env.HUBOT_STATUSPAGE_ROOM

  robot.router.post "/statuspage", (req, res) ->
#    console.log req.body
    component = req.body.component
    update = req.body.component_update

    res.send 'OK'
    fields = []

    fields.push
      title: component.name
      value: "Changed from " + ucwords(update.old_status) + " to " + ucwords(update.new_status)

    fields.push
      title: "Updated"
      value: moment(update.created_at).tz(timezone).calendar()
      short: true

    if component.description?
      fields.push
        title: "Description"
        value: component.description
        short: false

    color = if update.new_status is "operational" then 'good' else 'danger'

    robot.emit 'slack.attachment',
      channel: "#" + room
      username: "StatusPage.io"
      icon_url: "http://dka575ofm4ao0.cloudfront.net/assets/base/apple-touch-icon-144x144-precomposed-94dc1d1bac88837fc28fa5706f7494aa.png"
      content:
        color: color
        fields: fields

ucwords = (str) ->
  str = str.replace('_', ' ')
  str.toLowerCase().replace /\b[a-z]/g, (letter) ->
    letter.toUpperCase()