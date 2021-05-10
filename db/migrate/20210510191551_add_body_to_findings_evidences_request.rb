# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddBodyToFindingsEvidencesRequest < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :vulnerability_finding_evidence_requests, :body, :text

    add_text_limit :vulnerability_finding_evidence_requests, :body, 2048
  end

  def down
    remove_column :vulnerability_finding_evidence_requests, :body
  end
end
