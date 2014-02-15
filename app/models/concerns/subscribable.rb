module Subscribable
  extend ActiveSupport::Concern
  included do
    has_many :subscribes, as: :subscribable, dependent: :destroy, class_name: 'Subscription'
    has_many :subscribers, through: :subscribes, class_name: 'User', source: :user
  end
end
