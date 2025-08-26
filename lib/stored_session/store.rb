require_relative "store/instrumentation"
require_relative "store/logging"

class StoredSession::Store < ActionDispatch::Session::AbstractSecureStore
  include StoredSession::Store::Logging
  include StoredSession::Store::Instrumentation

  attr_reader :session_class

  def initialize(app, options = {})
    super(app, options)
    @session_class = options.fetch(:session_class) { StoredSession.config.session_class }
  end

  def find_session(env, sid)
    instrument(:read, sid) do |payload|
      if sid && (data = session_class.read(sid.private_id))
        [ sid, data || {} ]
      else
        [ generate_sid, {} ]
      end
    end
  end

  def write_session(req, sid, session, options)
    instrument(:write, sid) do |payload|
      return false unless session_class.write(sid.private_id, session)

      sid
    end
  end

  def delete_session(req, sid, options)
    instrument(:delete, sid) do |payload|
      session_class.by_sid(sid.private_id).delete_all
      generate_sid
    end
  end

  ActiveSupport.run_load_hooks(:stored_session_store, self)
end
