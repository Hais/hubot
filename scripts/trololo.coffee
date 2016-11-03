
fs = require 'fs'
util = require 'util'
os = require 'os'

template = fs.readFileSync('scripts/template.html');

tokens = {}

name = process.env.HUBOT_TROLOLO_NAME || "trololo"
hostname = os.hostname()
port = process.env.PORT || 8080

verifyToken = (user, token) ->
  tokenObj = tokens[user]
  return false if !token  || !user || !tokenObj
  return false if tokenObj.token != token

class Token

  constructor: () ->
    @token = uniqueId()
    @session = null

  login: (token) ->
    return false if this.session?
    @session = uniqueId()
    return this.session

  uniqueId = (length=32) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length

module.exports = (robot) ->

  robot.respond /trololo/i, (msg) ->
    token = new Token()
    userId = msg.message.user.id
    tokens[userId] = token
    msg.send "http://#{hostname}:#{port}/hubot/#{name}/login/#{userId}/#{token.token}"

  robot.router.get "/hubot/#{name}/channels", (req, res) ->
    res.set 'Content-type', 'application/json'
#    data = for id, channel of robot.adapter.client.channels when not channel.is_archived
#      id: id
#      name: channel.name
    data = [
      id: "foo"
      name: "Channel name"
    ]
    res.send JSON.stringify data

  robot.router.get "/hubot/#{name}/users", (req, res) ->
    res.set 'Content-type', 'application/json'
#    data = for id, user of robot.adapter.client.users
#      id: id
#      name: user.profile.real_name
#      avatar: user.profile.image_192
    data = [
      id: "user"
      name: "Test user"
      avatar: "https://media.licdn.com/mpr/mpr/shrinknp_400_400/AAEAAQAAAAAAAABBAAAAJDZlOWJmYjBiLWYxNzctNGY1Mi1iN2M0LTU3ZjA4YmQ2YmFlOA.jpg"
    ]
    res.send JSON.stringify data


  block = (res) ->
    res.set 'Content-type', 'text/html'
    return res.send(403, '<h1>Denied</h1><img src="http://regmedia.co.uk/2012/06/18/torvalds_bird.jpg" />')

  robot.router.get "/hubot/#{name}/login/:username/:token", (req, res) ->
    user = req.params.username
    tokenStr = req.params.token
    token = tokens[user]
    return block(res) if not token?
    res.send token


  robot.router.get "/hubot/#{name}", (req, res) ->

    res.set 'Content-type', 'text/html'

    if !verifyToken(user, token)
      return block(res)

    res.send template
