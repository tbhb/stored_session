require "test_helper"

class StoredSession::Store::InstrumentationTest < ActiveSupport::TestCase
  test "find_session instrumentation" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    events = with_instrumentation(:read) do
      store = StoredSession::Store.new(nil)
      StoredSession::Session.create!(sid: sid.private_id, data: { "key" => "value" })

      store.find_session(nil, sid)
    end

    assert_equal %w[ session_read.stored_session ], events.map(&:name)
    assert_equal sid.private_id, events.first.payload[:sid]
  end

  test "write_session instrumentation" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    events = with_instrumentation(:write) do
      store = StoredSession::Store.new(nil)
      store.write_session(nil, sid, { "key" => "value" }, {})

      StoredSession::Session.find_by(sid: sid.private_id)
    end

    assert_equal %w[ session_write.stored_session ], events.map(&:name)
    assert_equal sid.private_id, events.first.payload[:sid]
  end

  test "delete_session instrumentation" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    events = with_instrumentation(:delete) do
      store = StoredSession::Store.new(nil)
      StoredSession::Session.create!(sid: sid.private_id, data: { "key" => "value" })

      store.delete_session(nil, sid, {})

      StoredSession::Session.find_by(sid: sid.private_id)
    end

    assert_equal %w[ session_delete.stored_session ], events.map(&:name)
    assert_equal sid.private_id, events.first.payload[:sid]
  end

  private
    def with_instrumentation(method)
      event_name = "session_#{method}.stored_session"

      [].tap do |events|
        ActiveSupport::Notifications.subscribe(event_name) { |event| events << event }
        yield
      end
    ensure
      ActiveSupport::Notifications.unsubscribe event_name
    end
end
