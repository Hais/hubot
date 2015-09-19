# Description:
#   Translate
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot gangsta <topic> - translate yo' lyrics tha fuck into gangsta
#   hubot hckr <topic> - tfransl8 yor wrods onto haX0r
#   hubot cockney <topic> - translate yor words into cockney
#   hubot redneck <topic> - translate yer wo'ds into redneck
#   hubot jibe <topic> - translate yo' wo'ds into JIBE
#   hubot fudd <topic> - twanswate youw wowds into Elmer Fudd
#   hubot bork <topic> - trunslete-a yuoor vurds intu Svedeesh cheff
#   hubot moron <topic> - translate your words into moron
#   hubot piglatin <topic> - anslatetray youray ordsway intoyay igpay atinlay
#   hubot censor <topic> - censor your [fork]ing words
#
# Author:
#   Hais

WIKI_API_URL = "https://en.wikipedia.org/w/api.php"
WIKI_EN_URL = "https://en.wikipedia.org/wiki"

cheerio = require('cheerio')
querystring = require("querystring")

module.exports = (robot) ->

  robot.respond /gangsta (.+)/i, (msg) ->
    getWiki msg.match[1], msg, (text) ->
        translateGangster msg, text

  robot.respond /(redneck|jive|hacker|cockney|fudd|bork|moron|piglatin|hckr|censor) (.*)/i, (msg) ->
    getWiki msg.match[2], msg, (text) ->
      rinkworks msg.match[1], msg, text

getWiki = (topic, msg, cb) ->
  params =
    action: 'query'
    exintro: true
    explaintext: true
    format: 'json'
    prop: 'extracts'
    titles: topic

  wikiRequest msg, params, (object) ->
    for id, article of object.query.pages
      if id is -1
        summary "The article you have entered (\"#{msg.match[1]}\") does not exist. Try a different article."
      else if article.extract is ""
        summary = "No summary available"
      else
        summary = article.extract.split(". ")[0..1].join ". "
    cb summary

createURL = (title) ->
  "#{WIKI_EN_URL}/#{encodeURIComponent(title)}"

wikiRequest = (msg, params = {}, handler) ->
  msg.http(WIKI_API_URL)
  .query(params)
  .get() (err, res, body) ->
    if err
      msg.reply "An error occurred while attempting to process your request: #{err}"
      return robot.logger.error err

    handler JSON.parse(body)


translateGangster = (msg, text) ->
  msg.http("http://www.gizoogle.net/textilizer.php")
  .header('content-type', 'application/x-www-form-urlencoded')
  .post(querystring.stringify({translatetext: text, name: "Tranzizzle Dis Shiznit"})) (err, res, body) ->
    msg.send '>' + cheerio.load(body)('textarea').text().trim().replace(/(?:\r\n|\r|\n)/g, "_\n>_")

rinkworks = (dialect, msg, text) ->
  msg.http("http://www.rinkworks.com/dialect/dialectt.cgi")
  .header('content-type', 'application/x-www-form-urlencoded')
  .post(querystring.stringify({text: text, dialect: dialect})) (err, res, body) ->
    msg.send '>' + cheerio.load(body)('div.dialectized_text p').text().trim().replace(/(?:\r\n|\r|\n)/g, "\n>")
