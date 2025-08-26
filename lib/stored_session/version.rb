# :markup: markdown

# :nocov:
module StoredSession
  module VERSION
    MAJOR = 0
    MINOR = 5
    TINY  = 0
    PRE   = nil

    STRING = [ MAJOR, MINOR, TINY, PRE ].compact.join(".")
  end

  # Returns the currently loaded version of Stored Session as a `Gem::Version`.
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  # Returns the currently loaded version of Stored Session as a `String`.
  def self.version
    VERSION::STRING
  end
end
# :nocov:
