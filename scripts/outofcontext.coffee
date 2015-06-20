# Description:
#   Store a quote from a user, repeat it back to them at random times out of context.
#   Has a 1 in 200 (ish?) chance of delivering a quote whenever a person speaks.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot outofcontext <user name>: <message> - add a quote for a user
#   hubot ooc <user name>: <message> - add a quote for a user
#   hubot outofcontext rm <user name>: <message> - remove a quote for a user
#   hubot ooc rm <user name>: <message> - remove a quote for a user
#   hubot outofcontext ls <user name> - list quotes for a user
#   hubot ooc ls <user name> - list quotes for a user
#   hubot outofcontext random - show a random quote
#   hubot ooc random - show a random quote
#   hubot outofcontext stat - show statistics
#   hubot ooc stat - show statistics
#   hubot outofcontext 99 - sets randomness to 99
#   hubot ooc 99 - sets randomness to 99
#
# Author:
#   robotmay/hais

getQuotes = (robot) ->
  robot.brain.data.oocQuotes || {}

getUserQuotes = (robot, user) ->
  getQuotes(robot)[user.name] or= []

appendQuote = (robot, user, message) ->
  data = getQuotes robot
  data[user.name] or= []
  data[user.name].push message

removeQuote = (robot, user, message) ->
  index = getQuotes(robot, user).indexOf(message)
  data[user.name] = data[user.name].slice(index, 1)

userName = (user) ->
  user.real_name || user.name

printQuote = (msg, quote, user) ->
  msg.send ">#{quote}\n - _" + userName(user) + "_"

printQuoteForUser = (robot, msg, user) ->
  if (quotes = getUserQuotes(robot, user))
    randomQuote = quotes[Math.floor(Math.random() * quotes.length)]
    printQuote msg, randomQuote, user

findUserFuzzy = (robot, name) ->
  users = []
  brainUsers = robot.brain.users()
  console.log
  for key in Object.keys(brainUsers)
    user = brainUsers[key]
    users.push user if userName(user).toLowerCase().indexOf(name) >= 0
  return users

findUser = (robot, msg, name, callback) ->
  users = robot.brain.usersForFuzzyName name.trim()
  if users.length is 1
    user = users[0]
    callback(user)
  else
    users = findUserFuzzy robot, name.trim().toLowerCase()
    callback(users[0]) if users.length == 1
    msg.send "Too many users like #{name}" if users.length > 1
    msg.send "#{name}? Never heard of 'em" if users.length == 0

module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.oocQuotes ||= {}
    robot.brain.data.oocRandomness ||= 88

  robot.respond /outofcontext|ooc (?!rm )(.*?): (.*)/i, (msg) ->
    findUser robot, msg, msg.match[1], (user) ->
      #return msg.send "Denied. You narcissist." if user.name == msg.message.user.name
      appendQuote robot, user, msg.match[2]
      msg.send "Quote has been stored for future prosperity."

  robot.respond /outofcontext|ooc rm (.*?): (.*)/i, (msg) ->
    findUser robot, msg, msg.match[1], (user) ->
      removeQuote(robot, user, msg.match[2])
      msg.send "Quote has been removed from historical records."

  robot.respond /outofcontext|ooc ls (.*)/i, (msg) ->
    findUser robot, msg, msg.match[1], (user) ->
      if (quotes = getUserQuotes(robot, user))
        msg.send "No quotes for " + userName(user) if !quotes.length
        for quote in quotes
          printQuote msg, quote, user

  robot.respond /outofcontext|ooc stat/i, (msg) ->
    msg.send "Randomness is 1 in " + (robot.brain.data.oocRandomness)
    count = 0
    count += v.length for k, v of getQuotes(robot)
    msg.send "Quote count " + count

  robot.respond /outofcontext|ooc ([0-9]+)/i, (msg) ->
    robot.brain.data.oocRandomness = msg.match[1]
    msg.send "Entropy factored by " + msg.match[1]

  robot.respond /outofcontext|ooc random/i, (msg) ->
    keys = Object.keys(getQuotes(robot))
    username = msg.random keys
    findUser robot, msg, username, (user) ->
      printQuoteForUser robot, msg, user

  robot.hear /./i, (msg) ->
    printQuoteForUser(robot, msg, msg.message.user) if Math.floor(Math.random() * robot.brain.data.oocRandomness) == 0

