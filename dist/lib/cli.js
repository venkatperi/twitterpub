var TwitterPublisher, conf, parser, startServer;

parser = require('nomnom');

TwitterPublisher = require("./TwitterPublisher");

conf = require("./conf");

startServer = function(opts) {
  var server;
  server = new TwitterPublisher(opts);
  server.start();
  return process.on('SIGINT', function() {
    server.stop();
    return setTimeout((function() {
      return process.exit(0);
    }), 300);
  });
};

parser.script("twitterpub");

parser.command("start").help("Start twitterpub server").callback(startServer);

parser.parse();
