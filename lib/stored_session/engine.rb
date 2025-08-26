require "action_dispatch/session/stored_session_store"

require "stored_session/log_subscriber"

module StoredSession
  class Engine < ::Rails::Engine
    isolate_namespace StoredSession

    config.stored_session = ActiveSupport::OrderedOptions.new

    initializer "stored_session.deprecator", before: "active_support.deprecation_behavior" do |app|
      app.deprecators[:stored_session] = StoredSession.deprecator
    end

    initializer "stored_session.config", after: :load_config_initializers do |app|
      app.paths.add "config/stored_session", with: "config/stored_session.yml"
      config_exists = Pathname.new(app.config.paths["config/stored_session"].first).exist?
      options = config_exists ? app.config_for(:stored_session).to_h.deep_symbolize_keys : {}

      options[:connects_to] = config.stored_session.connects_to if config.stored_session.connects_to
      options[:encrypt] = config.stored_session.encrypt if config.stored_session.key?(:encrypt)

      options[:base_controller_class_name] = config.stored_session.base_controller_class_name if config.stored_session.base_controller_class_name
      options[:base_job_class_name] = config.stored_session.base_job_class_name if config.stored_session.base_job_class_name
      options[:base_record_class_name] = config.stored_session.base_record_class_name if config.stored_session.base_record_class_name

      options[:sessions_table_name] = config.stored_session.sessions_table_name if config.stored_session.sessions_table_name
      options[:session_class_name] = config.stored_session.session_class_name if config.stored_session.session_class_name
      options[:session_max_created_age] = config.stored_session.session_max_created_age if config.stored_session.session_max_created_age
      options[:session_max_updated_age] = config.stored_session.session_max_updated_age if config.stored_session.session_max_updated_age

      options[:expire_sessions_job_queue_as] = config.stored_session.expire_sessions_job_queue_as if config.stored_session.expire_sessions_job_queue_as

      StoredSession.config = StoredSession::Configuration.new(**options)
    end

    initializer "stored_session.logger", after: :initialize_logger do
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
