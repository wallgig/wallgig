class Wallgig.Managers.WGText
  AVATAR_SIZE: 20
  USERNAME_REGEX: /@([a-zA-Z0-9_]*[a-zA-Z][a-zA-Z0-9_]*)/g

  template_user: (user) ->
    "<a href='#{user.url}' class='link-user'>
      <img src='#{user.avatar_url}' width='#{@AVATAR_SIZE}'' height='#{@AVATAR_SIZE}'>
      #{user.username_tag}
      </a>"

  constructor: (@elements) ->
    @usernames = []

  prepareUsernames: ->
    @elements.each (index, element) =>
      $element = $(element)
      html = $element.html()
      html = html.replace @USERNAME_REGEX, (match, username) =>
        username = username.toLowerCase()
        @usernames.push(username)
        '<span data-username="' + username + '">' + match + '</span>'

      $element.html(html)

    @usernames = $.unique(@usernames)

  fetchUsernames: ->
    params =
      includes:    'basic,username_tag,avatar_url'
      avatar_size: @AVATAR_SIZE
      usernames:   @usernames.join(',')

    $.get '/api/v1/users', params, (users) =>
      for user in users
        @elements.find('[data-username=' + user.username + ']')
                 .replaceWith(@template_user(user))

  execute: ->
    @prepareUsernames()
    @fetchUsernames()
