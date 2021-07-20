# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['EpicBoard'] do
  specify { expect(described_class.graphql_name).to eq('EpicBoard') }

  specify { expect(described_class).to require_graphql_authorizations(:read_epic_board) }

  it 'has specific fields' do
    expected_fields = %w[id name lists hideBacklogList hideClosedList web_url web_path labels]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end
end
