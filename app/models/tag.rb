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

  has_many :wallpapers_tags, dependent: :destroy
  has_many :wallpapers, through: :wallpapers_tags

  delegate :name, to: :category, prefix: true, allow_nil: true

  include Approvable
  include HasPurity

  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  scope :name_like, -> (query) { where('name ILIKE ?', "#{query}%") }
  scope :alphabetically, -> { order 'LOWER(name) ASC' }

  before_validation :set_slug, if: :name_changed?

  def self.find_by_name(name)
    where(['LOWER(name) = LOWER(?)', name]).first
  end

  def set_slug
    self.slug = name.parameterize
  end
end
