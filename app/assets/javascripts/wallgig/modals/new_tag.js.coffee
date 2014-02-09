class Wallgig.Modals.NewTag
  constructor: (@name, @successCallback) ->

  show: ->
    bootbox.dialog
      title: 'New tag'
      message: JST['modal_new_tag'](@dataForTemplate())
      onEscape: -> true
      buttons:
        danger:
          label: 'Cancel'
          className: 'btn-default'
        success:
          label: 'Create Tag'
          className: 'btn-success'
          callback: (e) ->
            # TODO
            false

  dataForTemplate: ->
    name: @name
