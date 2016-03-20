should = require( "should" )
assert = require( "assert" )
TwitterPublisher = require '../lib/TwitterPublisher'

server = {}

describe "TwitterPublisher", ->
  it "start the server", ->
    server = new TwitterPublisher()
    server.start()

  
  it "stop the server", ->
    server.stop()
