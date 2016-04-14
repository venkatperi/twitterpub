Twit = require 'twit'
conf = require './conf'
WSPubSubClient = require( "node-wspubsub" ).Client
Log = require( "yandlr" ) module : module
conf = require "./conf"
_ = require 'underscore'

module.exports = class TwitterPublisher

  constructor : ( opts = {} ) ->
    @initialized =
      conf.get "twitterpub"
      .then ( config ) =>
        opts = _.extend twitterpub : config, opts
        @auth = opts.twitterpub.auth
        @endpoint = opts.twitterpub.endpoint or "user"
        @timeout = opts.twitterpub.timeout
        conf.get "wspubsub"
      .then ( config ) =>
        opts = _.extend wspubsub: config, opts
        @url = opts.wspubsub.url

        @ws = new WSPubSubClient name : "twitterpub", url : @url
        @autoRestart = true

    @initialized.done()

  start : =>
    @initialized.then => @startTwitter()

  stop : =>
    Log.i "stop"
    @autoRestart = false
    @twitterStream.stop()

  startTwitter : =>
    Log.i "twitter - connecting to endpoint: #{@endpoint}"

    @T = new Twit @auth
    @twitterStream = @T.stream @endpoint

    @twitterStream.on 'connected', => Log.i "twitter - connected"
    @twitterStream.on 'reconnect', =>
      return unless @autoRestart
      Log.i "twitter - reconnecting in #{@timeout} ms"
      @T = undefined
      setTimeout (=>@startTwitter()), @timeout
      @timeout += 500

    @twitterStream.on 'tweet', ( tweet ) =>
      Log.i "twitter - tweet #{JSON.stringify tweet}"
      @ws.publish "tweet", tweet

    @twitterStream.on 'error', ( err ) =>
      Log.e "twitter - error: #{JSON.stringify err}"

