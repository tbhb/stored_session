require "solid_session/version"
require "solid_session/deprecator"
require "solid_session/engine"

require "action_dispatch"
require "action_dispatch/middleware/session/abstract_store"

require "active_record/encryption/message_pack_message_serializer"

require "active_support"
require "active_support/log_subscriber"
require "active_support/message_pack"

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore(
  "#{__dir__}/solid_session/deprecator.rb",
  "#{__dir__}/solid_session/gem_version.rb",
  "#{__dir__}/solid_session/version.rb",
  "#{__dir__}/generators",
  "#{__dir__}/tasks"
)
loader.do_not_eager_load(
  "#{__dir__}/solid_session/test_helper.rb"
)
loader.setup

module SolidSession
  mattr_accessor :config, default: SolidSession::Configuration.new
  mattr_accessor :logger

  def self.configure
    yield config
    validate_config!
  end

  def self.validate_config!
    config.validate!
  end

  ActiveSupport.run_load_hooks(:solid_session, self)
end
