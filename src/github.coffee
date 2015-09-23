_ = require 'lodash'
Promise = require 'when'

globals = require './globals'

# handlers
auth = require './auth'
oauth = require './oauth'
setupApp = require './setupApp'
setupConnect = require './setupConnect'
GetGitHub = require './util/getGitHub'

ProcessEvent = require './util/processEvent'
userToIdentity = require './util/userToIdentity'
eventToActivityItem = require './util/eventToActivityItem'

module.exports = (System) ->
  Identity = System.getModel 'Identity'
  ActivityItem = System.getModel 'ActivityItem'

  getGitHub = GetGitHub System
  # processEvent = ProcessEvent System

  saveUser = (user) ->
    identityObj = userToIdentity user
    Promise.promise (resolve, reject) ->
      Identity.getOrCreate identityObj, (err, identity) ->
        return reject err if err
        resolve identity

  routes:
    admin:
      '/admin/github': 'setupApp'
      '/admin/github/oauth': 'oauth'
      '/admin/github/auth': 'auth'
      '/admin/github/app': 'setupApp'
      '/admin/github/connect': 'setupConnect'

  handlers:
    oauth: oauth System, getGitHub
    auth: auth System, getGitHub
    setupApp: setupApp System
    setupConnect: setupConnect System

  methods:
    getUser: ->
      System.getSettings()
      .then (settings) ->
        settings?.user

  events:
    github:
      event:
        save:
          do: ProcessEvent System
      user:
        save:
          do: saveUser

  globals: _.clone globals, true

  jobsx:
    getFollowing:
      frequency: 86400
      task: ->
        System.getSettings()
        .then getGitHub
        .then (api) ->
          unless api.isAuthenticated == true
            throw new Error 'GitHub not setup and authenticated'
          api.user.getFollowing {}
        .then (data) ->
          return unless data?.length > 0
          console.log 'got following', data.length
          promise = Promise()
          for user in data
            do (user) ->
              promise = promise.then (identities = []) ->
                System.do 'github.user.save', user
                .then (identity) ->
                  user: user
                  identity: identity
                .catch (err) ->
                  err: err
                  user: user
                .then (result) ->
                  identities.push result
                  identities
          promise
    getEvents:
      frequency: 1200
      task: ->
        System.getSettings()
        .then (settings) ->
          api = getGitHub settings
          unless api.isAuthenticated == true
            throw new Error 'GitHub not setup and authenticated'
          unless settings.user?.login
            throw new Error 'missing user login'
          api.events.getReceived
            user: settings.user.login
        .then (data) ->
          return unless data?.length > 0
          console.log 'got events', data.length
          promise = Promise()
          for event in data
            do (event) ->
              promise = promise.then ->
                event.actor.isFriend = true if event.actor
                System.do 'github.event.save', event
              .catch (err) -> err
          promise
    getFriendsEvents:
      frequency: 1200
      task: ->
        System.getSettings()
        .then getGitHub
        .then (api) ->
          unless api.isAuthenticated == true
            throw new Error 'GitHub not setup and authenticated'
          mpromise = Identity
          .where
            platform: 'github'
            'attributes.isFriend': true
            'data.github.login':
              $exists: true
            $or: [
              {
                'attributes.gotFriendsEvents':
                  $gt: new Date Date.now() - 86400000
              }
              {
                'attributes.gotFriendsEvents':
                  $exists: false
              }
            ]
          .sort
            'attributes.gotFriendsEvents': 1
          .findOne()
          Promise mpromise
          .then (identity) ->
            unless identity
              console.log 'getFriendsEvents: nobody to check'
              return
            where =
              _id: identity._id
            delta =
              'attributes.gotFriendsEvents': new Date()
            options =
              multi: true
            mpromise = Identity
            .update where, delta, options
            Promise mpromise
            .then (updateResult) ->
              console.log 'go go github', identity.data.github.login, identity.attributes, updateResult
              api.repos.getStarredFromUser
                user: identity.data.github.login
        .then (data) ->
          console.log 'got friend events', data?.length
          return unless data?.length > 0
          Promise.all _.map data, (event) ->
            event.actor.isFriend = true if event.actor
            System.do 'github.event.save', event
