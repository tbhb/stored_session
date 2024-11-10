source "https://rubygems.org"

gemspec

gem "rails", "~> 8.0.0"

gem "propshaft"
gem "puma", ">= 5.0"

gem "mysql2"
gem "pg"
gem "sqlite3"

gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", require: false
end

group :development do
  gem "web-console"

  gem "appraisal", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
  gem "simplecov-console", require: false
end
