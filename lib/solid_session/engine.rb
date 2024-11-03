module SolidSession
  class Engine < ::Rails::Engine
    isolate_namespace SolidSession

    config.solid_session = ActiveSupport::OrderedOptions.new

    initializer "solid_session.deprecator", before: :load_environment_config do |app|
      app.deprecators[:solid_session] = SolidSession.deprecator
    end

    initializer "solid_session.config" do |app|
      config_paths = %w[config/session config/solid_session]
      config_paths.each { |path| app.paths.add path, with: ENV["SOLID_SESSION_CONFIG"] || "#{path}.yml" }
      config_pathname = config_paths.map { |path| Pathname.new(app.config.paths[path].first) }.find(&:exist?)

      options = config_pathname ? app.config_for(config_pathname).to_h.deep_symbolize_keys : {}
      options.merge!(app.config.solid_session)

      SolidSession.config = SolidSession::Configuration.new(**options)
    end

    initializer "solid_session.executor" do |app|
      SolidSession.executor ||= app.executor
    end

    initializer "solid_session.logger" do
      ActiveSupport.on_load(:solid_session) { self.logger ||= ::Rails.logger }
      SolidSession::LogSubscriber.attach_to :solid_session
    end

    config.after_initialize do |app|
      unless app.config.eager_load
        SolidSession.config.base_controller_class
        SolidSession.config.base_job_class
        SolidSession.config.base_record_class
      end

      SolidSession.config.validate!
    end
  end
end
