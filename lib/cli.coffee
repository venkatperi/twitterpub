conf = require "./conf"
parser = require( 'nomnom' )
TwitterPublisher = require "./TwitterPublisher"

startServer =  (opts) ->
  server = new TwitterPublisher opts
  server.start()

parser.script "twitterpub"
parser.command "start"
.help "Start twitterpub server"
.callback startServer

parser.parse()

