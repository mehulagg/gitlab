# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ErrorTracking::ClientKey, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:public_key) }
  end
end
