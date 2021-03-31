# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::MergeRequestDiffReplicator do
  let(:model_record) { build(:merge_request_diff, :external) }

  include_examples 'a blob replicator'
  it_behaves_like 'a verifiable replicator'
end
