class Wallgig.Modals.NewTag
  constructor: (@name, @successCallback) ->
    @form = $(JST['modal_new_tag_form'](@dataForTemplate()))
    @rootCategories = @form.find('[data-provide=categories]')
    @tagCategoryIdInput = @form.find('#tag_category_id')

    @fetchCategories()

    @rootCategories.on 'change', '[data-provide=category-selection]', $.proxy(@onChangeCategory, @)

  dataForTemplate: ->
    name: @name

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

  fetchCategories: (parentId) ->
    params =
      parent_id: parentId
    $.get '/api/v1/categories', params, @populateCategories(parentId)

  populateCategories: (parentId) ->
    fn = (data) ->
      if parentId?
        $which = @rootCategories.find('[data-parent-category-id=' + parentId + '] [data-provide=category-children]')
      else
        $which = @rootCategories

      if data.categories.length > 0
        tplParams =
          parentId: parentId
          categories: data.categories

        $which.html(JST['modal_new_tag_category_selection'](tplParams))
      else
        $which.empty()

    $.proxy(fn, @)

  onChangeCategory: (e) ->
    e.preventDefault()

    $target    = $(e.currentTarget)
    $container = $target.closest('[data-parent-category-id]')

    selectedId = $target.val()

    if selectedId.length > 0
      $container.attr('data-parent-category-id', selectedId)
      @tagCategoryIdInput.val(selectedId)

      @fetchCategories(selectedId)
    else
      $parent = $container.parent().closest('[data-parent-category-id]')
      if $parent.length > 0
        $parent.find('> [data-provide=category-selection]').trigger('change')
      else
        $container.find('[data-provide=category-children]').empty()
        @tagCategoryIdInput.val('')

    null

  onClickCreateTag: (e) ->
    $.post '/api/v1/tags', @form.serialize(), @successCallback
