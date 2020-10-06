# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Namespace'] do
  it 'has specific fields' do
    expected_fields = %w[
      additional_purchased_storage_size
      total_repository_size_excess
      total_repository_size
      contains_locked_projects
      repository_size_excess_project_count
      storage_size_limit
      is_temporary_storage_increase_enabled
      temporary_storage_increase_ends_on
    ]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end
end
