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
        url: '/api/v1/tags?q=%QUERY'
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
    $.get '/api/v1/tags/find_or_initialize', name: name, (data) =>
      if data.tag
        @addTag(data.tag)
      else
        modal = new Wallgig.Modals.NewTag(name, data.available_categories, $.proxy(@addTag, @))
        modal.show()

        # bootbox.alert('This tag does not exist. <a href="/tags/new">Please go here and add!</a>')

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
