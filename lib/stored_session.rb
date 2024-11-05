require "stored_session/version"
require "stored_session/deprecator"
require "stored_session/engine"

require "action_dispatch"
require "action_dispatch/middleware/session/abstract_store"

require "active_job"

require "active_record/encryption/message_pack_message_serializer"

require "active_support"
require "active_support/core_ext/integer/time"
require "active_support/log_subscriber"
require "active_support/message_pack"
require "active_support/notifications"

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore(
  "#{__dir__}/stored_session/deprecator.rb",
  "#{__dir__}/stored_session/gem_version.rb",
  "#{__dir__}/stored_session/version.rb",
  "#{__dir__}/generators",
  "#{__dir__}/tasks"
)
loader.do_not_eager_load(
  "#{__dir__}/stored_session/test_helper.rb"
)
loader.setup

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
