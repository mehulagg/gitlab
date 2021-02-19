# frozen_string_literal: true

# require_relative 'danger_spec_helper'
require_relative '../../../tooling/danger/product_intelligence_helper'

RSpec.describe Tooling::Danger::ProductIntelligenceHelper do
  describe '.determine_changed_files' do
    it 'does something' do
      described_class.determine_changed_files([])
    end
  end
end
