require "test_helper"

class StoredSession::ExpireSessionsJobTest < ActiveJob::TestCase
  test "expiring sessions older than the max created age" do
    old_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    old_session = StoredSession::Session.create!(sid: old_sid.private_id, data: { "foo" => "bar" }, created_at: 2.days.ago)

    new_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    new_session = StoredSession::Session.create!(sid: new_sid.private_id, data: { "foo" => "bar" }, created_at: 12.hours.ago)

    StoredSession::ExpireSessionsJob.perform_now(max_created_age: 1.day)

    assert_nil StoredSession::Session.find_by(sid: old_sid.private_id)
    assert StoredSession::Session.find_by(sid: new_sid.private_id)
  end

  test "expiring updated sessions older than the max updated age" do
    old_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    old_session = StoredSession::Session.create!(sid: old_sid.private_id, data: { "foo" => "bar" }, updated_at: 2.days.ago)

    new_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    new_session = StoredSession::Session.create!(sid: new_sid.private_id, data: { "foo" => "bar" }, updated_at: 12.hours.ago)

    StoredSession::ExpireSessionsJob.perform_now(max_updated_age: 1.day)

    assert_nil StoredSession::Session.find_by(sid: old_sid.private_id)
    assert StoredSession::Session.find_by(sid: new_sid.private_id)
  end
end
