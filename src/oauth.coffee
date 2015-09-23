{OAuth2} = require 'oauth'

module.exports = (System, getGitHub) ->
  (req, res, next) ->
    System.getSettings()
    .done (settings) ->
      oauth = new OAuth2 settings.clientId,
        settings.clientSecret
        'https://github.com/'
        'login/oauth/authorize'
        'login/oauth/access_token'
      res.writeHead 303,
        Location: oauth.getAuthorizeUrl
          redirect_uri: settings.callbackUrl
          scope: 'user,repo,gist'
      res.end()
    , (err) -> next err
