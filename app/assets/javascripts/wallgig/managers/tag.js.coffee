class Wallgig.Managers.Tag
  constructor: (@input, @list) ->
    @tagIds = @list.find('[data-tag-id]').map(-> $(@).data('tag-id')).get()
    console.log @tagIds

    @initTypeahead()

    @input.on 'keydown', $.proxy(@onKeydown, @)
    @input.on 'typeahead:selected', $.proxy(@onTypeaheadSelected, @)
    @list.on 'click', '[data-action=remove]', $.proxy(@onClickRemoveTag, @)

  initTypeahead: ->
    engine = new Bloodhound
      datumTokenizer: (d) -> Bloodhound.tokenizers.whitespace(d.name)
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: '/tags.json?name_cont=%QUERY'
        ajax:
          beforeSend: (xhr, settings) =>
            settings.url = settings.url + '&' + $.param(exclude_ids: @tagIds)
            true
        filter: (parsedResponse) =>
          parsedResponse['tags'].filter (tag) =>
            !@tagIdExist(tag.id)

    dataset =
      name: 'tags'
      displayKey: 'name'
      source: engine.ttAdapter()
      templates:
        suggestion: JST['tag_typeahead_suggestion']

    engine.initialize()

    @input.typeahead(null, dataset)

  getInputVal:   -> @input.val()
  clearInputVal: -> @input.typeahead('val', '')

  tagIdExist: (tagId) -> parseInt(tagId) in @tagIds
  removeTagId: (tagId) ->
    tagId = parseInt(tagId)
    while (index = @tagIds.indexOf(tagId)) != -1
      @tagIds.splice(index, 1)
  addTagId: (tagId) -> @tagIds.push(parseInt(tagId))

  addTag: (tag) ->
    return if @tagIdExist(tag.id)

    @list.append(JST['tag_manager_tag_list_item'](tag))
    @addTagId(tag.id)

  addOrCreateTag: (name) ->
    params =
      name_matches: name
    $.get '/tags.json', params, (data) =>
      if data.tags.length > 0
        @addTag(data.tags[0])
      else
        modal = new Wallgig.Modals.NewTag(name, $.proxy(@addTag, @))
        modal.show()

  onKeydown: (e) ->
    if e.which == 13
      e.preventDefault()

      value = @getInputVal()

      if value.length > 0
        @addOrCreateTag(value)
        @clearInputVal()
    null

  onTypeaheadSelected: (e, tag, name) ->
    e.preventDefault()
    @addOrCreateTag(tag.name)
    @clearInputVal()
    null

  onClickRemoveTag: (e) ->
    e.preventDefault()
    $container = $(e.currentTarget).closest('[data-tag-id]')
    tagId = $container.data('tag-id')
    @removeTagId(tagId)
    $container.remove()
    null
