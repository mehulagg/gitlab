# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::TerraformStateVersionReplicator do
  let(:model_record) { build(:terraform_state_version, terraform_state: create(:terraform_state)) }
  let(:replicator) { described_class.new(model_record_id: model_record.id) }
  let(:secondary) { create(:geo_node, :secondary) }
  let(:primary) { create(:geo_node, :primary)}

  it_behaves_like 'a blob replicator'
  it_behaves_like 'a verifiable replicator'
end
