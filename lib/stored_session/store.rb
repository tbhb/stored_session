require_relative "store/instrumentation"

class StoredSession::Store < ActionDispatch::Session::AbstractSecureStore
  include ActiveSupport::Configurable
  include StoredSession::Store::Instrumentation

  delegate :logger, to: :StoredSession

  attr_reader :silence
  alias :silence? :silence

  attr_reader :session_class

  def initialize(app, options = {})
    super

    @session_class = options.fetch(:session_class) { StoredSession.config.session_class }
    @silence = true unless options.key?(:silence)
  end

  def find_session(env, sid)
    silence do
      instrument(:read, sid) do |payload|
        if sid && (data = session_class.read(sid.private_id))
          [ sid, data || {} ]
        else
          [ generate_sid, {} ]
        end
      end
    end
  end

  def write_session(req, sid, session, options)
    silence do
      instrument(:write, sid) do |payload|
        return false unless session_class.write(sid.private_id, session)

        sid
      end
    end
  end

  def delete_session(req, sid, options)
    silence do
      instrument(:delete, sid) do |payload|
        session_class.by_sid(sid.private_id).delete_all
        generate_sid
      end
    end
  end

  def silence(&)
    @silence ? logger.silence(&) : yield
  end

  ActiveSupport.run_load_hooks(:stored_session_store, self)
end
