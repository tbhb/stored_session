class SolidSession::Store < ActionDispatch::Session::AbstractSecureStore
  include ActiveSupport::Configurable

  config_accessor :session_class

  delegate :logger, to: :SolidSession

  def initialize(app, options = {})
    super

    @silence = true unless options.key?(:silence)
  end

  def find_session(req, sid)
    silence do
      if sid && (data = session_class.read(sid.private_id))
        [ sid, data || {} ]
      else
        [ generate_sid, {} ]
      end
    end
  end

  def write_session(req, sid, data, options)
    silence do
      return false unless session_class.write(sid.private_id, data)

      sid
    end
  end

  def delete_session(req, sid, options)
    silence do
      session_class.by_sid(sid.private_id).delete_all
      generate_sid
    end
  end

  def silence(&)
    @silence ? logger.silence(&) : yield
  end

  ActiveSupport.run_load_hooks(:solid_session_store, self)
end
