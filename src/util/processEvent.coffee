Promise = require 'when'

eventToActivityItem = require './eventToActivityItem'
userToIdentity = require './userToIdentity'

module.exports = (System) ->
  ActivityItem = System.getModel 'ActivityItem'
  Identity = System.getModel 'Identity'

  (event) ->
    types = [
      'CreateEvent'
      'ForkEvent'
      'WatchEvent'
    ]

    user = event.actor ? event.user
    unless -1 < types.indexOf event.type
      # ignore events i don't know how to phrase yet..
      return Promise.resolve
        err: 'unhandled'
        type: event.type ? event

    data =
      identity: userToIdentity user
      item: eventToActivityItem event

    Promise.promise (resolve, reject) ->
      ActivityItem.getOrCreate data, (err, item, identity) ->
        return reject err if err
        resolve
          item: item
          identity: identity
    .then ({item, identity}) ->
      identity.attributes.isFriend = true if user.isFriend
      identity.markModified 'attributes'
      System.do 'identity.save', identity
      .then ->
        System.do 'activityItem.save', item
      .then ->
        identity: identity
        item: item
    .catch (err) ->
      console.log 'processEvent err', err?.stack ? err
      err: err
