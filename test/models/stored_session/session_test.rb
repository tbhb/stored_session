require "test_helper"

class StoredSession::SessionTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "read with a valid session id" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    session = StoredSession::Session.create!(sid: sid.private_id, data: { "foo" => "bar" })

    assert_equal({ "foo" => "bar" }, StoredSession::Session.read(sid.private_id))
  end

  test "read with an invalid session id" do
    assert_nil StoredSession::Session.read("INVALID")
  end

  test "write with an existing session id" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    session = StoredSession::Session.create!(sid: sid.private_id, data: { "foo" => "bar" })

    assert StoredSession::Session.write(sid.private_id, { "foo" => "baz" })

    assert_equal({ "foo" => "baz" }, StoredSession::Session.read(sid.private_id))
  end

  test "write with a new session id" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))

    assert StoredSession::Session.write(sid.private_id, { "foo" => "bar" })

    assert_equal({ "foo" => "bar" }, StoredSession::Session.read(sid.private_id))
  end

  test "write with invalid data" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))

    assert_not StoredSession::Session.write(sid.private_id, "not a hash")
  end

  test "expire with sessions older than the max created age" do
    old_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    old_session = StoredSession::Session.create!(sid: old_sid.private_id, data: { "foo" => "bar" }, created_at: 2.days.ago)

    new_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    new_session = StoredSession::Session.create!(sid: new_sid.private_id, data: { "foo" => "bar" }, created_at: 12.hours.ago)

    StoredSession::Session.expire(max_created_age: 1.day)

    assert_nil StoredSession::Session.find_by(sid: old_sid.private_id)
    assert StoredSession::Session.find_by(sid: new_sid.private_id)
  end

  test "expire with sessions older than the max updated age" do
    old_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    old_session = StoredSession::Session.create!(sid: old_sid.private_id, data: { "foo" => "bar" }, updated_at: 2.days.ago)

    new_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    new_session = StoredSession::Session.create!(sid: new_sid.private_id, data: { "foo" => "bar" }, updated_at: 12.hours.ago)

    StoredSession::Session.expire(max_updated_age: 1.day)

    assert_nil StoredSession::Session.find_by(sid: old_sid.private_id)
    assert StoredSession::Session.find_by(sid: new_sid.private_id)
  end

  test "expire_later" do
    assert_enqueued_with(job: StoredSession::ExpireSessionsJob) do
      StoredSession::Session.expire_later
    end
  end

  test "uncached_count" do
    3.times do
      StoredSession::Session.create!(
        sid: Rack::Session::SessionId.new(SecureRandom.hex(16)).private_id,
        data: { "foo" => "bar" })
    end

    assert_equal 3, StoredSession::Session.uncached_count
  end
end
