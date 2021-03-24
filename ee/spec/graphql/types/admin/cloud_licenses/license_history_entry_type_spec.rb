# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['LicenseHistoryEntry'] do
  let(:fields) do
    %i[name email company plan activated_on valid_from expires_on users_in_license]
  end

  it { expect(described_class.graphql_name).to eq('LicenseHistoryEntry') }

  expect(described_class).to have_graphql_fields(fields)
end
