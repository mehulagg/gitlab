# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Namespace'] do
  it { expect(described_class).to have_graphql_field(:storage_size_limit) }
end
