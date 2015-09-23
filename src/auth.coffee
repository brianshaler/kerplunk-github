Promise = require 'when'
{OAuth2} = require 'oauth'

userToIdentity = require './util/userToIdentity'




    # // URL called by github after authenticating
    # else if (path.match(/^\/github-callback\/?$/)) {
    #     // upgrade the code to an access token
    #     oauth.getOAuthAccessToken(query.code, {}, function (err, access_token, refresh_token) {
    #         if (err) {
    #             console.log(err);
    #             res.writeHead(500);
    #             res.end(err + "");
    #             return;
    #         }
    #
    #         accessToken = access_token;
    #
    #         // authenticate github API
    #         github.authenticate({
    #             type: "oauth",
    #             token: accessToken
    #         });
    #
    #         //redirect back
    #         res.writeHead(303, {
    #             Location: "/"
    #         });
    #         res.end();
    #     });
    #     return;


module.exports = (System, getGitHub) ->
  (req, res, next) ->
    unless req.query.code
      return next new Error 'no oauth code in query string'

    # get and apply accessToken
    System.getSettings()
    .then (settings) ->
      oauth = new OAuth2 settings.clientId,
        settings.clientSecret
        'https://github.com/'
        'login/oauth/authorize'
        'login/oauth/access_token'
      Promise.promise (resolve, reject) ->
        oauth.getOAuthAccessToken req.query.code, {}, (err, access_token, refresh_token) ->
          return reject err if err
          settings.accessToken = access_token
          resolve settings
    # fetch github user account
    .then (settings) ->
      # with accessToken now
      gh = getGitHub settings
      Promise.promise (resolve, reject) ->
        gh.api.user.get {}, (err, user) ->
          return reject err if err
          resolve user
      .catch (err) ->
        console.log 'getUser error', err?.stack ? err
        throw err
      .then (data) ->
        unless data?.id
          console.log data
        throw new Error "Couldn't find myself" unless data?.id
        settings.user = data
        # merge github profile information
        # with the `me` Identity
        # by creating a placeholder identity and then `linking`
        me = System.getMe()
        identity = userToIdentity settings.user
        Promise.promise (resolve, reject) ->
          me.link identity, (err) ->
            return reject err if err
            resolve settings
    .then (settings) ->
      # console.log 'auth now has settings:', settings
      {accessToken, user} = settings
      if !accessToken? or !user?
        throw new Error 'Something went wrong'
      System.updateSettings
        $set:
          accessToken: accessToken
          user: user
    .then ->
      res.redirect '/admin/github/connect'
    .catch (err) ->
      console.log 'error during github auth'
      console.log err?.stack ? err?.statusCode ? err
      next err
