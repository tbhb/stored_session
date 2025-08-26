require "test_helper"
require "minitest/benchmark"
# require "action_dispatch/middleware/session/cookie_store"
# require "action_dispatch/middleware/session/cache_store"
require "action_dispatch/session/active_record_store"

class SessionStoreComparisonBenchmark < Minitest::Benchmark
  def self.bench_range
    bench_exp 1, 1000
  end

  def setup
    # StoredSession.config.encrypt = false

    @ar_store = ActionDispatch::Session::ActiveRecordStore.new(nil)
    @ss_store = ActionDispatch::Session::StoredSessionStore.new(nil)
  end

  def bench_active_record_store_write_and_read
    run_write_read_benchmark(@ar_store)
  end

  def bench_stored_session_store_write_and_read
    run_write_read_benchmark(@ss_store)
  end

  private

  def run_write_read_benchmark(store)
    # Warm up database connections and other components before running benchmarks.
    request = ActionDispatch::Request.new({ "rack.session.options" => {} })
    data = { test: "data" * 1000 }
    sid = generate_sid

    5.times do
      store.send(:write_session, request, sid, data, {})
      store.send(:find_session, request, generate_sid)
    end

    assert_performance_linear do |n|
      n.times do
        store.send(:write_session, request, sid, data, {})
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
