# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Milestone'] do
  it 'has the expected fields' do
    expected_fields = %w[
      report
    ]

    expect(described_class).to have_graphql_fields(*expected_fields).at_least
  end
end
