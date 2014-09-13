class BasicUserSettingsSerializer < ActiveModel::Serializer
  attributes :sfw, :sketchy, :nsfw, :per_page, :infinite_scroll, :invisible, :new_window
end
