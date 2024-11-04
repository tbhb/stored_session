require "test_helper"

class SolidSession::TrimSessionsJobTest < ActiveJob::TestCase
  test "trimming sessions older than the max age" do
    old_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    old_session = SolidSession::Session.create!(sid: old_sid.private_id, data: { "foo" => "bar" }, updated_at: 2.days.ago)

    new_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    new_session = SolidSession::Session.create!(sid: new_sid.private_id, data: { "foo" => "bar" }, updated_at: 12.hours.ago)

    SolidSession::TrimSessionsJob.perform_now(1.day)

    assert_nil SolidSession::Session.find_by(sid: old_sid.private_id)
    assert SolidSession::Session.find_by(sid: new_sid.private_id)
  end
end
