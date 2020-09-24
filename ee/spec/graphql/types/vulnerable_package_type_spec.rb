# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['VulnerablePackage'] do
  it { expect(described_class).to have_graphql_fields(:name) }
end
