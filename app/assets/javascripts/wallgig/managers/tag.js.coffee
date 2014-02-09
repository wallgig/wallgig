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

  onKeydown: (e) ->
    if e.keyCode == 13
      e.preventDefault()
      # TODO do something here
      @clearInputVal()

  onTypeaheadSelected: (e, tag, name) ->
    e.preventDefault()
    @clearInputVal()
    @addTag(tag)

  getInputVal: -> @input.typeahead('val')
  clearInputVal: -> @input.typeahead('val', '')

  tagIdExist: (tagId) -> parseInt(tagId) in @tagIds
  removeTagId: (tagId) ->
    tagId = parseInt(tagId)
    while (index = @tagIds.indexOf(tagId)) != -1
      @tagIds.splice(index, 1)
  addTagId: (tagId) -> @tagIds.push(parseInt(tagId))

  onClickRemoveTag: (e) ->
    e.preventDefault()
    $container = $(e.currentTarget).closest('[data-tag-id]')
    tagId = $container.data('tag-id')
    console.log @tagIds
    @removeTagId(tagId)
    console.log @tagIds
    $container.remove()

  addTag: (tag) ->
    return if @tagIdExist(tag.id)

    @list.append(JST['tag_manager_tag_list_item'](tag))
    console.log @tagIds
    @addTagId(tag.id)
    console.log @tagIds
