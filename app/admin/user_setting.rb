ActiveAdmin.register UserSetting do
  permit_params :screen_resolution_id,
                :sfw, :sketchy, :nsfw,
                :per_page,
                :infinite_scroll,
                :screen_width,
                :screen_height,
                :invisible,
                :resolution_exactness,
                :new_window,
                aspect_ratios: []

  actions :all, except: [:destroy]

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

  form do |f|
    f.semantic_errors

    f.inputs 'Browsing settings' do
      f.input :sfw
      f.input :sketchy
      f.input :nsfw
      f.input :per_page, as: :select, include_blank: false
      f.input :infinite_scroll
      f.input :new_window
    end

    f.inputs 'Privacy settings' do
      f.input :invisible
    end

    f.inputs 'Search settings' do
      f.input :resolution_exactness
      f.input :screen_resolution
      f.input :aspect_ratios, as: :check_boxes
    end

    f.actions
  end

  controller do
    def scoped_collection
      UserSetting.includes(:user)
    end
  end
end
