# Description:
#   Make hubot respect a table
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   (╯°□°）╯︵ ┻━┻ - Hubot unflips table
#
# Author:
#   hais

module.exports = (robot) ->

  robot.hear /┻([━]+)┻/i, (msg) ->
    unflips = [
      '┬──┬ ノ( ゜-゜ノ)',
      '┬─┬﻿ ︵ /(.□. \）',
      '-( °-°)- ノ(ಠ_ಠノ)',
      '┬─┬ノ(ಥ益ಥノ)',
      '┬─┬ノ(ಠ_ಠノ)'
      '눈_눈',
      'Please respect tables'
    ]
    msg.send msg.random unflips
