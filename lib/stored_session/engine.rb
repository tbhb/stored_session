require "action_dispatch/session/stored_session_store"

require "active_support"
require "action_dispatch"
require "action_controller"
require "active_record"

module StoredSession
  class Engine < ::Rails::Engine
    isolate_namespace StoredSession

    config.stored_session = ActiveSupport::OrderedOptions.new

    initializer "stored_session.deprecator", before: :load_environment_config do |app|
      app.deprecators[:stored_session] = StoredSession.deprecator
    end

    initializer "stored_session.config" do |app|
      StoredSession.config = StoredSession::Configuration.new(app.config.stored_session)
    end

    initializer "stored_session.logger" do
      ActiveSupport.on_load(:stored_session) { self.logger ||= ::Rails.logger }
      StoredSession::LogSubscriber.attach_to :stored_session
    end

    config.after_initialize do |app|
      unless app.config.eager_load
        StoredSession.config.base_controller_class
        StoredSession.config.base_job_class
        StoredSession.config.base_record_class
      end

      StoredSession.config.validate!
    end
  end
end
