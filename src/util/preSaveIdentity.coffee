
module.exports = (System, getGitHub) ->

  (identity) ->
    return identity unless identity?.data?.github?.login
    System.getSettings()
    .then getGitHub
    .then (api) ->
      api.user.getFrom
        user: identity.data.github.login
    .then (user) ->
      return identity unless user?.login
      identity.data.github = user
      identity.nickName = user.login
      identity.fullName = user.name ? user.login
      [firstName, lastNames...] = identity.fullName.split ' '
      identity.firstName = firstName
      identity.lastName = lastNames.join ' '
      identity
    .catch (err) ->
      console.log 'util/preSaveIdentity', err
      identity
