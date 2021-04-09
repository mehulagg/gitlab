# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ApprovalRule'] do
  let(:fields) { %i[id name type] }

  it { expect(described_class).to have_graphql_fields(fields) }
  it { expect(described_class).to require_graphql_authorizations(:read_approval_rule) }
end
