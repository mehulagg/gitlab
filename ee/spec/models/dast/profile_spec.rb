# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::Profile, type: :model do
  subject { create(:dast_profile) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:dast_site_profile) }
    it { is_expected.to belong_to(:dast_scanner_profile) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:description).is_at_most(255) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }
    it { is_expected.to validate_presence_of(:project_id) }
    it { is_expected.to validate_presence_of(:dast_site_profile_id) }
    it { is_expected.to validate_presence_of(:dast_scanner_profile_id) }

    context 'when the project_id and dast_site_profile.project_id do not match' do
      let(:project) { create(:project) }
      let(:dast_site_profile) { create(:dast_site_profile) }

      subject { build(:dast_profile, project: project, dast_site_profile: dast_site_profile) }

      it 'is not valid' do
        aggregate_failures do
          expect(subject.valid?).to be_falsey
          expect(subject.errors.full_messages).to include('Project must match dast_site_profile.project_id')
        end
      end
    end

    context 'when the project_id and dast_scanner_profile.project_id do not match' do
      let(:project) { create(:project) }
      let(:dast_scanner_profile) { create(:dast_scanner_profile) }

      subject { build(:dast_profile, project: project, dast_scanner_profile: dast_scanner_profile) }

      it 'is not valid' do
        aggregate_failures do
          expect(subject.valid?).to be_falsey
          expect(subject.errors.full_messages).to include('Project must match dast_scanner_profile.project_id')
        end
      end
    end
  end
end
