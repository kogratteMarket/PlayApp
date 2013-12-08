class FacebookClient
  constructor: (@appId) ->
    that = this

    window.fbAsyncInit = ->
      sdkParameters =
        appId      : that.appId
        status     : true
        xfbml      : true
      FB.init sdkParameters
      $(document).trigger 'FbApiReady'

    @loadSdk document, 'script', 'fb-jssdk'

  loadSdk: (d, s, id) ->
    fjs = d.getElementsByTagName(s)[0]
    return if d.getElementById(id)
    js = d.createElement s
    js.id = id
    js.src = '//connect.facebook.net/en_US/all.js'
    fjs.parentNode.insertBefore js, fjs

  requestAccess: ->
    that = this

    FB.login((response) ->
      if response.authResponse
        $(document).trigger 'FbAccessGranted'
      else
        $(document).trigger 'FbAccessDenied'
    , { scope: 'email' })

  getInformations: () ->

    FB.api '/me', (response) ->
      if !response || response.error
        $(document).trigger 'FbUserDataRetrieveFailed', response
      else
        $(document).trigger 'FBDataFetched', response


window.facebookClient = FacebookClient