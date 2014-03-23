$ ->
  if $('body.collections.index').length == 1
    loadNextPage = (event, visible) ->
      return unless visible
      $this = $(this)
      url = $this.attr 'href'
      $this.unbind 'inview'
      $this.replaceWith('<hr /><div class="loading" />')
      $.get url, (html) ->
        $mainContainer = $('.list-collection:first').parent()
        $mainContainer.find('.loading').remove()
        $mainContainer.append(html)
        $('[rel=next]').bind('inview', loadNextPage)

      ga('send', 'pageview', url) if ga

    if Wallgig.CurrentUser.Settings.infinite_scroll
      $('[rel=next]').bind('inview', loadNextPage)
