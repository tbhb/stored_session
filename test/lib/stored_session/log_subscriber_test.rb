require "test_helper"
require "active_support/log_subscriber/test_helper"

class StoredSession::LogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    @subscriber = StoredSession::LogSubscriber.new
    super
    StoredSession::LogSubscriber.attach_to :stored_session, @subscriber
  end

  def teardown
    super
    ActiveSupport::LogSubscriber.log_subscribers.clear
  end

  def set_logger(logger)
    # Isolate the logger used by the test subscriber so that we don't change StoredSession.logger globally
    @subscriber.logger = logger
  end

  test "session_read" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    store = StoredSession::Store.new(nil)
    StoredSession::Session.create!(sid: sid.private_id, data: { "key" => "value" })

    store.find_session(nil, sid)
    wait

    assert_equal 1, @logger.logged(:debug).size
    assert_match /Session Read in \d+\.\d+ms \(sid: "#{sid.private_id}"\)/, @logger.logged(:debug).last
  end

  test "session_write" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    store = StoredSession::Store.new(nil)
    store.write_session(nil, sid, { "key" => "value" }, {})
    wait

    assert_equal 1, @logger.logged(:debug).size
    assert_match /Session Write in \d+\.\d+ms \(sid: "#{sid.private_id}"\)/, @logger.logged(:debug).last
  end

  test "session_delete" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    store = StoredSession::Store.new(nil)
    StoredSession::Session.create!(sid: sid.private_id, data: { "key" => "value" })

    store.delete_session(nil, sid, {})
    wait

    assert_equal 1, @logger.logged(:debug).size
    assert_match /Session Delete in \d+\.\d+ms \(sid: "#{sid.private_id}"\)/, @logger.logged(:debug).last
  end
end
