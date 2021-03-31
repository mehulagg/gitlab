# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::MergeRequestDiffReplicator do
  let(:mr_diff) { build(:merge_request_diff, :external) }
  let(:model_record) { build(:merge_request_diff_detail, merge_request_diff: mr_diff) }

  include_examples 'a blob replicator'
  it_behaves_like 'a verifiable replicator'
end
