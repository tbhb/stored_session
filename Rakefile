require "bundler/setup"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

DATABASES = %w[ mysql postgres sqlite ]

task :test do
  DATABASES.each do |database|
    sh "TARGET_DB=#{database} bin/setup"
    sh "TARGET_DB=#{database} bin/rails test"
  end
end
