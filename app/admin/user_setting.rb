ActiveAdmin.register UserSetting do
  menu parent: 'Users'

  filter :invisible
  filter :screen_resolution
  filter :sfw
  filter :sketchy
  filter :nsfw
  filter :per_page
  filter :infinite_scroll
  filter :screen_width
  filter :screen_height

  index do
    selectable_column
    column :user
    column('SFW', :sfw)
    column('Sketchy', :sketchy)
    column('NSFW', :nsfw)
    column :per_page
    column(:infinite_scroll, sortable: :infinite_scroll) { |user_setting| status_tag user_setting.infinite_scroll? ? 'Yes' : 'No' }
    column :screen_width
    column :screen_height
    column(:invisible, sortable: :invisible) { |user_setting| status_tag user_setting.invisible? ? 'Yes' : 'No' }
    default_actions
  end

  controller do
    def scoped_collection
      UserSetting.includes(:user)
    end
  end
end
