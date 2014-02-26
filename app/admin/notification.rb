ActiveAdmin.register Notification do
  permit_params :user_id, :message

  filter :user, collection: proc { User.alphabetically.pluck(:username) }
  filter :notifiable_type
  filter :read

  scope :all, default: true
  scope :read
  scope :unread

  form do |f|
    f.inputs do
      f.input :user, collection: User.select(:username, :id).alphabetically.all
      f.input :message
    end
    f.actions
  end
end
