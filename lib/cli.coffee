parser = require( 'nomnom' )
TwitterPublisher = require "./TwitterPublisher"
conf = require "./conf"

startServer = ( opts ) ->
  server = new TwitterPublisher opts
  server.start()

  process.on 'SIGINT', ->
    server.stop()
    setTimeout (->
      process.exit 0
    ), 300

parser.script "twitterpub"
parser.command "start"
.help "Start twitterpub server"
.callback startServer

parser.parse()

