# frozen_string_literal: true

require 'spec_helper'

require_migration!('delete_legacy_operations_feature_flags')

RSpec.describe DeleteLegacyOperationsFeatureFlags do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:operations_feature_flags) { table(:operations_feature_flags) }
  let(:namespace) { namespaces.create!(name: 'foo', path: 'bar') }
  let(:project) { projects.create!(namespace_id: namespace.id) }

  it 'correctly deletes `BuildsEmailService` services' do
    # Legacy version - dropped support in GitLab 14.0.
    operations_feature_flags.create!(project_id: project.id, version: 1)
    # New version.
    operations_feature_flags.create!(project_id: project.id, version: 2)

    expect(operations_feature_flags.all.pluck(:version)).to match_array %w[1 2]

    migrate!

    expect(operations_feature_flags.all.pluck(:version)).to match_array %w[2]
  end
end
