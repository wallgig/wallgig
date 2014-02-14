class EnsureDatabaseConsistency
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily 1 }

  def perform
    Category.ensure_consistency!
    Collection.ensure_consistency!
    Tag.ensure_consistency!
    User.ensure_consistency!
  end
end
