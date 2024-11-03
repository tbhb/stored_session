require "test_helper"

class SolidSession::ConfigurationTest < ActiveSupport::TestCase
  test "valid with default values" do
    assert_predicate SolidSession::Configuration.new, :valid?
  end
end
