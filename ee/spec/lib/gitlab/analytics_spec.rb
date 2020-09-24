# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics do
  describe '.productivity_analytics_enabled?' do
    it 'is enabled by default' do
      expect(described_class).to be_productivity_analytics_enabled
    end
  end
end
