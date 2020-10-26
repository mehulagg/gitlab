# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::TerraformStateVersionReplicator do
  let(:model_record) { build(:terraform_state_version, terraform_state: create(:terraform_state)) }

  it_behaves_like 'a blob replicator'
end
