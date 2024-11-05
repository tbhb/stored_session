class StoredSession::ExpireSessionsJob < StoredSession.config.base_job_class
  queue_as StoredSession.config.expire_sessions_job_queue_as

  def perform(max_created_age: nil, max_updated_age: nil)
    StoredSession::Session.expire(max_created_age:, max_updated_age:)
  end

  ActiveSupport.run_load_hooks(:stored_session_expire_sessions_job, self)
end
