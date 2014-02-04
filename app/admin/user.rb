ActiveAdmin.register User do
  config.batch_actions = false

  actions :all, except: [:destroy]

  permit_params :email, :username, :password, :moderator, :admin, :developer, :locked_at

  scope :all, default: true
  scope :confirmed
  scope('Not Confirmed') { |u| u.where(confirmed_at: nil) }
  scope('Locked') { |u| u.where.not(locked_at: nil) }
  scope :staff

  filter :email
  filter :username

  index do
    selectable_column
    column('Avatar') do |u|
      link_to admin_user_path(u) do
        image_tag user_avatar_url(u, 50), width: 25, height: 25
      end
    end
    column('Username', sortable: :username) { |u| link_to username_tag(u), admin_user_path(u), class: 'username-link' }
    column('Role') { |u| role_name_for(u) }
    column :wallpapers_count
    column :sign_in_count
    column :current_sign_in_at
    column('Confirmed', sortable: :confirmed_at) { |u| status_tag u.confirmed? ? 'Yes' : 'No' }
    column :created_at
    column :updated_at
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :username
      f.input :password
      f.input :moderator
      f.input :admin
      f.input :developer
    end
    f.actions
  end

  controller do
    def resource
      User.find_by!(username: params[:id])
    end

    def scoped_collection
      User.includes(:profile)
    end
  end
end
