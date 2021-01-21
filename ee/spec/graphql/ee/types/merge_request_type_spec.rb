# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['MergeRequest'] do
  it { expect(described_class).to have_graphql_fields(:approvals_required, :merge_trains_count).at_least }
  it { expect(described_class).to have_graphql_field(:approved, complexity: 2, calls_gitaly?: true) }
  it { expect(described_class).to have_graphql_field(:approvals_left, complexity: 2, calls_gitaly?: true) }
end
