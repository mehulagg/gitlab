# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::MergeRequestDiffReplicator, let_it_be_light_freeze: false do
  let(:model_record) { build(:merge_request_diff, :external) }

  include_examples 'a blob replicator'
end
