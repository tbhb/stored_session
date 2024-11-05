# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
require "rails/test_help"
require "debug"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

SharedTestRoutes = ActionDispatch::Routing::RouteSet.new

module ActionDispatch
  module SharedRoutes
    def before_setup
      @routes = SharedTestRoutes
      super
    end
  end
end

class RoutedRackApp
  class Config < Struct.new(:middleware)
  end

  attr_reader :routes, :stack

  def initialize(routes, &blk)
    @routes = routes
    @stack = ActionDispatch::MiddlewareStack.new(&blk)
    @app = @stack.build(@routes)
  end

  def call(env)
    @app.call(env)
  end

  def config
    Config.new(@stack)
  end
end

class ActionDispatch::IntegrationTest < ActiveSupport::TestCase
  include ActionDispatch::SharedRoutes

  def self.build_app(routes = nil)
    RoutedRackApp.new(routes || ActionDispatch::Routing::RouteSet.new) do |middleware|
      middleware.use ActionDispatch::DebugExceptions
      middleware.use ActionDispatch::Callbacks
      middleware.use ActionDispatch::Cookies
      middleware.use ActionDispatch::Flash
      middleware.use Rack::Head
      yield(middleware) if block_given?
    end
  end

  private
    # def app
    #   @app ||= self.class.build_app do |middleware|
    #     middleware.use ActionDispatch::Session::StoredSessionStore, key: "_session_id"
    #     middleware.delete ActionDispatch::ShowExceptions
    #   end
    # end

    def with_test_route_set(options = {})
      controller_namespace = self.class.to_s.underscore
      with_routing do |set|
        set.draw do
          ActionDispatch.deprecator.silence do
            get ":action", controller: "#{controller_namespace}/test"
          end
        end

        @app = self.class.build_app(set) do |middleware|
          middleware.use ActionDispatch::Session::StoredSessionStore, options.reverse_merge(key: "_session_id")
          middleware.delete ActionDispatch::ShowExceptions
        end

        reset!

        yield
      end
    end
end
