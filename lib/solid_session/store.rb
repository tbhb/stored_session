class SolidSession::Store < ActionDispatch::Session::AbstractSecureStore
  def initialize(app, options = {})
    super
  end

  private

  def find_session(req, sid); end

  def write_session(req, sid, session, options); end

  def delete_session(req, sid, options); end

  ActiveSupport.run_load_hooks(:solid_session_store, self)
end
