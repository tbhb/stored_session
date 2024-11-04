class SolidSession::Session < SolidSession::Record
  self.table_name = SolidSession.config.sessions_table_name

  serialize :data, coder: ActiveSupport::MessagePack, type: Hash
  encrypts :data, message_serializer: ActiveRecord::Encryption::MessagePackMessageSerializer.new

  scope :by_sid, ->(sid) { where(sid: sid) }

  class << self
    def read(sid)
      without_query_cache do
        select(:data).find_by(sid: sid)&.data
      end
    end

    def write(sid, data)
      without_query_cache do
        upsert({ sid:, data: }, unique_by: upsert_unique_by, on_duplicate: :update, update_only: %i[sid data])
      end
    end

    private
      def upsert_unique_by
        connection.supports_insert_conflict_target? ? :sid : nil
      end

      def without_query_cache(&)
        uncached(dirties: false, &)
      end
  end

  ActiveSupport.run_load_hooks(:solid_session_session, self)
end
