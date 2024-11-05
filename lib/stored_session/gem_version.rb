# :markup: markdown

module StoredSession
  # Returns the currently loaded version of Stored Session as a `Gem::Version`.
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 0
    MINOR = 1
    TINY  = 0
    PRE   = "".freeze

    STRING = [ MAJOR, MINOR, TINY, PRE ].compact.join(".")
  end
end
