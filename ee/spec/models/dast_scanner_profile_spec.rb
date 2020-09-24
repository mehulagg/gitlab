# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastScannerProfile, type: :model do
  subject { create(:dast_scanner_profile) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }
    it { is_expected.to validate_presence_of(:project_id) }
  end

  describe 'scopes' do
    describe '.project_id_in' do
      it 'returns the dast_scanner_profiles for given projects' do
        result = DastScannerProfile.project_id_in([subject.project.id])
        expect(result).to eq([subject])
      end
    end
  end
end
