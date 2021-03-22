# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Scan'] do
  let(:fields) { %i(name errors) }

  it { expect(described_class).to have_graphql_fields(fields) }
  it { expect(described_class).to require_graphql_authorizations(:read_scan) }
end
