# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteProfile, type: :model do
  subject { create(:dast_site_profile, :with_dast_site_validation) }

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
    it { is_expected.to validate_presence_of(:name) }

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

    describe '.with_name' do
      it 'returns the dast_site_profiles with given name' do
        result = DastSiteProfile.with_name(subject.name)
        expect(result).to eq([subject])
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
      it 'is none' do
        subject.dast_site.update!(dast_site_validation_id: nil)

        aggregate_failures do
          expect(subject.dast_site_validation).to be_nil
          expect(subject.status).to eq('none')
        end
      end
    end

    context 'when dast_site_validation association does exist' do
      it 'is dast_site_validation#state' do
        expect(subject.status).to eq(subject.dast_site_validation.state)
      end
    end
  end

  describe '#referenced_in_security_policies' do
    context 'there is no security_orchestration_policy_configuration assigned to project' do
      it 'returns empty array' do
        expect(subject.referenced_in_security_policies).to eq([])
      end
    end

    context 'there is security_orchestration_policy_configuration assigned to project' do
      let(:security_orchestration_policy_configuration) { instance_double(Security::OrchestrationPolicyConfiguration, present?: true, active_policy_names_with_dast_site_profile: ['Policy Name']) }

      before do
        allow(subject.project).to receive(:security_orchestration_policy_configuration).and_return(security_orchestration_policy_configuration)
      end

      it 'calls security_orchestration_policy_configuration.active_policy_names_with_dast_site_profile with profile name' do
        expect(security_orchestration_policy_configuration).to receive(:active_policy_names_with_dast_site_profile).with(subject.name)

        subject.referenced_in_security_policies
      end

      it 'returns the referenced policy name' do
        expect(subject.referenced_in_security_policies).to eq(['Policy Name'])
      end
    end
  end
end
