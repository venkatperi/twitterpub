var Log, Twit, TwitterPublisher, WSPubSubClient, conf, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Twit = require('twit');

conf = require('./conf');

WSPubSubClient = require("node-wspubsub").Client;

Log = require("yandlr")({
  module: module
});

conf = require("./conf");

_ = require('underscore');

module.exports = TwitterPublisher = (function() {
  function TwitterPublisher(opts) {
    if (opts == null) {
      opts = {};
    }
    this.startTwitter = __bind(this.startTwitter, this);
    this.stop = __bind(this.stop, this);
    this.start = __bind(this.start, this);
    this.initialized = conf.get("twitterpub").then((function(_this) {
      return function(config) {
        opts = _.extend({
          twitterpub: config
        }, opts);
        _this.auth = opts.twitterpub.auth;
        _this.endpoint = opts.twitterpub.endpoint || "user";
        _this.timeout = opts.twitterpub.timeout;
        return conf.get("wspubsub");
      };
    })(this)).then((function(_this) {
      return function(config) {
        opts = _.extend({
          wspubsub: config
        }, opts);
        _this.url = opts.wspubsub.url;
        _this.ws = new WSPubSubClient({
          name: "twitterpub",
          url: _this.url
        });
        return _this.autoRestart = true;
      };
    })(this));
    this.initialized.done();
  }

  TwitterPublisher.prototype.start = function() {
    return this.initialized.then((function(_this) {
      return function() {
        return _this.startTwitter();
      };
    })(this));
  };

  TwitterPublisher.prototype.stop = function() {
    Log.i("stop");
    this.autoRestart = false;
    return this.twitterStream.stop();
  };

  TwitterPublisher.prototype.startTwitter = function() {
    Log.i("twitter - connecting to endpoint: " + this.endpoint);
    this.T = new Twit(this.auth);
    this.twitterStream = this.T.stream(this.endpoint);
    this.twitterStream.on('connected', (function(_this) {
      return function() {
        return Log.i("twitter - connected");
      };
    })(this));
    this.twitterStream.on('reconnect', (function(_this) {
      return function() {
        if (!_this.autoRestart) {
          return;
        }
        Log.i("twitter - reconnecting in " + _this.timeout + " ms");
        _this.T = void 0;
        setTimeout((function() {
          return _this.startTwitter();
        }), _this.timeout);
        return _this.timeout += 500;
      };
    })(this));
    this.twitterStream.on('tweet', (function(_this) {
      return function(tweet) {
        Log.i("twitter - tweet " + (JSON.stringify(tweet)));
        return _this.ws.publish("tweet", tweet);
      };
    })(this));
    return this.twitterStream.on('error', (function(_this) {
      return function(err) {
        return Log.e("twitter - error: " + (JSON.stringify(err)));
      };
    })(this));
  };

  return TwitterPublisher;

})();
