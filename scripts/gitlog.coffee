module.exports = (robot) ->
  robot.hear /([0-9A-Fa-f]{6,})...?([0-9A-Fa-f]{6,})/i, (msg) ->
    if msg.message.room == 'clojurians'
      msg.send "https://github.com/SocialSuperstore/superstore/compare/#{msg.match[1]}...#{msg.match[2]}"
