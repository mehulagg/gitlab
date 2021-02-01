# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['EpicIssue'] do
  it { expect(described_class.graphql_name).to eq('EpicIssue') }

  it { expect(described_class).to require_graphql_authorizations(:read_issue) }

  it 'has specific fields' do
    %i[epic_issue_id relation_path].each do |field_name|
      expect(described_class).to have_graphql_field(field_name)
    end
  end
end
