require "test_helper"

class SolidSession::StoreTest < ActionDispatch::IntegrationTest
  class TestController < ActionController::Base
    def set_session_value
      session[:foo] = params[:foo] || "bar"
      head :ok
    end

    def get_session_value
      render plain: "foo: #{session[:foo].inspect}"
    end

    def get_session_id
      render plain: "#{request.session['session_id']}"
    end

    def call_reset_session
      session[:foo]
      reset_session
      reset_session if params[:twice]
      session[:foo] = "baz"
      head :ok
    end
  end

  test "setting and getting session value" do
    with_test_route_set do
      get "/set_session_value"
      assert_response :success
      assert cookies["_session_id"]

      get "/get_session_value"
      assert_response :success
      assert_equal 'foo: "bar"', response.body

      get "/set_session_value", params: { foo: "baz" }
      assert_response :success
      assert cookies["_session_id"]

      get "/get_session_value"
      assert_response :success
      assert_equal 'foo: "baz"', response.body

      get "/call_reset_session"
      assert_response :success
      assert cookies["_session_id"]
    end
  end

  test "getting nil session value" do
    with_test_route_set do
      get "/get_session_value"
      assert_response :success
      assert_equal "foo: nil", response.body
    end
  end

  test "calling reset_session twice does not raise errors" do
    with_test_route_set do
      get "/call_reset_session", params: { twice: "true" }
      assert_response :success

      get "/get_session_value"
      assert_response :success
      assert_equal 'foo: "baz"', response.body
    end
  end

  test "setting session value after reset" do
    with_test_route_set do
      get "/set_session_value"
      assert_response :success
      assert cookies["_session_id"]
      session_id = cookies["_session_id"]

      get "/call_reset_session"
      assert_response :success
      assert cookies["_session_id"]

      get "/get_session_id"
      assert_response :success
      assert_not_equal session_id, response.body
    end
  end

  test "getting session value after reset" do
    with_test_route_set do
      get "/set_session_value"
      assert_response :success
      assert cookies["_session_id"]
      session_cookie = cookies.get_cookie("_session_id")

      get "/call_reset_session"
      assert_response :success
      assert cookies["_session_id"]

      cookies << session_cookie

      get "/get_session_value"
      assert_response :success
      assert_equal "foo: nil", response.body, "data for this session should have been obliterated from the database"
    end
  end

  test "getting from non-existent session" do
    with_test_route_set do
      get "/get_session_value"
      assert_response :success
      assert_equal "foo: nil", response.body
      assert_nil cookies["_session_id"], "should only create session on write, not read"
    end
  end

  test "getting session id" do
    with_test_route_set do
      get "/set_session_value"
      assert_response :success
      assert cookies["_session_id"]
      session_id = cookies["_session_id"]

      get "/get_session_id"
      assert_response :success
      assert_equal session_id, response.body, "should be able to read session id without accessing the session hash"
    end
  end

  test "doesn't write session cookie if session id already exists" do
    with_test_route_set do
      get "/set_session_value"
      assert_response :success
      assert cookies["_session_id"]

      get "/get_session_value"
      assert_response :success
      assert_nil headers["Set-Cookie"]
    end
  end

  test "prevents session fixation" do
    with_test_route_set do
      sid = Rack::Session::SessionId.new("0xhax")
      assert_nil SolidSession::Session.find_by(sid: sid.private_id)

      cookies["_session_id"] = sid.public_id
      get "/set_session_value"

      assert_response :success
      assert_not_equal sid.public_id, cookies["_session_id"]
      assert_nil SolidSession::Session.find_by(sid: sid.private_id)
      assert_equal(
        { "foo" => "bar" },
        SolidSession::Session.read(Rack::Session::SessionId.new(cookies["_session_id"]).private_id)
      )
    end
  end

  test "allows session fixation" do
    with_test_route_set(cookie_only: false) do
      get "/set_session_value"
      assert_response :success
      assert cookies["_session_id"]

      get "/get_session_value"
      assert_response :success
      assert_equal 'foo: "bar"', response.body
      session_id = cookies["_session_id"]
      assert session_id

      reset!

      get "/set_session_value", params: { _session_id: session_id, foo: "baz" }
      assert_response :success
      assert_equal session_id, cookies["_session_id"]

      get "/get_session_value", params: { _session_id: session_id }
      assert_response :success
      assert_equal 'foo: "baz"', response.body
      assert_equal session_id, cookies["_session_id"]
    end
  end

  test "ignores invalid session id from cookie" do
    with_test_route_set do
      open_session do |sess|
        sess.cookies["_session_id"] = "INVALID"

        sess.get "/set_session_value"
        new_sid = sess.cookies["_session_id"]
        assert_not_equal "INVALID", new_sid

        sess.get "/get_session_value"
        new_sid_2 = sess.cookies["_session_id"]
        assert_equal new_sid, new_sid_2
      end
    end
  end

  test "ignores invalid session id from param" do
    with_test_route_set(cookie_only: false) do
      open_session do |sess|
        sess.get "/set_session_value", params: { _session_id: "INVALID" }
        new_session_id = sess.cookies["_session_id"]
        assert_not_equal "INVALID", new_session_id

        sess.get "/get_session_value"
        new_session_id_2 = sess.cookies["_session_id"]
        assert_equal new_session_id, new_session_id_2
      end
    end
  end

  test "with all domains" do
    with_test_route_set(domain: :all) do
      get "/set_session_value"
      assert_response :success
    end
  end

  test "sessions are indexed by hashed session" do
    with_test_route_set do
      get "/set_session_value"
      assert_response :success
      public_session_id = cookies["_session_id"]

      session = SolidSession::Session.last
      assert session
      assert_not_equal public_session_id, session.sid

      expected_private_id = Rack::Session::SessionId.new(public_session_id).private_id

      assert_equal expected_private_id, session.sid
    end
  end

  test "sessions cannot be retrieved by their private session id" do
    with_test_route_set do
      get "/set_session_value", params: { foo: "baz" }
      assert_response :success

      session = SolidSession::Session.last
      private_session_id = session.sid

      cookies.merge("_session_id=#{private_session_id};path=/")

      get "/get_session_value"
      assert_response :success
      assert_equal "foo: nil", response.body
    end
  end
end
