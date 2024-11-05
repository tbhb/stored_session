module StoredSession
  class Store < ActionDispatch::Session::AbstractSecureStore
    module Logging
      extend ActiveSupport::Concern

      included do
        delegate :logger, to: :StoredSession
      end

      def initialize(app, options = {})
        super
        @silence = options.fetch(:silence) { true }
      end

      private
        def silence(&blk)
          @silence ? ActiveRecord::Base.logger.silence(&blk) : yield
        end

      ActiveSupport.run_load_hooks(:stored_session_store_logging, self)
    end
  end
end
