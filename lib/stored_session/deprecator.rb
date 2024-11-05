module StoredSession
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new
  end
end
