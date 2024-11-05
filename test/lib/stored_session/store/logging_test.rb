require "test_helper"

class StoredSession::Store::LoggingTest < ActionDispatch::IntegrationTest
  class TestController < ActionController::Base
    def set_session_value
      session[:foo] = params[:foo] || "bar"
      head :ok
    end

    def get_session_value
      render plain: "foo: #{session[:foo].inspect}"
    end

    def call_reset_session
      session[:foo]
      reset_session
      head :ok
    end
  end

  test "silenced by default" do
    with_test_route_set do
      with_logger do
        get "/set_session_value"
        get "/get_session_value"
        get "/call_reset_session"

        assert_no_match /StoredSession::Session Upsert/, fake_logger.string
        assert_no_match /StoredSession::Session Load/, fake_logger.string
        assert_no_match /StoredSession::Session Delete/, fake_logger.string
      end
    end
  end

  test "silenced" do
    with_test_route_set(silence: true) do
      with_logger do
        get "/set_session_value"
        get "/get_session_value"
        get "/call_reset_session"

        assert_no_match /StoredSession::Session Upsert/, fake_logger.string
        assert_no_match /StoredSession::Session Load/, fake_logger.string
        assert_no_match /StoredSession::Session Delete/, fake_logger.string
      end
    end
  end

  test "not silenced" do
    with_test_route_set(silence: false) do
      with_logger do
        get "/set_session_value"
        get "/get_session_value"
        get "/call_reset_session"

        assert_match /StoredSession::Session Upsert/, fake_logger.string
        assert_match /StoredSession::Session Load/, fake_logger.string
        assert_match /StoredSession::Session Delete/, fake_logger.string
      end
    end
  end

  private
    def with_logger(&)
      old_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = ActiveSupport::Logger.new(fake_logger)
      yield
    ensure
      ActiveRecord::Base.logger = old_logger
    end

    def fake_logger
      @fake_logger ||= StringIO.new
    end
end
