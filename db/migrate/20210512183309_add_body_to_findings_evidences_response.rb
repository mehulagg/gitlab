# frozen_string_literal: true

class AddBodyToFindingsEvidencesResponse < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :vulnerability_finding_evidence_responses, :body, :text

    add_text_limit :vulnerability_finding_evidence_responses, :body, 2048
  end

  def down
    remove_column :vulnerability_finding_evidence_responses, :body
  end
end
