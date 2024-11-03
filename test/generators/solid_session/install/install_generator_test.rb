require "test_helper"
require_relative "../../../../lib/generators/solid_session/install/install_generator"

class SolidSession::InstallGeneratorTest < Rails::Generators::TestCase
  tests SolidSession::InstallGenerator
  destination File.expand_path("../../../../tmp", __dir__)

  setup :prepare_destination
  setup :run_generator

  test "session.yml exists" do
    assert_file "config/session.yml"
  end
end
