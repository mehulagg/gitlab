# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20210602063100_retry_backfill_traversal_ids_children.rb')

RSpec.describe RetryBackfillTraversalIdsChildren, :migration do
  let(:bg_class_name) { 'BackfillNamespaceTraversalIdsChildren' }
  let(:namespaces_table) { table(:namespaces) }

  let!(:user_namespace) { namespaces_table.create!(id: 1, name: 'user', path: 'user', type: nil) }
  let!(:root_group) { namespaces_table.create!(id: 2, name: 'group', path: 'group', type: 'Group', parent_id: nil) }
  let!(:sub_group1) { namespaces_table.create!(id: 3, name: 'subgroup-a', path: 'subgroup-a', type: 'Group', parent_id: 2) }
  let!(:sub_group2) { namespaces_table.create!(id: 4, name: 'subgroup-b', path: 'subgroup-b', type: 'Group', parent_id: 2) }

  let!(:background_migration_job1) { table(:background_migration_jobs).create!(class_name: bg_class_name, arguments: [1, 3, 100], status: 1) }
  let!(:background_migration_job2) { table(:background_migration_jobs).create!(class_name: bg_class_name, arguments: [4, 4, 100], status: 0) }

  it 'steals remaining jobs, updates any remaining rows and deletes background_migration_jobs rows' do
    expect(Gitlab::BackgroundMigration).to receive(:steal).with(bg_class_name).and_call_original

    migrate!

    expect(user_namespace.reload.traversal_ids).to eq([])
    expect(root_group.reload.traversal_ids).to eq([])
    expect(sub_group1.reload.traversal_ids).to eq([])
    expect(sub_group2.reload.traversal_ids).to eq([root_group.id, sub_group2.id])

    expect(table(:background_migration_jobs).where(class_name: bg_class_name).count).to eq(0)
  end
end
