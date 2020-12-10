class RemoveDuplicateVulnerabilitiesFindings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = "tmp_idx_deduplicate_vulnerability_occurrences"
  BATCH_SIZE = 10_000

  disable_ddl_transaction!

  class VulnerabilitiesFinding < ActiveRecord::Base
    include ::EachBatch
    self.table_name = "vulnerability_occurrences"
  end

  def up
    add_concurrent_index :vulnerability_occurrences,
      %i[project_id report_type location_fingerprint primary_identifier_id id],
      name: INDEX_NAME

    VulnerabilitiesFinding.each_batch(of: BATCH_SIZE) do |relation|
      cte = Gitlab::SQL::CTE.new(:batch, relation.select(:report_type, :location_fingerprint, :primary_identifier_id, :project_id))

      query = VulnerabilitiesFinding
        .select('batch.report_type', 'batch.location_fingerprint', 'batch.primary_identifier_id', 'batch.project_id', 'array_agg(id) as ids')
        .distinct
        .with(cte.to_arel)
        .from(cte.alias_to(Arel.sql('batch')))
        .joins(
          %(
          INNER JOIN
          vulnerability_occurrences ON
          vulnerability_occurrences.report_type = batch.report_type AND
          vulnerability_occurrences.location_fingerprint = batch.location_fingerprint AND
          vulnerability_occurrences.primary_identifier_id = batch.primary_identifier_id AND
          vulnerability_occurrences.project_id = batch.project_id
        )).group('batch.report_type', 'batch.location_fingerprint', 'batch.primary_identifier_id', 'batch.project_id')
          .having('COUNT(*) > 1')

      query.to_a.each do |record|
        # We want to keep the latest finding since it might have recent metadata
        id_to_remove = record.ids.uniq.min
        VulnerabilitiesFinding.destroy(record.ids.uniq.min)
      end
    end

    remove_concurrent_index_by_name :vulnerability_occurrences, INDEX_NAME
  end

  def down
  end
end
