# == Schema Information
#
# Table name: categories
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  slug               :string(255)
#  wikipedia_title    :string(255)
#  raw_content        :text
#  cooked_content     :text
#  ancestry           :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  sfw_tags_count     :integer          default(0)
#  sketchy_tags_count :integer          default(0)
#  nsfw_tags_count    :integer          default(0)
#

require 'wikipedia_client'

class Category < ActiveRecord::Base
  has_many :tags, dependent: :nullify

  has_ancestry orphan_strategy: :adopt

  extend FriendlyId
  friendly_id :name, use: :slugged

  include PurityCounters
  has_purity_counters :tags

  validates :name, presence: true

  scope :alphabetically, -> { order 'LOWER(name) ASC' }

  before_save :fetch_wikipedia_content, if: proc { |c| c.raw_content.blank? && c.wikipedia_title.present? }

  def self.ensure_consistency!
    connection.execute('
      UPDATE categories c
      SET
        sfw_tags_count = (
          SELECT     COUNT(*)
          FROM       tags t
          WHERE      t.category_id = c.id
            AND      t.purity = \'sfw\'
        ),
        sketchy_tags_count = (
          SELECT     COUNT(*)
          FROM       tags t
          WHERE      t.category_id = c.id
            AND      t.purity = \'sketchy\'
        ),
        nsfw_tags_count = (
          SELECT     COUNT(*)
          FROM       tags t
          WHERE      t.category_id = c.id
            AND      t.purity = \'nsfw\'
        )
    ')
  end

  def fetch_wikipedia_content
    self.cooked_content = WikipediaClient.new(wikipedia_title).extract if wikipedia_title.present?
  end

  # Taken from https://github.com/stefankroes/ancestry/wiki/Creating-a-selectbox-for-a-form-using-ancestry
  def self.arrange_as_array(options = {}, hash = nil)                                                                                                                                                            
    hash ||= arrange(options)

    arr = []
    hash.each do |node, children|
      arr << node
      arr += arrange_as_array(options, children) unless children.nil?
    end
    arr
  end

  def name_for_selects
    "#{'-' * depth} #{name}"
  end

  def possible_parents
    parents = Category.arrange_as_array(order: :name)
    return new_record? ? parents : parents - subtree
  end
end
