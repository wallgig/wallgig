module HasPurity
  extend ActiveSupport::Concern
  included do
    extend Enumerize
    enumerize :purity, in: [:sfw, :sketchy, :nsfw], default: :sfw, scope: true, predicates: true

    scope :sfw, -> { where(purity: 'sfw') }
    scope :sketchy, -> { where(purity: 'sketchy') }
    scope :nsfw, -> { where(purity: 'nsfw') }
    scope :with_purities, -> (*purities) { where(purity: purities) }

    validates :purity, presence: true
  end
end
