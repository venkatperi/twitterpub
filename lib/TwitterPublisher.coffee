Twit = require 'twit'
WebSocket = require "ws"
conf = require './conf'

module.exports = class TwitterPublisher
  constructor : ( opts = {} ) ->
    @T = new Twit opts.twitter?.auth or conf.get "twitter:auth" 
    @endpoint = opts.twitter?.endpoint or conf.get "twitter:endpoint"
    @url = opts.wspubsub?.url or conf.get "wspubsub:url"
    @timeout = opts.timeout or 2000

  start : =>
    @startWebSocket()
    @startTwitter()

  stop : =>
    @twitterStream.stop()

  startWebSocket: =>
    return if @ws? && @ws.readyState? && @ws.readyState == 1
    console.log "trying to connect to websocket server #{@url}"
    @ws = new WebSocket @url
    @ws.on "open", => console.log "connected to websocket server"
    @ws.on "close", => 
      console.log "websocket server connection closed"
      @ws = null
      setTimeout => @startWebSocket(),
      @timeout

  startTwitter : =>
    console.log "Connecting to twitter (/#{@endpoint})"
    @twitterStream = @T.stream @endpoint

    @twitterStream.on 'tweet', ( tweet ) =>
      return @startWebSocket() unless @ws.readyState == 1
      msg = command: "PUBLISH", channel: "tweet", message: tweet
      @ws.send JSON.stringify(msg)

    @twitterStream.on 'error', ( err ) =>
      console.log err.message
      console.log "Retrying in #{@timeout} ms"
      setTimeout @createTwitterStream, @timeout
      @timeout += 500

