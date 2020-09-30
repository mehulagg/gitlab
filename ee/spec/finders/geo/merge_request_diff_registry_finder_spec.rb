# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::MergeRequestDiffRegistryFinder do
  it_behaves_like 'a framework registry finder', :geo_merge_request_diff_registry
end
