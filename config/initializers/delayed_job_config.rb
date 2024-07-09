Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3
Delayed::Worker.sleep_delay = 120
Delayed::Worker.read_ahead = 10
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))

[[ExceptionNotifier::Notifier, :background_exception_notification]].each do |object, method_name|
  raise NoMethodError, "undefined method `#{method_name}' for #{object.inspect}" unless object.respond_to?(method_name, true)
end

module DelayedJobWithNotification
  def handle_failed_job(job, error)
    super
    if Rails.env.production?
      begin
        ExceptionNotifier.notify_exception(error)
      rescue Exception => e
        Rails.logger.error "ExceptionNotifier failed: #{e.class.name}: #{e.message}"
        e.backtrace.each { |f| Rails.logger.error "  #{f}" }
        Rails.logger.flush
      end
    end
  end
end

Delayed::Worker.prepend DelayedJobWithNotification
