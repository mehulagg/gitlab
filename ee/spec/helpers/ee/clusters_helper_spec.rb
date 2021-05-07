# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ClustersHelper do
  describe '#display_cluster_agents?' do
    let(:clusterable) { build(:project) }

    subject { helper.display_cluster_agents?(clusterable) }

    context 'without premium license' do
      it 'does not allows agents to display' do
        expect(subject).to be_falsey
      end
    end

    context 'with premium license' do
      before do
        allow(Gitlab).to receive(:com?).and_return(false)

        stub_licensed_features(cluster_agents: true)
      end

      context 'when clusterable is a project' do
        it 'allows agents to display' do
          expect(subject).to be_truthy
        end
      end

      context 'when clusterable is a group' do
        let(:clusterable) { build(:group) }

        it 'does not allows agents to display' do
          expect(subject).to be_falsey
        end
      end

      context 'GitLab.com' do
        before do
          allow(Gitlab).to receive(:com?).and_return(true)
        end

        context 'when kubernetes_agent_on_gitlab_com feature flag is disabled' do
          before do
            stub_feature_flags(kubernetes_agent_on_gitlab_com: false)
          end

          it 'does not allows agents to display' do
            expect(subject).to be_falsey
          end
        end

        context 'kubernetes_agent_on_gitlab_com feature flag enabled' do
          before do
            stub_feature_flags(kubernetes_agent_on_gitlab_com: clusterable)
          end

          it 'allows agents to display' do
            expect(subject).to be_truthy
          end
        end
      end
    end
  end
end
