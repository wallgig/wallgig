class Wallgig.Managers.SubscribeButton
  constructor: (@elements) ->
  
  execute: ->
    @elements.click $.proxy(@onClick, @)

  onClick: (e) ->
    e.preventDefault()

    $el = $(e.currentTarget)
    url = $el.data('url')

    $.post url, (data) =>
      if data.subscription_state == true
        @applyUnsubscribeState($el)
      else
        @applySubscribeState($el)

    null

  applySubscribeState: ($el) ->
    $el.removeClass('subscribed')
       .html('<span class="glyphicon glyphicon-plus"></span> Subscribe')

  applyUnsubscribeState: ($el) ->
    $el.addClass('subscribed')
       .html('<span class="glyphicon glyphicon-minus"></span> Unsubscribe')
