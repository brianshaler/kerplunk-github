module.exports = (System) ->
  (req, res, next) ->
    System.getSettings()
    .done (settings) ->
      isSetup = false
      if settings.clientSecret and settings.accessToken
        isSetup = true

      # Show the page for this step
      res.render 'connect',
        title: 'Connect to GitHub'
        settings:
          github: settings
        isSetup: isSetup
    , (err) ->
      next err
