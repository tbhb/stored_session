class SolidSession::Record < SolidSession.config.base_record_class
  self.abstract_class = true

  connects_to(**SolidSession.config.connects_to) if SolidSession.config.connects_to

  ActiveSupport.run_load_hooks :solid_session_record, self
end
