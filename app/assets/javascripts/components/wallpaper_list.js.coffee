WallpaperListData = flight.component ->
  @onReceiveData = (res) ->
    @trigger 'wallpaperListDataServed', res
    console.log 'got', res

  @onRequestWallpaperListData = (ev, attr) ->
    $.get '/wallpapers.json', attr, $.proxy(@onReceiveData, @)

  @after 'initialize', ->
    @on 'requestWallpaperListData', @onRequestWallpaperListData


WallpaperListUi = flight.component ->
  @attributes
    page: 1
    perPage: 20
    listTemplate: JST['wallpapers/list']
    showHorizontalBar: false

  @renderItems = (ev, res) ->
    data = $.extend(res, showHorizontalBar: @attr.showHorizontalBar)
    @$node.append @attr.listTemplate(data)
    @attr.showHorizontalBar = true

  @buildRequestParams = ->
    page: @attr.page
    per_page: @attr.perPage

  @after 'initialize', ->
    @attr.page = @$node.data('page') || @attr.page
    @attr.perPage = @$node.data('per-page') || @attr.perPage
    console.log 'WallpaperList attr', @attr

    @on document, 'wallpaperListDataServed', @renderItems

    @trigger 'requestWallpaperListData', @buildRequestParams()


$ ->
  WallpaperListData.attachTo document
  WallpaperListUi.attachTo '[data-component=wallpaper-list]'
