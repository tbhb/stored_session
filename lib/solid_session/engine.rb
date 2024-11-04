require "action_dispatch/session/solid_session_store"

require "active_support"
require "action_dispatch"
require "action_controller"
require "active_record"

module SolidSession
  class Engine < ::Rails::Engine
    isolate_namespace SolidSession

    config.solid_session = ActiveSupport::OrderedOptions.new

    initializer "solid_session.deprecator", before: :load_environment_config do |app|
      app.deprecators[:solid_session] = SolidSession.deprecator
    end

    initializer "solid_session.config" do |app|
      SolidSession.config = SolidSession::Configuration.new(app.config.solid_session)
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

      SolidSession::Store.session_class = SolidSession.config.session_class
    end
  end
end
