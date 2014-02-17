class Wallgig.Managers.Notifications
  constructor: (@elements) ->

  execute: ->
    @elements.on 'click', '.unread[data-mark-read-url]', $.proxy(@onClick, @)

  onClick: (e) ->
    e.preventDefault()

    $currentTarget = $(e.currentTarget)
    url            = $currentTarget.attr('href')
    markReadUrl    = $currentTarget.data('mark-read-url')

    $.ajax
      type: 'POST'
      url: markReadUrl,
      dataType: 'json'
      success: ->
        $currentTarget.removeClass('unread')

    redirect = () ->
      document.location.href = url
    setTimeout redirect, 100
