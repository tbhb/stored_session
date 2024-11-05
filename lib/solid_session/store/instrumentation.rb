module SolidSession
  class Store < ActionDispatch::Session::AbstractSecureStore
    module Instrumentation
      extend ActiveSupport::Concern

      def instrument(operation, sid, **options, &blk)
        payload = { sid: sid&.private_id, **options }
        ActiveSupport::Notifications.instrument("session_#{operation}.solid_session", payload) do
          blk&.call(payload)
        end
      end

      ActiveSupport.run_load_hooks(:solid_session_store_instrumentation, self)
    end
  end
end
