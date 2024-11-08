require "test_helper"

Rails.application.load_tasks

class StoredSessionTasksTest < ActiveSupport::TestCase
  setup do
    $stdout, @original_stdout = StringIO.new, $stdout
    $stderr, @original_stderr = StringIO.new, $stderr
  end

  teardown do
    $stdout, $stderr = @original_stdout, @original_stderr
  end

  test "stored_session:expire" do
    Rake::Task["stored_session:expire"].reenable
    3.times do
      StoredSession::Session.create!(
        sid: Rack::Session::SessionId.new(SecureRandom.hex(16)).private_id,
        data: { "foo" => "bar" }, created_at: 31.days.ago, updated_at: 31.days.ago
      )
    end

    assert_difference -> { StoredSession::Session.uncached_count }, -3 do
      Rake::Task["stored_session:expire"].invoke
    end

    assert_match /Expired 3 session\(s\)/, $stdout.string
  end

  test "stored_session:sessions:expire with no sessions" do
    Rake::Task["stored_session:expire"].reenable
    3.times do
      StoredSession::Session.create!(
        sid: Rack::Session::SessionId.new(SecureRandom.hex(16)).private_id,
        data: { "foo" => "bar" }
      )
    end

    assert_no_difference -> { StoredSession::Session.uncached_count } do
      Rake::Task["stored_session:expire"].invoke
    end

    assert_match /No sessions to expire/, $stdout.string
  end

  test "stored_session:expire_later" do
    Rake::Task["stored_session:expire_later"].reenable
    assert_enqueued_with(job: StoredSession::ExpireSessionsJob) do
      Rake::Task["stored_session:expire_later"].invoke
    end

    assert_match /Enqueued session expiration job/, $stdout.string
  end
end
