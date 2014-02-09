module Approvable
  extend ActiveSupport::Concern
  included do
    belongs_to :approved_by, class_name: 'User'

    scope :approved,         -> { where.not(approved_at: nil) }
    scope :pending_approval, -> { where(approved_at:nil) }
  end

  def approved?
    approved_at.present?
  end

  def approve_by!(user)
    self.approved_by = user
    self.approved_at = Time.now
    save!
  end

  def unapprove!
    self.approved_by = nil
    self.approved_at = nil
    save!
  end
end
