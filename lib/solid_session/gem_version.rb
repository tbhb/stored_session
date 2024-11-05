# :markup: markdown

module SolidSession
  # Returns the currently loaded version of Solid Session as a `Gem::Version`.
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
