require "action_dispatch/session/stored_session_store"

require "stored_session/log_subscriber"

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
      # :nocov:
      unless app.config.eager_load
        StoredSession.config.base_controller_class
        StoredSession.config.base_job_class
        StoredSession.config.base_record_class
      end
      # :nocov:

      StoredSession.config.validate!
    end
  end
end
