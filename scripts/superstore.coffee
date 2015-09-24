# Description:
#   Business cat
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot superstore name - create store name
#
# Author:
#   Hais Deakin <hais.deakin@socialsuperstore.com>

names = require '../data/superstorenames.json'

name = (msg) ->
  adj = msg.random names.adj
  noun = msg.random names.noun
  "#{adj} #{noun} Store"

module.exports = (robot) ->
  robot.respond /superstore name/i, (msg) ->
    msg.send name msg

  robot.respond /([0-9]+) superstore name/i, (msg) ->
    msgs = while msg.match[1] -= 1
      name msg
    msg.send msgs.join "\n"