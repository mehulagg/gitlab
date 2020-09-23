# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::MergeRequestDiffRegistry, :geo, type: :model do
  let_it_be(:merge_request) { create(:merge_request) }
  let_it_be(:merge_request_diff) { create(:merge_request_diff, merge_request: merge_request) }
  let_it_be(:registry) { create(:geo_merge_request_diff_registry, merge_request_diff: merge_request_diff) }

  specify 'factory is valid' do
    expect(registry).to be_valid
  end

  include_examples 'a Geo framework registry'
end
