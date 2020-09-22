# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupImportData, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:group).required }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:api_url).is_at_most(255) }
    it { is_expected.to validate_length_of(:access_token).is_at_most(255) }
  end
end
