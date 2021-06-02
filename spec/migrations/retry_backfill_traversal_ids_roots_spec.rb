# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20210602062146_retry_backfill_traversal_ids_roots.rb')

RSpec.describe RetryBackfillTraversalIdsRoots, :migration do
  let(:bg_class_name) { 'BackfillNamespaceTraversalIdsRoots' }
  let(:namespaces_table) { table(:namespaces) }

  let!(:root_group1) { namespaces_table.create!(id: 1, name: 'group-a', path: 'group-a', type: 'Group', parent_id: nil) }
  let!(:root_group2) { namespaces_table.create!(id: 2, name: 'group-b', path: 'group-b', type: 'Group', parent_id: nil) }
  let!(:sub_group) { namespaces_table.create!(id: 3, name: 'subgroup', path: 'subgroup', type: 'Group', parent_id: 2) }

  let!(:background_migration_job1) { table(:background_migration_jobs).create!(class_name: bg_class_name, arguments: [1, 1, 100], status: 1) }
  let!(:background_migration_job2) { table(:background_migration_jobs).create!(class_name: bg_class_name, arguments: [2, 3, 100], status: 0) }

  it 'steals remaining jobs, updates any remaining rows and deletes background_migration_jobs rows' do
    expect(Gitlab::BackgroundMigration).to receive(:steal).with(bg_class_name).and_call_original

    migrate!

    expect(root_group1.reload.traversal_ids).to eq([])
    expect(root_group2.reload.traversal_ids).to eq([root_group2.id])
    expect(sub_group.reload.traversal_ids).to eq([])

    expect(table(:background_migration_jobs).where(class_name: bg_class_name).count).to eq(0)
  end
end
