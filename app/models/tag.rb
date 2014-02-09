# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  slug           :string(255)
#  category_id    :integer
#  purity         :string(255)
#  coined_by_id   :integer
#  approved_by_id :integer
#  approved_at    :datetime
#

class Tag < ActiveRecord::Base
  belongs_to :category
  belongs_to :coined_by, class_name: 'User'

  include Approvable
  include HasPurity

  extend FriendlyId
  friendly_id :name, use: :slugged

  delegate :name, to: :category, prefix: true, allow_nil: true

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :name_like, -> (query) { where('name ILIKE ?', "#{query}%") }
  scope :alphabetically, -> { order 'LOWER(name) ASC' }
end
