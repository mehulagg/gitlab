# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['EpicDescendantCount'] do
  it { expect(described_class.graphql_name).to eq('EpicDescendantCount') }

  it 'has specific fields' do
    %i[opened_epics closed_epics opened_issues closed_issues].each do |field_name|
      expect(described_class).to have_graphql_field(field_name)
    end
  end
end
