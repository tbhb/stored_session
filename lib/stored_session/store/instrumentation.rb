module StoredSession
  class Store < ActionDispatch::Session::AbstractSecureStore
    module Instrumentation
      extend ActiveSupport::Concern

      def instrument(operation, sid, **options, &blk)
        payload = { sid: sid&.private_id, **options }
        ActiveSupport::Notifications.instrument("session_#{operation}.stored_session", payload) do
          blk&.call(payload)
        end
      end

      ActiveSupport.run_load_hooks(:stored_session_store_instrumentation, self)
    end
  end
end