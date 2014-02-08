module HasPurity
  extend ActiveSupport::Concern
  included do
    extend Enumerize
    enumerize :purity, in: [:sfw, :sketchy, :nsfw], default: :sfw, scope: true, predicates: true

    scope :with_purities, -> (*purities) { where(purity: purities) }
  end
end
