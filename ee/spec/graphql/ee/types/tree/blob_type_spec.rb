# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Blob'] do
  specify { expect(described_class.graphql_name).to eq('Blob') }

  specify do
    expect(described_class).to have_graphql_fields(
      :can_lock,
      :is_locked,
      :lock_link
    ).at_least
  end
end
