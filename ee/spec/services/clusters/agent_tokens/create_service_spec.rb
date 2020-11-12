# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clusters::AgentTokens::CreateService do
  subject(:service) { described_class.new(container: project, current_user: user) }

  let_it_be(:user) { create(:user) }
  let(:cluster_agent) { create(:cluster_agent) }
  let(:project) { cluster_agent.project }

  before do
    stub_licensed_features(cluster_agents: false)
  end

  describe '#execute' do
    context 'without premium plan' do
      it 'does not create a new token' do
        expect { service.execute(cluster_agent) }.not_to change(Clusters::AgentToken, :count)
      end

      it 'returns missing license error' do
        result = service.execute(cluster_agent)

        expect(result.status).to eq(:error)
        expect(result.message).to eq('This feature is only available for premium plans')
      end

      context 'with premium plan' do
        before do
          stub_licensed_features(cluster_agents: true)
        end

        it 'does not create a new token due to user permissions' do
          expect { service.execute(cluster_agent) }.not_to change(::Clusters::AgentToken, :count)
        end

        it 'returns permission errors', :aggregate_failures do
          result = service.execute(cluster_agent)

          expect(result.status).to eq(:error)
          expect(result.message).to eq('User has insufficient permissions to create a token for this project')
        end

        context 'with user permissions' do
          before do
            project.add_maintainer(user)
          end

          it 'creates a new token' do
            expect { service.execute(cluster_agent) }.to change { ::Clusters::AgentToken.count }.by(1)
          end

          it 'returns success status', :aggregate_failures do
            result = service.execute(cluster_agent)

            expect(result.status).to eq(:success)
            expect(result.payload[:secret]).not_to be_nil
          end
        end
      end
    end
  end
end
