# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
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

#= require_tree .
#= require_tree ../templates/.
#= require_self

$ ->
  # Handle ajax errors
  $(document).ajaxError (e, xhr, status, error) ->
    return unless xhr.status == 422
    bootbox.alert
      message: xhr.responseJSON.join('<br>'),
      title: 'Something went wrong'

  # Read data-url if present
  $.rails.href = (element) ->
    element.data('url') || element.attr('href')

  # Handle tooltips
  if ($tooltips = $('[data-toggle=tooltip]')).length > 0
    $tooltips.tooltip();

  # Handle WGText
  if ($wgtextEnabled = $('[data-provide=wgtext]')).length > 0
    (new Wallgig.Managers.WGText($wgtextEnabled)).execute()

  # Handle subscribe button
  if ($subscribeButtons = $('[data-provide=subscribe-button]')).length > 0
    (new Wallgig.Managers.SubscribeButton($subscribeButtons)).execute()

  # Handle time ago
  if ($timeAgo = $('[data-provide=time-ago]')).length > 0
    $timeAgo.timeago()
