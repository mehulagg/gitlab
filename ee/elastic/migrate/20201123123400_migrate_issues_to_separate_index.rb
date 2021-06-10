# frozen_string_literal: true

class MigrateIssuesToSeparateIndex < Elastic::Migration
  include Elastic::MigrationObsolete
end
