parser = require( 'nomnom' )
TwitterPublisher = require "./TwitterPublisher"
conf = require "./conf"

startServer =  (opts) ->
  server = new TwitterPublisher opts
  server.start()

parser.script "twitterpub"
parser.command "start"
.help "Start twitterpub server"
.callback startServer

parser.parse()

