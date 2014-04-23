$ ->
  API_PATH = '/api/v1/notifications/unread.json'
  LIMIT = 10 # Notifications to show
  ITEM_TEMPLATE = _.template '
    <li>
      <a href="<%- notification.url %>">
        <span data-provide="wgtext"><%- notification.message %></span>
        <small data-provide="time-ago" class="text-muted" title="<%- notification.created_at %>"><%- notification.created_at %></small>
      </a>
    </li>'

  canReload = true

  # Elements
  $dropdown = $('.dropdown.user-notifications')
  $dropdownMenu = $dropdown.find('.dropdown-menu')
  $status = $dropdownMenu.find('.status')
  $icon = $dropdown.find('.fa')

  status =
    loading: ->
      $status
        .html('Loading&hellip;')
        .show()
    empty: ->
      $status
        .text('No new notifications')
        .show()
    hide: ->
      $status
        .hide()

  bell =
    present: ->
      $icon
        .addClass('bell')
        .removeClass('bell-o')
    empty: ->
      $icon
        .removeClass('bell')
        .addClass('bell-o')

  buildMarkReadOnClick = (markReadPath) ->
    (e) ->
      e.preventDefault()

      url = $(this).attr('href')

      $.ajax
        type: 'POST'
        url: markReadPath,
        dataType: 'json'

      if url.length > 0
        redirect = ->
          document.location.href = url
        setTimeout redirect, 100

  renderItems = (data) ->
    _.forEach data.notifications, (notification) ->
      markReadPath = data._links.mark_read.replace ':id', notification.id

      $(ITEM_TEMPLATE(notification: notification))
        .find('a[href]')
          .on('click', buildMarkReadOnClick(markReadPath))
          .end()
        .insertAfter($status)

    $(document)
      .trigger 'wg:bind-time-ago'
      .trigger 'wg:bind-wgtext'

  onShowDropdown = ->
    if canReload
      status.loading()
      $.getJSON API_PATH, limit: LIMIT, (data) ->
        if _.isEmpty(data.notifications)
          status.empty()
          bell.empty()
        else
          renderItems(data)
          status.hide()
          bell.present()
          canReload = false

  # Bind events
  $dropdown.on 'show.bs.dropdown', onShowDropdown