# == Schema Information
#
# Table name: tags
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  slug             :string(255)
#  category_id      :integer
#  purity           :string(255)
#  coined_by_id     :integer
#  approved_by_id   :integer
#  approved_at      :datetime
#  wallpapers_count :integer          default(0)
#

class Tag < ActiveRecord::Base
  belongs_to :category, counter_cache: true
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

  scope :name_like,      -> (query) { where('name ILIKE ?', "#{query}%") }
  scope :alphabetically, -> { order 'LOWER(name) ASC' }
  scope :not_empty,      -> { where('wallpapers_count > 0') }
  scope :in_category,    -> (category) { where(category_id: category.subtree_ids) if category.present? }

  before_validation :set_slug, if: :name_changed?

  def self.ensure_consistency!
    connection.execute('
      UPDATE tags SET wallpapers_count = (
        SELECT COUNT(*) FROM wallpapers_tags WHERE wallpapers_tags.tag_id = tags.id
      )
    ')
  end

  def set_slug
    self.slug = name.parameterize
  end
end
