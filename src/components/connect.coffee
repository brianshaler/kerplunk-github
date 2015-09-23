_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    #Avatar = @props.getComponent 'kerplunk-stream:avatar'
    DOM.section
      className: 'content admin-panel'
    ,
      DOM.p null,
        'We will now authenticate your user account to the app...'
      DOM.p null,
        DOM.a
          href: '/admin/github/oauth'
        , 'Click here to authenticate'
      if @props.settings?.github?.user
        DOM.div null,
          DOM.h4 null, 'Your account has been connected!'
          DOM.img
            src: @props.settings.github.user.avatar_url
            style:
              width: '48px'
          DOM.h4 null,
            @props.settings.github.user.name
            ' ('
            @props.settings.github.user.login
            ')'
      else
        null
