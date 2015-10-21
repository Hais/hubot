
module.exports = (robot) ->
  robot.router.post "/statuspage", (req, res) ->
    console.log req.body
    res.send 'OK'