require "test_helper"

class StoredSession::ConfigurationTest < ActiveSupport::TestCase
  test "valid with default values" do
    assert_predicate StoredSession::Configuration.new, :valid?
  end
end
