# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Orchestration::AssignService do
  let_it_be(:project, reload: true) { create(:project) }
  let_it_be(:another_project) { create(:project) }
  let_it_be(:policy_project) { create(:project) }
  let_it_be(:new_policy_project) { create(:project) }

  describe '#execute' do
    subject(:service) do
      described_class.new(project, nil, policy_project_id: policy_project.id).execute
    end

    before do
      service
    end

    it 'assigns policy project to project' do
      expect(service).to be_success
      expect(
        project.security_orchestration_policy_configuration.security_policy_management_project_id
      ).to eq(policy_project.id)
    end

    it 'updates project with new policy project' do
      repeated_service =
        described_class.new(project, nil, policy_project_id: new_policy_project.id).execute

      expect(repeated_service).to be_success
      expect(
        project.security_orchestration_policy_configuration.security_policy_management_project_id
      ).to eq(new_policy_project.id)
    end

    it 'assigns same policy to different projects' do
      repeated_service =
        described_class.new(another_project, nil, policy_project_id: policy_project.id).execute
      expect(repeated_service).to be_success
    end

    it 'unassigns project' do
      expect { described_class.new(project, nil, policy_project_id: nil).execute }.to change {
        project.reload.security_orchestration_policy_configuration
      }.to(nil)
    end

    it 'returns error when db has problem' do
      dbl_error = double('ActiveRecord')
      dbl =
        double(
          'Security::OrchestrationPolicyConfiguration',
          security_orchestration_policy_configuration: dbl_error
        )

      allow(dbl_error).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)

      allow_next_instance_of(described_class) do |instance|
        allow(instance).to receive(:has_existing_policy?).and_return(true)
        allow(instance).to receive(:project).and_return(dbl)
      end

      repeated_service =
        described_class.new(project, nil, policy_project_id: new_policy_project.id).execute

      expect(repeated_service).to be_error
    end

    describe 'with invalid project id' do
      subject(:service) { described_class.new(project, nil, policy_project_id: 345).execute }

      it 'assigns policy project to project' do
        expect(service).to be_error

        expect { service }.not_to change { project.security_orchestration_policy_configuration }
      end
    end
  end
end
