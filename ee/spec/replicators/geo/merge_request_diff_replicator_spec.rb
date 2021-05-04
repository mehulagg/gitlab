# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::MergeRequestDiffReplicator do
  # TODO should model record be mr_Diff_detail?
  let(:model_record) { build(:merge_request_diff, :external) }

  include_examples 'a blob replicator'
  include_examples 'a verifiable replicator'
end
