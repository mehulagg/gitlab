# frozen_string_literal: true

require 'spec_helper'

Rspec.describe GitlabSchema.types['IssueConnection'] do
  it 'has the expected fields' do
    expected_fields = %i[total_count page_info edges nodes]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
