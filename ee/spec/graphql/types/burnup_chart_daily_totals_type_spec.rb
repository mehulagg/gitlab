# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['BurnupChartDailyTotals'] do
  it { expect(described_class.graphql_name).to eq('BurnupChartDailyTotals') }

  it 'has specific fields' do
    expect(described_class).to have_graphql_fields(
      :date,
      :scope_count,
      :scope_weight,
      :completed_count,
      :completed_weight
    )
  end
end
