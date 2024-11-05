require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "authentication" do
    email_address = "user@example.com"
    password = SecureRandom.hex(16)
    user = User.create!(email_address:, password:)

    get "/"

    assert_response :success
    assert_match /Welcome/, response.body
    assert_equal 0, session_count

    get "/protected" # Session created

    assert_redirected_to "/session/new"
    assert_equal 1, session_count

    post "/session", params: { email_address:, password: } # Session reset

    assert_redirected_to "/protected"
    assert_equal 1, session_count

    get "/protected"

    assert_match /Protected/, response.body
    assert_equal 1, session_count

    delete "/session" # Session reset

    assert_redirected_to new_session_path
    assert_equal 1, session_count
  end

  private

  def session_count
    StoredSession::Session.uncached { StoredSession::Session.count }
  end
end
