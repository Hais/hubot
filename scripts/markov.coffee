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
delimeters = /\s+|,\s*|\.\s*/
start = "{{{START}}}"
stop = "{{{STOP}}}"
users_whitelist = ["keigo", "bronsa", "daniel", "mikey", "james", "mrlee", "george", "dave", "Shell"]

store_markov = (username, msg) ->
  robot.brain.data.markov[username] || = {}
  markov = robot.brain.data.markov[username]
  previous_word = start
  words = msg.split delimeters
  for word in words.concat stop
    markov[previous_word] ||= []
    markov[previous_word].push(word)
    previous_word = word


generate_markov = (username) ->
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

module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.markov || = {}

  robot.hear /(.*)/i, (msg) ->
    if msg.message.user.name in users_whitelist
      store_markov(msg.message.user.name, msg.match[1])

  robot.respond /mimic (.*)/i, (msg) ->
    msg.send generate_markov(msg.match[1])
