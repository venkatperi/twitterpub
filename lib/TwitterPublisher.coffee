Twit = require 'twit'
WebSocket = require "ws"
conf = require './conf'

module.exports = class TwitterPublisher
  constructor : ( opts = {} ) ->
    @T = new Twit opts.twitter?.auth or conf.get "twitter:auth" 
    @endpoint = opts.twitter?.endpoint or conf.get "twitter:endpoint"
    @url = opts.wspubsub?.url or conf.get "wspubsub:url"
    @timeout = opts.timeout or 1000
    @wsOpen = false

  start : =>
    @startWebSocket()
    @startTwitter()

  stop : =>
    @twitterStream.stop()

  startWebSocket: =>
    @ws = new WebSocket @url
    @ws.on "open", =>
      @wsOpen = true

  startTwitter : =>
    console.log "Connecting to twitter (/#{@endpoint})"
    @twitterStream = @T.stream @endpoint

    @twitterStream.on 'tweet', ( tweet ) =>
      if @wsOpen
        msg = command: "PUBLISH", channel: "tweet", message: tweet
        @ws.send JSON.stringify(msg)

    @twitterStream.on 'error', ( err ) =>
      console.log err.message
      console.log "Retrying in #{@timeout} ms"
      setTimeout @createTwitterStream, @timeout
      @timeout += 500

