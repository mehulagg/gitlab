# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LicenseScanningReportDependencyEntity do
  include LicenseScanningReportHelper

  let(:dependency) { create_dependency }
  let(:entity) { described_class.new(dependency) }

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains the correct dependency name' do
      expect(subject[:name]).to eq('Dependency1')
    end
  end
end
