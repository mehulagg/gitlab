# frozen_string_literal: true

class CreateCiSchema < ActiveRecord::Migration[6.1]
  include Gitlab::Database::SchemaHelpers

  DOWNTIME = false

  def up
    execute 'CREATE SCHEMA gitlab_ci'

    create_comment(:schema, :gitlab_ci, <<~EOS.strip)
      Schema to hold all tables owned by GitLab CI feature
    EOS
  end

  def down
    execute 'DROP SCHEMA gitlab_ci'
  end
end
