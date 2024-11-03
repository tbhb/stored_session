require_relative "lib/solid_session/version"

version = SolidSession::VERSION

Gem::Specification.new do |spec|
  spec.name        = "solid_session"
  spec.version     = version
  spec.authors     = [ "Tony Burns" ]
  spec.email       = [ "tony@tonyburns.net" ]
  spec.homepage    = "https://github.com/tbhb/solid_session"
  spec.summary     = "Database-backed session store for Rails."
  spec.description = "Database-backed session store for Rails."
  spec.license     = "MIT"

  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/tbhb/solid_session/issues",
    "changelog_uri"     => "https://github.com/tbhb/solid_session/blob/v#{version}/CHANGELOG.md",
    "documentation_uri" => "https://github.com/tbhb/solid_session",
    "mailing_list_uri"  => "https://github.com/tbhb/solid_session/discussions",
    "source_code_uri"   => "https://github.com/tbhb/solid_session/tree/v#{version}",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "lib/**/*", "app/**/*", "config/**/*", "db/**/*"]
  spec.require_path = "lib"

  spec.required_ruby_version = ">= 3.2.0"

  rails_version = '>= 7.2'
  spec.add_dependency 'actionpack', rails_version
  spec.add_dependency 'activejob', rails_version
  spec.add_dependency 'activerecord', rails_version
  spec.add_dependency 'railties', rails_version

  spec.add_dependency 'zeitwerk', '~> 2.6'

  spec.add_dependency 'bundler', '>= 1.15.0'
end
