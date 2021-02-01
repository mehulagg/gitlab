# frozen_string_literal: true

class MigrateDelayedProjectRemovalFromNamespacesToNamespaceSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  class Namespace < ActiveRecord::Base
    self.table_name = 'namespaces'

    include ::EachBatch
  end

  def up
    Namespace.select(:id).where(delayed_project_removal: true).each_batch do |batch|
      execute <<-EOF.strip_heredoc
        UPDATE namespace_settings
        SET delayed_project_removal = TRUE
        WHERE namespace_id IN (#{batch.to_sql})
      EOF
    end
  end

  def down
    # no-op
  end
end
