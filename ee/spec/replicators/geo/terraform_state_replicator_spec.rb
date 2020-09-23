# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::TerraformStateReplicator do
  let(:model_record) { build(:terraform_state, :with_file) }

  it_behaves_like 'a blob replicator'

  context 'Terraform state versioning is enabled' do
    let(:model_record) { build(:terraform_state, :with_version) }
    let(:replicator) { model_record.replicator }

    describe '#handle_after_create_commit' do
      subject { replicator.handle_after_create_commit }

      it 'does not create a Geo::Event' do
        expect { subject }.not_to change { ::Geo::Event.count }
      end
    end

    describe '#handle_after_destroy' do
      subject { replicator.handle_after_destroy }

      it 'does not create a Geo::Event' do
        expect { subject }.not_to change { ::Geo::Event.count }
      end
    end
  end
end
