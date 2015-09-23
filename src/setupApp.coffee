module.exports = (System) ->
  (req, res, next) ->
    System.getSettings()
    .done (settings) ->
      if req?.body?.settings?.github
        # Process form
        updated = false
        for k, v of req.body.settings.github
          settings[k] = v
          updated = true
        if updated
          System.updateSettings settings
          .then ->
            # Done with this step. Continue!
            res.redirect "/admin/github/connect"
          return
      # Show the page for this step
      res.render 'app',
        settings:
          github: settings
        title: 'GitHub App Settings'
    , (err) ->
      next err
