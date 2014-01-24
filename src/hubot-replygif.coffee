cheerio = require('cheerio')
request = require('request')
format = require('util').format

module.exports = (robot) ->
  robot.respond /reaction (\w+)/, (msg) ->
    msg.reply "hello! #{msg.match[1]}"
