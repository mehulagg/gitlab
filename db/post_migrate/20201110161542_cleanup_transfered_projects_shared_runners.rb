# frozen_string_literal: true

class CleanupTransferedProjectsSharedRunners < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  disable_ddl_transaction!

  class Namespace < ActiveRecord::Base
    include EachBatch

    self.table_name = 'namespaces'
  end

  class Project < ActiveRecord::Base
    self.table_name = 'projects'
  end

  def up
    Project.reset_column_information

    Namespace.each_batch(of: 25_000) do |relation|
      ids = relation.where(shared_runners_enabled: false, allow_descendants_override_disabled_shared_runners: false).select(:id)

      Project.where(namespace_id: ids).update_all(shared_runners_enabled: false)
    end
  end

  def down
    # This migration fixes an inconsistent database state resulting from https://gitlab.com/gitlab-org/gitlab/-/issues/271728
    # and as such does not require a down migration
  end
end
