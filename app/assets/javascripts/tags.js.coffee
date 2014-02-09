$ ->
  if ($tagSearch = $('[data-provide=tag-search]')).length > 0
    new Wallgig.Managers.Tag($tagSearch, $('[data-provide=tag-list]'))