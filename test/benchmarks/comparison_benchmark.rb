require "test_helper"
require "minitest/benchmark"
# require "action_dispatch/middleware/session/cookie_store"
# require "action_dispatch/middleware/session/cache_store"
require "action_dispatch/session/active_record_store"

class SessionStoreComparisonBenchmark < Minitest::Benchmark
  def self.bench_range
    bench_exp 1, 1000
  end

  def bench_compare_write_session_active_record_session_store
    5.times { StoredSession::Store.new(nil).find_session(nil, generate_sid) }

    assert_performance_linear do |n|
      n.times do
        request = ActionDispatch::Request.new({ "rack.session.options" => {} })
        store = ActionDispatch::Session::ActiveRecordStore.new(nil)
        sid = generate_sid
        store.send(:write_session, request, sid, { test: "data" * 1000 }, {})
        store.send(:find_session, request, sid)
      end
    end
  end

  def bench_compare_write_session_stored_session_store
    5.times { StoredSession::Store.new(nil).find_session(nil, generate_sid) }

    assert_performance_linear do |n|
      n.times do
        request = ActionDispatch::Request.new({ "rack.session.options" => {} })
        store = ActionDispatch::Session::StoredSessionStore.new(nil)
        sid = generate_sid
        store.send(:write_session, request, sid, { test: "data" * 1000 }, {})
        store.send(:find_session, request, sid)
      end
    end
  end

  private
    def generate_sid
      sid = SecureRandom.hex(16)
      sid.encode!(Encoding::UTF_8)
      Rack::Session::SessionId.new(sid)
    end
end
