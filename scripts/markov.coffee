# Description:
#   Fuckin' thing sucks
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   mimic <user>
#
# Author:
#   daniel
#
delimiters = /\s+|,\s+|\.\s+|\s*```.*```\s*/
start = "{{{START}}}"
stop = "{{{STOP}}}"

store_markov = (username, msg) ->
  username = username.toLowerCase()
  robot.brain.data.markov[username] || = {}
  markov = robot.brain.data.markov[username]
  previous_word = start
  words = msg.split delimiters
  for word in words.concat stop
    markov[previous_word] ||= []
    markov[previous_word].push(word)
    previous_word = word

generate_markov = (username) ->
  username = username.toLowerCase()
  word = start
  sentence = ""
  markov = robot.brain.data.markov[username]
  if markov == undefined
    return "No markov model for " + username + " yet"
  while true
    next_word = markov[word][Math.floor(Math.random() * markov[word].length)]
    break if next_word == stop
    sentence = sentence + " " + next_word
    word = next_word
  return sentence

erase_markov = (username) ->
  robot.brain.data.markov[username] = undefined

module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.markov || = {}

  robot.hear /(.*)/i, (msg) ->
    username = msg.message.user.name.toLowerCase()
    if (!msg.message.text.startsWith "--") and (!msg.message.text.startsWith "hubot")
       store_markov(username, msg.message.text)

  robot.respond /mimic (.*)/i, (msg) ->
    username = msg.match[1].toLowerCase().replace(/^@/, "")
    msg.send generate_markov(username)

  robot.respond /unmimic (.*)/i, (msg) ->
    username = msg.match[1].toLowerCase().replace(/^@/, "")
    erase_markov(username)
