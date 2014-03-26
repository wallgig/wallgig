ActiveAdmin.register User do
  config.batch_actions = false

  actions :all, except: [:destroy]

  permit_params :email, :username, :trusted,
                :moderator, :admin, :developer,
                :locked_at, :password

  scope :all, default: true
  scope :trusted
  scope :confirmed
  scope('Not Confirmed') { |u| u.where(confirmed_at: nil) }
  scope('Locked') { |u| u.where.not(locked_at: nil) }
  scope :staff

  filter :email
  filter :username

  index do
    selectable_column
    column('Avatar') do |user|
      link_to admin_user_path(user) do
        image_tag user_avatar_url(user, 50), width: 25, height: 25
      end
    end
    column('Username', sortable: :username) { |user| link_to username_tag(user), admin_user_path(user), class: 'username-link' }
    column('Role') { |user| role_name_for(user) }
    column('Title') { |user| user.profile.title }
    column 'Cover' do |user|
      link_to user.profile.cover_wallpaper.image.url, target: '_blank' do
        if user.profile.cover_wallpaper.thumbnail_image.present?
          image_tag user.profile.cover_wallpaper.thumbnail_image.url, width: 100, height: 75
        else
          'Processing'
        end
      end if user.profile.cover_wallpaper.present?
    end
    column('Country', sortable: 'user_profiles.country_code') { |user| user.profile.country_code }
    column :wallpapers_count
    column :sign_in_count
    column :current_sign_in_at
    column('Confirmed', sortable: :confirmed_at) { |user| status_tag user.confirmed? ? 'Yes' : 'No' }
    column :created_at
    column :updated_at
    actions do |user|
      link_to 'Pretend', pretend_admin_user_path(user), data: { method: :post, confirm: 'Are you sure?' }
      link_to 'View settings', admin_user_settings_path(q: { user_id_eq: user.id })
    end
  end

  show do
    panel 'User Details' do
      attributes_table_for user do
        row('Username') { username_tag(user) }
        row('Title') { user.profile.title }
        row('Country') { user.profile.country_name }
        row 'Avatar' do
          image_tag(user_avatar_url(user, 50), width: 50, height: 50)
        end
        row :email
      end
    end
    panel 'Security' do
      attributes_table_for user do
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
        row :confirmed_at
        row :confirmation_sent_at
        row :unconfirmed_email
        row :failed_attempts
        row :locked_at
        row :created_at
        row :updated_at
      end
    end
    active_admin_comments
  end

  sidebar 'Roles', only: :show do
    attributes_table_for user do
      row :moderator
      row :admin
      row :developer
    end
  end

  action_item only: :show do
    if authorized? :read, user.settings
      link_to 'View Settings', admin_user_setting_path(user.settings)
    end
  end
  action_item only: :show do
    link_to "Collections (#{user.collections_count})", admin_collections_path(q: { user_username_eq: user.username })
  end
  action_item only: :show do
    link_to "Favourites (#{user.favourites_count})", admin_favourites_path(q: { user_username_eq: user.username })
  end
  action_item only: :show do
    link_to "Wallpapers (#{user.wallpapers_count})", admin_wallpapers_path(q: { user_username_eq: user.username }, scope: 'all')
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :username
      f.input :trusted
      f.input :moderator
      f.input :admin
      f.input :developer
      f.input :password
    end
    f.actions
  end

  member_action :pretend, method: :post do
    @user = User.find_by!(username: params[:id])
    sign_in @user
    redirect_to root_url, notice: "You are now pretending to be #{@user.username}."
  end

  controller do
    def find_resource
      scoped_collection.find_by!(username: params[:id])
    end
  end
end
