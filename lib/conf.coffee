nconf = require 'nconf'
Q = require 'q'

HOME_DIR = process.env.HOME
nconf.file 'global',  "#{HOME_DIR}/.twitterpub"
nconf.file 'local', "./app.conf"

module.exports = exports =
  nconf : nconf

  get : ( key ) ->
    nconf.get key

  set : ( key, value ) ->
    d = Q.defer()
    nconf.set key, value
    nconf.save ( err ) ->
      return d.reject( err ) if err?
      d.resolve value

    d.promise


