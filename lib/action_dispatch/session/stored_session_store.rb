require "stored_session/store"

module ActionDispatch
  module Session
    StoredSessionStore = StoredSession::Store
  end
end
