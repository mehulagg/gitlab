# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Milestone'] do
  it { expect(described_class).to have_graphql_field(:burnup_time_series) }
end
