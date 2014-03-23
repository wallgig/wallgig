# == Schema Information
#
# Table name: donation_goals
#
#  id        :integer          not null, primary key
#  name      :string(255)
#  starts_on :date             not null
#  ends_on   :date
#  cents     :integer          not null
#

class DonationGoal < ActiveRecord::Base
  has_many :donations

  validates :starts_on, presence: true
  validates :cents, presence: true

  default_scope -> { order(:starts_on) }

  after_initialize do
    self.starts_on ||= Time.now.to_date.advance(months: 1).beginning_of_month
    self.ends_on   ||= starts_on.end_of_month
    self.name      ||= starts_on.strftime('%B %Y')
    self.cents     ||= self.class.last.try(:cents)
  end

  def self.current
    current_date = Time.now.to_date
    result = self.where(["#{quoted_table_name}.\"starts_on\" >= ? AND #{quoted_table_name}.\"ends_on\" < ?", current_date, current_date]).first
    result ||= self.last
    result
  end

  def amount
    cents / 100.0
  end

  def percentage_complete
    if collected_cents >= cents
      100
    else
      (collected_cents.to_f / cents.to_f * 100).round
    end
  end

  def collected_cents
    donations.sum(:base_cents)
  end

  def collected
    collected_cents / 100.0
  end

  def reached?
    collected_cents >= cents
  end
end
