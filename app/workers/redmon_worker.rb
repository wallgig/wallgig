class RedmonWorker
  include Sidekiq::Worker

  def perform
    worker = Redmon::Worker.new
    worker.record_stats
    worker.cleanup_old_stats
  ensure
    self.class.perform_in Redmon.config.poll_interval.seconds
  end
end
