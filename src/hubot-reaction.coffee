# Description:
#   https://github.com/jakswa/hubot-reaction
# 
# Configuration:
#   None
# 
# Commands:
#   !reply tag - returns reaction gif from replygif.net, with that tag
# 
# Author:
#   jakswa 
request = require('request')
cheerio = require('cheerio')
format = require('util').format
module.exports = (robot) ->
  robot.parseReplyGifTag = (text) ->
    text.toLowerCase().replace(/[^\w \-]+/g, '').replace(/--+/g, '').replace(/\ /g, '-')
  robot.hear /^!reply (.+)$/, (msg) ->
    tag = robot.parseReplyGifTag msg.match[1]
    url = 'http://replygif.net/t/%s'

    # page randomization logic
    # (after first request for tag)
    max_pages = maxPageNumber(tag)
    chosen_page = Math.floor(Math.random() * (max_pages + 1))
    url += "?page=#{chosen_page}" if chosen_page # do nothing if 0

    request format(url, tag), (err, resp, body) ->
      $ = cheerio.load(body)

      # last page parsing/caching logic
      last_page_link = $('li.pager-last a').attr('href')
      last_page_match = last_page_link.match(/page=(\d+)/) if last_page_link
      maxPageNumber(tag, parseInt(last_page_match[1])) if last_page_match

      gifs = $('img.gif')
      if gifs.length == 0
        robot.send {user: msg.message.user}, "no gifs for #{tag} -- probably invalid category/tag"
      else
        ind = Math.floor(Math.random() * gifs.length)
        msg.send gifs.eq(ind).attr('src').replace('thumbnail', 'i')
  robot.hear /\?reply/, (msg) ->
    robot.send {user: msg.message.user}, "stuff" # TODO: this part

  # while we're scraping pages, we can keep track of how many pages
  # and cyle through them randomly, after the first request
  maxPageNumbers = {} 
  maxPageNumber = (tag, number) ->
    maxPageNumbers[tag] = number if number
    maxPageNumbers[tag] || 0

