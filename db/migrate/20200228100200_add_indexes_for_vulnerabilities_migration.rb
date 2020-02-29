# frozen_string_literal: true

class AddIndexesForVulnerabilitiesMigration < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  VULNERABILITIES_INDEX_NAME = 'index_vulnerabilities_for_occurrence_id_update'
  VULNERABILITY_OCCURRENCES_INDEX_NAME = 'index_vulnerability_occurrences_for_occurrence_id_update'

  disable_ddl_transaction!

  def up
    add_concurrent_index :vulnerabilities,
      [:vulnerability_occurrence_id],
      name: VULNERABILITIES_INDEX_NAME,
      using: :btree

    add_concurrent_index :vulnerability_occurrences,
      [:id, :project_id],
      name: VULNERABILITY_OCCURRENCES_INDEX_NAME,
      using: :btree
  end

  def down
    remove_concurrent_index_by_name :vulnerability_occurrences, VULNERABILITY_OCCURRENCES_INDEX_NAME
    remove_concurrent_index_by_name :vulnerabilities, VULNERABILITIES_INDEX_NAME
  end
end
