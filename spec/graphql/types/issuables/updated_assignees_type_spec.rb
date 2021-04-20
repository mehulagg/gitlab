# frozen_string_literal: true
require 'spec_helper'

RSpec.describe GitlabSchema.types['UpdatedAssignees'] do
  it 'has expected fields' do
    expected_fields = %i[
      assignees
    ]

    expect(described_class).to have_graphql_fields(*expected_fields).only
  end
end
