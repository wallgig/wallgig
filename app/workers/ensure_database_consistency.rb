class EnsureDatabaseConsistency
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily 1 }

  def perform
    Collection.ensure_consistency!
    User.ensure_consistency!
  end
end
