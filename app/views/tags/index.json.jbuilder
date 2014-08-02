json.partial! 'shared/api/page_meta', collection: @tags

json.tags @tags, partial: 'tag', as: :tag
