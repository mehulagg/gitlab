# frozen_string_literal: true

class PopulateDismissalInformationForVulnerabilities < ActiveRecord::Migration[6.0]
  # Uncomment the following include if you require helper functions:
  # include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 100
  UPDATE_QUERY = <<~SQL
    UPDATE
      vulnerabilities
    SET
      vulnerabilities.dismissed_at = vulnerabilities.updated_at,
      vulnerabilities.dismissed_by_id = COALESCE(vulnerabilities.updated_by_id, vulnerabilities.last_edited_by_id, vulnerabilities.author_id)
    WHERE
      vulnerabilities.id IN (%{ids})
  SQL

  class Vulnerability < ActiveRecord::Base
    include EachBatch

    self.table_name = 'vulnerabilities'

    enum state: { detected: 1, confirmed: 4, resolved: 3, dismissed: 2 }

    scope :broken, -> { dismissed.where('dismissed_at IS NULL OR dismissed_by_id IS NULL') }
  end

  def up
    Vulnerability.broken.each_batch(of: BATCH_SIZE) do |batch|
      query = format(UPDATE_QUERY, ids: batch.pluck(:id).join(', '))

      connection.execute(query)
    end
  end

  def down
    # no-op
  end
end
