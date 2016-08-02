module.exports = (robot) ->
  robot.hear /([0-9A-Fa-f]{6,})...?([0-9A-Fa-f]{6,})/i, (msg) ->
    msg.reply "https://github.com/SocialSuperstore/superstore/compare/#{msg.match[1]}...#{msg.match[2]}"
