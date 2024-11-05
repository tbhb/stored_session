class StoredSession::Record < StoredSession.config.base_record_class
  self.abstract_class = true

  connects_to(**StoredSession.config.connects_to) if StoredSession.config.connects_to

  ActiveSupport.run_load_hooks :stored_session_record, self
end
