require "test_helper"

class SolidSession::SessionTest < ActiveSupport::TestCase
  test "read with a valid session id" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    session = SolidSession::Session.create!(sid: sid.private_id, data: { "foo" => "bar" })

    assert_equal({ "foo" => "bar" }, SolidSession::Session.read(sid.private_id))
  end

  test "read with an invalid session id" do
    assert_nil SolidSession::Session.read("INVALID")
  end

  test "write with an existing session id" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    session = SolidSession::Session.create!(sid: sid.private_id, data: { "foo" => "bar" })

    assert SolidSession::Session.write(sid.private_id, { "foo" => "baz" })

    assert_equal({ "foo" => "baz" }, SolidSession::Session.read(sid.private_id))
  end

  test "write with a new session id" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))

    assert SolidSession::Session.write(sid.private_id, { "foo" => "bar" })

    assert_equal({ "foo" => "bar" }, SolidSession::Session.read(sid.private_id))
  end

  test "write with invalid data" do
    sid = Rack::Session::SessionId.new(SecureRandom.hex(16))

    assert_not SolidSession::Session.write(sid.private_id, "not a hash")
  end

  test "trim! with sessions older than the max age" do
    old_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    old_session = SolidSession::Session.create!(sid: old_sid.private_id, data: { "foo" => "bar" }, updated_at: 2.days.ago)

    new_sid = Rack::Session::SessionId.new(SecureRandom.hex(16))
    new_session = SolidSession::Session.create!(sid: new_sid.private_id, data: { "foo" => "bar" }, updated_at: 12.hours.ago)

    SolidSession::Session.trim!(1.day)

    assert_nil SolidSession::Session.find_by(sid: old_sid.private_id)
    assert SolidSession::Session.find_by(sid: new_sid.private_id)
  end
end
