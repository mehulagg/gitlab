# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20210602062146_retry_backfill_traversal_ids_roots.rb')

RSpec.describe RetryBackfillTraversalIdsRoots, :migration do
  let!(:background_migration_job1) { table(:background_migration_jobs).create!(class_name: bg_class_name, arguments: [namespace1.id, namespace2.id, 100], status: 0) }
  let!(:background_migration_job2) { table(:background_migration_jobs).create!(class_name: bg_class_name, arguments: [namespace3.id, namespace4.id, 100], status: 1) }
end
