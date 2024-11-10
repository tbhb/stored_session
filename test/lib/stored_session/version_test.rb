require "test_helper"

class StoredSession::VersionTest < ActiveSupport::TestCase
  test "gem_version" do
    assert_kind_of Gem::Version, StoredSession.gem_version
  end

  test "version" do
    assert_equal StoredSession::VERSION::STRING, StoredSession.version
  end
end
