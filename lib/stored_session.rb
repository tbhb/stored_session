require "active_support"
require "active_support/rails"
require "active_support/core_ext/integer/time"
require "active_support/log_subscriber"
require "active_support/message_pack"
require "active_support/notifications"

require "action_dispatch"
require "action_dispatch/middleware/session/abstract_store"

require "active_job"

require "active_record/encryption/message_pack_message_serializer"

require "stored_session/version"
require "stored_session/deprecator"
require "stored_session/configuration"
require "stored_session/engine"

module StoredSession
  mattr_accessor :config, default: StoredSession::Configuration.new
  mattr_accessor :logger

  def self.configure
    yield config
    validate_config!
  end

  def self.validate_config!
    config.validate!
  end

  ActiveSupport.run_load_hooks(:stored_session, self)
end
