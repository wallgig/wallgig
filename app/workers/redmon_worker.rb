class RedmonWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { secondly Redmon.config.poll_interval.seconds }

  def perform
    worker = Redmon::Worker.new
    worker.record_stats
    worker.cleanup_old_stats
  end
end
