# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::TerraformStateVersionReplicator, let_it_be_light_freeze: false do
  let(:model_record) { build(:terraform_state_version, terraform_state: create(:terraform_state)) }

  it_behaves_like 'a blob replicator'
end
