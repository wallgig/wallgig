#= require lodash
#= require jquery
#= require jquery_ujs

# Bootstrap
#= require bootstrap

# Notifications
#= require jquery.bootstrap-growl
#= require bootbox

# Utilities
#= require panzoom
#= require selectize
#= require jquery.inview
#= require spin
#= require ladda
#= require jquery.cookie
#= require jquery.timeago

# Markdown
#= require markdown
#= require to-markdown
#= require bootstrap-markdown

# Typeahead
#= require typeahead.bundle

# v2
#= require v2/application

#= require_tree .
#= require_tree ../templates/.
#= require_self

$ ->
  $document = $(document)

  # Handle ajax errors
  $document.ajaxError (e, xhr, status, error) ->
    return unless xhr.status == 422
    bootbox.alert
      message: xhr.responseJSON.join('<br>'),
      title: 'Something went wrong'

  # Read data-url if present
  $.rails.href = (element) -> element.data('url') || element.attr('href')

  # Handle tooltips
  bindTooltips = -> $('[data-toggle=tooltip]').tooltip()
  bindTooltips()
  $document.ajaxSuccess bindTooltips

  # Handle WGText
  bindWGText = -> (new Wallgig.Managers.WGText($('[data-provide=wgtext]'))).execute()
  bindWGText()
  $(document).on 'wg:bind-wgtext', bindWGText
  # $(document).ajaxSuccess bindWGText

  # Handle subscribe button
  bindSubscribeButtons = -> (new Wallgig.Managers.SubscribeButton($('[data-provide=subscribe-button]'))).execute()
  bindSubscribeButtons()

  # Handle user online status tooltip
  bindUserOnlineTooltip = ->
    $('.icon-user-online').tooltip
      title: 'Online'
  bindUserOnlineTooltip()
  $(document).ajaxSuccess bindUserOnlineTooltip

  # Country flag tooltip
  bindUserCountryFlagTooltip = ->
    $('.flag').each ->
      $this = $(this)
      $this.tooltip
        title: $this.data('country')
  bindUserCountryFlagTooltip()
  $(document).ajaxSuccess bindUserCountryFlagTooltip
