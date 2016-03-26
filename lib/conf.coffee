Conf = require 'node-conf'

opts =
  name : "twitterpub"
  dirs :
    "factory" : "#{__dirname}/.."

conf = Conf( opts )

module.exports = conf


