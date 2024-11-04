class SolidSession::TrimSessionsJob < SolidSession.config.base_job_class
  queue_as SolidSession.config.trim_sessions_job_queue_as

  def perform(max_age = SolidSession.config.max_age)
    SolidSession::Session.trim!(max_age)
  end

  ActiveSupport.run_load_hooks(:solid_session_trim_sessions_job, self)
end
