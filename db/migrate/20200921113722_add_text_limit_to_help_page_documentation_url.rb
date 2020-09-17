# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTextLimitToHelpPageDocumentationUrl < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_text_limit :application_settings, :help_page_documentation_url, 255
  end

  def down
    remove_text_limit :application_settings, :help_page_documentation_url
  end
end
