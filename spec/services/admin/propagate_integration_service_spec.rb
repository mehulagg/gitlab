# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::PropagateIntegrationService do
  describe '.propagate' do
    include JiraServiceHelper

    before do
      stub_jira_service_test
    end

    let_it_be(:project) { create(:project) }
    let(:excluded_attributes) { %w[id project_id group_id inherit_from_id instance template created_at updated_at] }
    let!(:instance_integration) do
      JiraService.create!(
        instance: true,
        active: true,
        push_events: true,
        url: 'http://update-jira.instance.com',
        username: 'user',
        password: 'secret'
      )
    end

    let!(:inherited_integration) do
      JiraService.create!(
        project: create(:project),
        inherit_from_id: instance_integration.id,
        instance: false,
        active: true,
        push_events: false,
        url: 'http://jira.instance.com',
        username: 'user',
        password: 'secret'
      )
    end

    let!(:not_inherited_integration) do
      JiraService.create!(
        project: project,
        inherit_from_id: nil,
        instance: false,
        active: true,
        push_events: false,
        url: 'http://jira.instance.com',
        username: 'user',
        password: 'secret'
      )
    end

    let!(:different_type_inherited_integration) do
      BambooService.create!(
        project: project,
        inherit_from_id: instance_integration.id,
        instance: false,
        active: true,
        push_events: false,
        bamboo_url: 'http://gitlab.com',
        username: 'mic',
        password: 'password',
        build_key: 'build'
      )
    end

    context 'with inherited integration' do
      let(:integration) { inherited_integration }

      it 'updates the integration' do
        described_class.propagate(instance_integration)

        expect(integration.reload.inherit_from_id).to eq(instance_integration.id)
        expect(integration.attributes.except(*excluded_attributes))
          .to eq(instance_integration.attributes.except(*excluded_attributes))
      end

      context 'with integration with data fields' do
        let(:excluded_attributes) { %w[id service_id created_at updated_at] }

        it 'updates the data fields from the integration' do
          described_class.propagate(instance_integration)

          expect(integration.reload.data_fields.attributes.except(*excluded_attributes))
            .to eq(instance_integration.data_fields.attributes.except(*excluded_attributes))
        end
      end
    end

    context 'with not inherited integration' do
      let(:integration) { not_inherited_integration }

      it 'does not update the integration' do
        expect { described_class.propagate(instance_integration) }
          .not_to change { instance_integration.attributes.except(*excluded_attributes) }
      end
    end

    context 'with different type inherited integration' do
      let(:integration) { different_type_inherited_integration }

      it 'does not update the integration' do
        expect { described_class.propagate(instance_integration) }
          .not_to change { instance_integration.attributes.except(*excluded_attributes) }
      end
    end

    context 'with a project without integration' do
      let!(:another_project) { create(:project) }

      it 'calls to PropagateIntegrationProjectWorker' do
        expect(PropagateIntegrationProjectWorker).to receive(:perform_async)
          .with(instance_integration.id, another_project.id, another_project.id)

        described_class.propagate(instance_integration)
      end
    end

    context 'with a group without integration' do
      let!(:group) { create(:group) }

      it 'calls to PropagateIntegrationProjectWorker' do
        expect(PropagateIntegrationGroupWorker).to receive(:perform_async)
          .with(instance_integration.id, group.id, group.id)

        described_class.propagate(instance_integration)
      end
    end
  end
end
