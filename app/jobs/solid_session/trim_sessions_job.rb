class SolidSession::TrimSessionsJob < SolidSession.config.base_job_class
  queue_as SolidSession.config.trim_sessions_job_queue_as

  def perform(max_created_age: nil, max_updated_age: nil)
    SolidSession::Session.trim!(max_created_age:, max_updated_age:)
  end

  ActiveSupport.run_load_hooks(:solid_session_trim_sessions_job, self)
end
