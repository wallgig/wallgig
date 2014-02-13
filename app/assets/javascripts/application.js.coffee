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
#= require bootstrap
#= require panzoom
#= require jquery.inview
#= require spin
#= require ladda
#= require selectize
#= require jquery.bootstrap-growl
#= require jquery.cookie
#= require bootbox

#= require markdown
#= require to-markdown
#= require bootstrap-markdown

#= require typeahead.bundle

#= require_tree .
#= require_tree ../templates/.
#= require_self

$ ->
  $(document).on 'ajax:error', (e, xhr, status, error) ->
    return unless xhr.status == 422
    bootbox.alert
      message: xhr.responseJSON.join('<br>'),
      title: 'Something went wrong'

  $.rails.href = (element) ->
    # Read data-url if present
    element.data('url') || element.attr('href')

  if ($tooltips = $('[data-toggle=tooltip]')).length > 0
    $tooltips.tooltip();


  if ($wgtextEnabled = $('[data-provide=wgtext]')).length > 0
    (new Wallgig.Managers.WGText($wgtextEnabled)).execute()
