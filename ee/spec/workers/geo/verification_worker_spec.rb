# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::VerificationWorker, :geo do
  include EE::GeoHelpers

  let(:package_file) { create(:conan_package_file, :conan_recipe_file) }

  describe '#perform' do
    it 'calls calculate_checksum!' do
      replicator = double(:replicator)
      allow(::Gitlab::Geo::Replicator).to receive(:for_replicable_params).with(replicable_name: 'package_file', replicable_id: package_file.id).and_return(replicator)

      expect(replicator).to receive(:calculate_checksum!)

      described_class.new.perform('package_file', package_file.id)
    end

    context 'when on a primary node' do
      before do
        stub_primary_node
      end

      it 'calculates the checksum' do
        expect { described_class.new.perform('package_file', package_file.id) }
          .to change { package_file.reload.verification_checksum }.from(nil)
      end
    end
  end
end
