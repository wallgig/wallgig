$ ->
  if $('body.users').length > 0
    $('[data-action=explain-add-profile-cover]').click (e) ->
      e.preventDefault()
      bootbox.alert
        title: 'Add profile cover'
        message: JST['modal_add_profile_cover_explanation']()


  if $('.icon-user-online').length > 0
    $('.icon-user-online').tooltip
      title: 'Online'
