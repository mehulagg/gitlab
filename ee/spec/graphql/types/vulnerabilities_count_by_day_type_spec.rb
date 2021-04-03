# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['VulnerabilitiesCountByDay'] do
  it { expect(described_class).to have_graphql_fields(:total, :date, :info, :unknown, :low, :medium, :high, :critical) }
end
