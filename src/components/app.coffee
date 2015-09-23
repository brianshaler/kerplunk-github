React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    DOM.section
      className: 'content admin-panel'
    ,
      DOM.h1 null, 'GitHub Configuration'
      DOM.p null,
        'Copy the details from your GitHub App, which you can find or create at '
        DOM.a
          href: 'https://github.com/settings/applications/new'
          target: '_blank'
        , 'https://github.com/settings/applications/new'
      DOM.p null,
        DOM.form
          method: 'post'
          action: '/admin/github/app'
        ,
          DOM.table null,
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Client ID:'
              DOM.td null,
                DOM.input
                  name: 'settings[github][clientId]'
                  defaultValue: @props.settings?.github?.clientId
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Client Secret:'
              DOM.td null,
                DOM.input
                  name: 'settings[github][clientSecret]'
                  defaultValue: @props.settings?.github?.clientSecret
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Callback URL:'
              DOM.td null,
                DOM.input
                  name: 'settings[github][callbackUrl]'
                  defaultValue: @props.settings?.github?.callbackUrl
            DOM.tr null,
              DOM.td null, ''
              DOM.td null,
                DOM.input
                  type: 'submit'
                  value: 'Save & Next'
