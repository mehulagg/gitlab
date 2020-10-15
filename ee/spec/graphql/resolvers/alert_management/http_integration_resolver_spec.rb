# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::AlertManagement::HttpIntegrationResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:active_integration) { create(:alert_management_http_integration, project: project) }
  let_it_be(:inactive_integration) { create(:alert_management_http_integration, :inactive, project: project) }
  let_it_be(:alert_other_proj) { create(:alert_management_http_integration) }

  let(:args) { {} }

  subject { resolve_http_integrations(args) }

  before do
    stub_licensed_features(multiple_alert_http_integrations: true)
  end

  context 'user does not have permission' do
    it { is_expected.to eq(AlertManagement::HttpIntegration.none) }
  end

  context 'user has permission' do
    before do
      project.add_maintainer(current_user)
    end

    it { is_expected.to contain_exactly(active_integration, inactive_integration) }

    context 'finding by id' do
      let(:args) { { id: inactive_integration.id } }

      it { is_expected.to contain_exactly(inactive_integration) }
    end
  end

  private

  def resolve_http_integrations(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
