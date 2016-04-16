Twit = require 'twit'
WSPubSubClient = require( "node-wspubsub" ).Client
Log = require( "yandlr" ) module : module
_ = require 'underscore'
conf = require './conf'

module.exports = class TwitterPublisher

  constructor : ( opts = {} ) ->
    @initialized =
#      conf.dump()
#      .then ( x ) =>
#        console.log x
      conf.get "twitterpub"
      .then ( config ) =>
        opts = _.extend twitterpub : config, opts
        @auth = opts.twitterpub.auth
        @endpoint = opts.twitterpub.endpoint or "user"
        @timeout = opts.twitterpub.timeout
        conf.get "wspubsub"
      .then ( config ) =>
        opts = _.extend wspubsub : config, opts
        @url = opts.wspubsub.url

        @ws = new WSPubSubClient name : "twitterpub", url : @url
        @autoRestart = true

    @initialized.done()

  start : =>
    @initialized
    .then => @startTwitter()
    .fail ( err ) =>
      Log.e err
      throw err
    .done()

  stop : =>
    Log.i "stop"
    @autoRestart = false
    @twitterStream.stop()

  startTwitter : =>
    Log.i "twitter - connecting to endpoint: #{@endpoint}"

    opts = _.extend @auth, timeout_ms : @timeout
    @T = new Twit opts
    @twitterStream = @T.stream @endpoint

    @twitterStream.on 'connected', => Log.i "twitter - connected"
    @twitterStream.on 'reconnect', ( req, res, time ) =>
      Log.i "twitter - reconnecting in #{time} ms"
    #      @T = undefined
    #      setTimeout (=>@startTwitter()), @timeout
    #      @timeout += 500

    @twitterStream.on 'tweet', ( tweet ) =>
      Log.i "twitter - tweet #{JSON.stringify tweet}"
      @ws.publish "tweet", tweet

    @twitterStream.on 'error', ( err ) =>
      Log.e "twitter - error: #{JSON.stringify err}"

