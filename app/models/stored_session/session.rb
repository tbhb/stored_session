require "active_support/core_ext/integer/time"

class StoredSession::Session < StoredSession::Record
  include StoredSession::Model

  self.table_name = StoredSession.config.sessions_table_name

  ActiveSupport.run_load_hooks(:stored_session_session, self)
end
