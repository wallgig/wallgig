$ ->
  $document = $(document)

  # Listen to 'wg:bind-time-ago' event
  $document.on 'wg:bind-time-ago', ->
    $('[data-provide=time-ago]:not(.binded)')
      .timeago()
      .addClass('binded')

  # Trigger bind
  triggerBind = -> $document.trigger 'wg:bind-time-ago'

  # Listen to ajaxSuccess events
  $document.ajaxSuccess triggerBind

  # Trigger once
  triggerBind()