# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteProfile, type: :model do
  subject { create(:dast_site_profile) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:dast_site) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }
    it { is_expected.to validate_presence_of(:project_id) }
    it { is_expected.to validate_presence_of(:dast_site_id) }

    context 'when the project_id and dast_site.project_id do not match' do
      let(:project) { create(:project) }
      let(:dast_site) { create(:dast_site) }

      subject { build(:dast_site_profile, project: project, dast_site: dast_site) }

      it 'is not valid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.full_messages).to include('Project does not match dast_site.project')
      end
    end
  end

  describe 'scopes' do
    describe '.with_dast_site_and_validation' do
      before do
        subject.dast_site_validation.update!(state: :failed)
      end

      it 'eager loads the association' do
        subject

        recorder = ActiveRecord::QueryRecorder.new do
          subject.dast_site
          subject.dast_site_validation
        end

        aggregate_failures do
          expect(subject.status).to eq('failed') # ensures guard passed
          expect(recorder.count).to be_zero
        end
      end
    end
  end

  describe '#destroy!' do
    context 'when the associated dast_site has no dast_site_profiles' do
      it 'is also destroyed' do
        subject.destroy!

        expect { subject.dast_site.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the associated dast_site has dast_site_profiles' do
      it 'is not destroyed' do
        create(:dast_site_profile, dast_site: subject.dast_site, project: subject.project)

        subject.destroy!

        expect { subject.dast_site.reload }.not_to raise_error
      end
    end
  end

  describe '#status' do
    context 'when dast_site_validation association does not exist' do
      it 'is pending' do
        subject.dast_site.update!(dast_site_validation_id: nil)

        aggregate_failures do
          expect(subject.dast_site_validation).to be_nil
          expect(subject.status).to eq('pending')
        end
      end
    end

    context 'when dast_site_validation association does exist' do
      it 'is dast_site_validation#state' do
        expect(subject.status).to eq(subject.dast_site_validation.state)
      end
    end
  end
end
