# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ApiFuzzingCiConfiguration'] do
  let_it_be(:fields) { %i[scanModes scanProfiles] }

  it { expect(described_class).to have_graphql_fields(fields) }
end
