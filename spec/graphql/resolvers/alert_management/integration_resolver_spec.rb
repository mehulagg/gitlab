# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::AlertManagement::IntegrationResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:prometheus_integration) { create(:prometheus_service, project: project) }
  let_it_be(:active_http_integration) { create(:alert_management_http_integration, project: project) }
  let_it_be(:inactive_http_integration) { create(:alert_management_http_integration, :inactive, project: project) }
  let_it_be(:other_proj_integration) { create(:alert_management_http_integration) }

  let(:args) { {} }

  subject { sync(resolve_http_integrations(args)) }

  context 'user does not have permission' do
    it { is_expected.to be_empty }
  end

  context 'user has permission' do
    before do
      project.add_maintainer(current_user)
    end

    it { is_expected.to contain_exactly(active_http_integration, prometheus_integration) }

    context 'with id' do
      context 'for PrometheusService' do
        let(:args) { { id: GitlabSchema.id_from_object(prometheus_integration) } }

        it { is_expected.to contain_exactly(prometheus_integration) }
      end

      context 'for HttpIntegration' do
        let(:args) { { id: GitlabSchema.id_from_object(active_http_integration) } }

        it { is_expected.to contain_exactly(active_http_integration) }
      end

      context 'for non-integration object' do
        let(:args) { { id: GitlabSchema.id_from_object(project) } }

        it { is_expected.to be_empty }
      end

      context 'with integration from another project' do
        let(:args) { { id: GitlabSchema.id_from_object(other_proj_integration) } }

        it { is_expected.to be_empty }
      end
    end
  end

  private

  def resolve_http_integrations(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
