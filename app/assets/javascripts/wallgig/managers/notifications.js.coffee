class Wallgig.Managers.Notifications
  constructor: (@elements) ->

  execute: ->
    @elements.on 'click', '[data-notification-id]', $.proxy(@onClick, @)

  onClick: (e) ->
    e.preventDefault()

    $currentTarget = $(e.currentTarget)
    url = $currentTarget.attr('href')
    id  = $currentTarget.data('notification-id')
    markReadUrl = "/notifications/#{id}/mark_as_read"

    $.ajax
      type: 'POST'
      url: markReadUrl,
      dataType: 'json'
      success: ->
        $currentTarget.removeClass('unread')

    redirect = () ->
      document.location.href = url
    setTimeout redirect, 100
