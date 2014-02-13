ActiveAdmin.register User do
  config.batch_actions = false

  actions :all, except: [:destroy]

  permit_params :email, :username, :trusted, :moderator, :admin, :developer, :locked_at, :password

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
