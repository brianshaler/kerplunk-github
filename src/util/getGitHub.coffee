_ = require 'lodash'
GitHubApi = require 'github'
Promise = require 'when'
Promisify = require('when/node').lift

module.exports = (System) ->
  ghKey = null
  ghCache = null

  (settings) ->
    key = [
      settings.clientId
      settings.clientSecret
      settings.callbackUrl
      settings.accessToken
    ].join ','
    return ghCache if ghKey == key
    ghKey = key

    accessToken = settings.accessToken ? ''
    clientId = settings.clientId ? ''
    clientSecret = settings.clientSecret ? ''

    opt = if accessToken.length > 0
      type: 'oauth'
      token: settings.accessToken
    else if clientId.length > 0 and clientSecret.length > 0
      type: 'oauth'
      key: clientId
      secret: clientSecret
    else
      null

    api = new GitHubApi
      version: '3.0.0'
      # debug: true
      headers:
        'user-agent': 'Kerplunk'

    if opt?
      api.authenticate opt

    ghCache =
      api: api
      isSetup: opt?
      isAuthenticated: accessToken.length > 0
      user:
        get: Promisify api.user.get
        getFollowing: Promisify api.user.getFollowing
        getFrom: Promisify api.user.getFrom
      events:
        getReceived: Promisify api.events.getReceived
        getFromUser: Promisify api.events.getFromUser
        getFromUserPublic: Promisify api.events.getFromUserPublic
      repos:
        getStarredFromUser: Promisify api.repos.getStarredFromUser
      timeline:
        get: (params) ->
          Promise.promise (resolve, reject) ->
            msg = {}
            block =
              url: '/events'
              method: 'GET'
              params: params
            console.log 'msg', msg, 'block', block
            api.httpSend msg, block, (err, data) ->
              return reject err if err
              resolve data
      # Checkins:
      #   getRecentCheckins: promiseWithToken api.Checkins.getRecentCheckins
      # Users:
      #   getCheckins: promiseWithToken api.Users.getCheckins
      #   getUser: promiseWithToken api.Users.getUser
      # getAccessToken: Promisify api.getAccessToken
      # getAuthClientRedirectUrl: api.getAuthClientRedirectUrl
