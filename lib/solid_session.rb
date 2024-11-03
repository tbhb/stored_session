require "active_support"
require "active_support/rails"

require "solid_session/version"
require "solid_session/deprecator"
require "solid_session/engine"

require "zeitwerk"

Zeitwerk::Loader.for_gem.tap do |loader|
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
end.setup

module SolidSession
  mattr_accessor :config, default: SolidSession::Configuration.new
  mattr_accessor :executor
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
