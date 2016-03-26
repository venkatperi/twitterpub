Twit = require 'twit'
conf = require './conf'
WSPubSubClient = require( "node-wspubsub" ).Client
Log = require( "node-log" )( module, "debug" )
conf = require "./conf"

module.exports = class TwitterPublisher
  constructor : ( opts = {} ) ->
    @auth = opts.twitter?.auth or conf.get "twitterpub:auth"
    @endpoint = opts.twitter?.endpoint or conf.get "twitterpub:endpoint"
    @url = opts.wspubsub?.url or conf.get "wspubsub:url"
    @timeout = opts.timeout? or conf.get "twitterpub:timeout" or 1000

    @ws = new WSPubSubClient name : "twitterpub", url : @url

  start : =>
    @startTwitter()

  stop : =>
    @twitterStream.stop()

  startTwitter : =>
    Log.i "twitter - connecting to endpoint: #{@endpoint}"

    @T = new Twit @auth
    @twitterStream = @T.stream @endpoint

    @twitterStream.on 'connected', => Log.i "twitter - connected"
    @twitterStream.on 'reconnect', => 
      Log.i "twitter - reconnect scheduled"
      setTimeout @startTwitter, @timeout += 500

    @twitterStream.on 'tweet', ( tweet ) =>
      Log.i "twitter - tweet #{JSON.stringify tweet}"
      @ws.publish "tweet", tweet

    @twitterStream.on 'error', ( err ) =>
      Log.e "twitter - error: #{JSON.stringify err}"

