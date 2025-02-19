require "rails/generators"
require "rails/generators/migration"
require "rails/generators/active_record"

module Descripto
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(dirname)
        # Standard pattern: if there are existing migrations,
        # increment the largest timestamp. Or just use Time:
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def copy_migrations
        migration_template "create_descripto_tables.rb", "db/migrate/create_descripto_tables.rb"
      end
    end
  end
end
