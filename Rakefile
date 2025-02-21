# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

# Task to run gem tests only
Rake::TestTask.new(:test_gem) do |t|
  t.libs << "test"
  t.libs << "lib"

  # Run only gem tests (ignoring dummy app tests)
  t.test_files = FileList["test/**/*_test.rb"] - FileList["test/dummy/test/**/*_test.rb"]
end

# Task to run dummy app tests separately
desc "Run tests in the dummy Rails app"
task :test_dummy do
  sh "cd test/dummy && RAILS_ENV=test bin/rails test"
end

# Default test task runs both
desc "Run all tests (gem + dummy app)"
task test: %i[test_gem test_dummy]

task default: %i[test]
