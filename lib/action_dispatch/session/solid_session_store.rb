require "solid_session/store"

module ActionDispatch
  module Session
    SolidSessionStore = SolidSession::Store
  end
end
