module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :notifiable, dependent: :destroy

    after_create :notify
  end

  def notify
    # method stub
  end
end
