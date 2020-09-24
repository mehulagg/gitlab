# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::BlobVerificationPrimaryWorker, :geo do
  let(:package_file) { create(:conan_package_file, :conan_recipe_file) }

  describe '#perform' do
    it 'calculates the checksum' do
      expect { described_class.new.perform('package_file', package_file.id) }
        .to change { package_file.reload.verification_checksum }.from(nil)
    end
  end
end
