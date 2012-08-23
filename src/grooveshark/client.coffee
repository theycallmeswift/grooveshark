# Dependencies
request = require('request')
crypto = require('crypto')

# Constants
BASE_URL = "https://api.grooveshark.com/ws3.php"

# Client class
class Client

  constructor: (@key, @secret) ->
    @sessionID = null
    @authenticated = false

  ensureSessionStarted: (cb) ->
    if @sessionID
      return cb(null)
    else
      @request('startSession', {}, (err, status, body) =>
        return cb(err) if err

        @sessionID = body.sessionID
        cb(null)
      )

  generateRequestBody: (method, parameters, cb) ->
    unless method == 'startSession'
      @ensureSessionStarted((err) =>
        return cb(err) if err

        return cb(null, {
          method: method,
          parameters: parameters,
          header: { wsKey: @key, sessionID: @sessionID }
        })
      )
    else
      return cb(null, {
        method: method,
        parameters: parameters,
        header: { wsKey: @key }
      })

  urlWithSig: (body) ->
    sig = crypto.createHmac('md5', @secret).update(JSON.stringify(body)).digest('hex')
    "#{BASE_URL}?sig=#{sig}"

  request: (method, parameters = {}, cb) ->
    @generateRequestBody(method, parameters, (err, body) =>
      return cb(err) if err

      request({
        uri: @urlWithSig(body),
        method: 'POST',
        json: body,
      }, (err, res, body) =>
        return cb(err) if err

        if /^2..$/.test(res.statusCode)
          if body.errors && body.errors.length
            cb(body.errors, res.statusCode, body.result)
          else
            cb(null, res.statusCode, body.result)
        else
          cb(null, res.statusCode, body)
      )
    )

  authenticate: (username, password, cb) ->
    token = crypto.createHash('md5').update(password).digest("hex")
    @request('authenticate', {login: username, password: token}, (err, status, body) =>
      return cb(err) if err

      @authenticated = true
      cb(null)
    )

module.exports = Client
