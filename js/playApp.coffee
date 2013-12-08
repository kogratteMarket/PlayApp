class PlayApp
  @defaults =
    article: ''
    errorClass: 'error'
    verticalGutter: 10
    facebookAppId: undefined
    form: undefined,
    errorArea: undefined
    successArea: undefined

  # Class constructor
  constructor: (@params) ->
    @options = $.extend true, {}, @params, @defaults

    console?.log @options

    @createArticleScrollbars()
    @initRequiredField()
    @handleFormSubmit()

    that = this

    @options.errorArea.find('button').on 'click', (e) ->
      that.hideErrorArea()
      that.showForm()

    if @options.form
      @firstNameField = @options.form.find 'input[name="firstName"]'
      @lastNameField = @options.form.find 'input[name="lastName"]'
      @emailField = @options.form.find 'input[name="email"]'

      if @options.facebookAppId
        @runFbProcess()

  # Show / Hide methods
  showForm: ->
    @options.form.slideDown 'fast'

  showErrorArea: ->
    @options.errorArea.slideDown 'fast'

  hideForm: (callback) ->
    @options.form.slideUp 'fast', callback

  hideErrorArea: (callback) ->
    @options.errorArea.slideUp 'fast', callback

  showSuccessResponse: ->
    @hideForm()
    @options.successArea.slideDown 'fast'

  # Create the FacebookClient, and bind event to handle all the facebook data retrieving process
  runFbProcess: ->
    that = this

    $(document)
      .on 'FbApiReady', (e) ->
          console?.log "FacebookAPI Ready, request Access"
          that.facebookApp.requestAccess()

      .on 'FbAccessGranted', (e) ->
          console?.log 'Access granted, Retrieve FB Data'
          that.facebookApp.getInformations()

      .on 'FbAccessDenied', (e) ->
          console?.log 'Access denied by user.'

      .on 'FbUserDataRetrieveFailed', (e) ->
          console?.log 'Fb retrieve failed'

      .on 'FBDataFetched', (e, data) ->
          console?.log 'Fb data fetched', data

          if that.options.form
            that.firstNameField.val data.first_name
            that.emailField.val data.email
            that.lastNameField.val data.last_name


    @facebookApp = new facebookClient @options.facebookAppId

  # Css and JQuery tricks to be able to personnalize scrollbar
  createArticleScrollbars: ->
    @options.article.jScrollPane({
      verticalGutter: @options.verticalGutter
    })

    that = this

    $(window).on 'resize', (e) ->
      $(that.options.article).jScrollPane()

  # Just add a class to all label placed before each required field
  initRequiredField: ->
    that = this

    $('input[required]').each ->
      $(@).closest('.row').find('label').addClass 'required'

  # Handle form submit. Allow us to control required field if not supported by the client
  handleFormSubmit: ->
    that = this

    $('form').on 'submit', (e) ->
      e.preventDefault()

      firstName = that.firstNameField.val()
      if firstName == ''
        that.firstNameField.addClass "error"
        that.firstNameField.trigger 'focus'
        return false

      lastName = that.lastNameField.val()
      if lastName == ''
        that.lastNameField.addClass "error"
        that.lastNameField.trigger 'focus'
        return false

      email = that.emailField.val()
      if email == ''
        that.emailField.addClass 'error'
        that.emailField.trigger 'focus'
        return false

      ajaxParameters =
        ajax: 'add_user'
        firstname: firstName
        lastname: lastName
        email: email
        newsletter: 1 if $(this).find('input[name="nl"]').is(':checked')
        playapp: $(this).find('input[name="followPlayApp"]:checked').val()

      $.get that.options.apiHost, ajaxParameters, (data) ->
        if data.status == 'OK'
          console?.log data.datas
          that.renderPlayAppResponse data.datas
        else
          that.renderPlayAppError data.message
      , 'JSON'

  # Render errors returned by the PlayApp API
  renderPlayAppError: (error) ->
    console?.log error

    return if @options.errorArea is null

    that = this
    @hideForm ->
      that.options.errorArea.find('.alert.alert-danger').html error
      that.showErrorArea()

  # Render the remote response
  renderPlayAppResponse: (data) ->

    console?.log data
    $("<div>" + k + ' : ' + data[k] + "</div>").appendTo @options.successArea.find('pre') for k of data

    @showSuccessResponse()


window.playApp = PlayApp