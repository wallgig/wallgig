class Wallgig.Modals.NewTag
  constructor: (@name, @categories, @successCallback) ->
    @form = $(JST['modal_new_tag_form'](@dataForTemplate()))

  show: ->
    bootbox.dialog
      title: 'New tag'
      message: @form
      onEscape: -> true
      buttons:
        danger:
          label: 'Cancel'
          className: 'btn-default'
        success:
          label: 'Create Tag'
          className: 'btn-success'
          callback: $.proxy(@onClickCreateTag, @)

  dataForTemplate: ->
    name: @name
    categories: @categories

  onClickCreateTag: (e) ->
    $.post '/api/v1/tags', @form.serialize(), @successCallback
    # false
