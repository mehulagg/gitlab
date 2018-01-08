require 'rails_helper'

describe EE::DeploymentPlatform do
  describe '#deployment_platform' do
    let(:project) { create(:project) }

    context 'when environment is specified' do
      let(:environment) { create(:environment, project: project, name: 'review/name') }
      let!(:default_cluster) { create(:cluster, :provided_by_user, projects: [project], environment_scope: '*') }
      let!(:cluster) { create(:cluster, :provided_by_user, environment_scope: 'review/*', projects: [project]) }

      subject { project.deployment_platform(environment: environment) }

      shared_examples 'matching environment scope' do
        context 'when multiple clusters is available' do
          before do
            stub_licensed_features(multiple_clusters: true)
          end

          it 'returns environment specific cluster' do
            is_expected.to eq(cluster.platform_kubernetes)
          end
        end

        context 'when multiple clusters is unavailable' do
          before do
            stub_licensed_features(multiple_clusters: false)
          end

          it 'returns a kubernetes platform' do
            is_expected.to be_kind_of(Clusters::Platforms::Kubernetes)
          end
        end
      end

      shared_examples 'not matching environment scope' do
        context 'when multiple clusters is available' do
          before do
            stub_licensed_features(multiple_clusters: true)
          end

          it 'returns default cluster' do
            is_expected.to eq(default_cluster.platform_kubernetes)
          end
        end

        context 'when multiple clusters is unavailable' do
          before do
            stub_licensed_features(multiple_clusters: false)
          end

          it 'returns a kubernetes platform' do
            is_expected.to be_kind_of(Clusters::Platforms::Kubernetes)
          end
        end
      end

      context 'when environment scope is exactly matched' do
        before do
          cluster.update!(environment_scope: 'review/name')
        end

        it_behaves_like 'matching environment scope'
      end

      context 'when environment scope is matched by wildcard' do
        before do
          cluster.update!(environment_scope: 'review/*')
        end

        it_behaves_like 'matching environment scope'
      end

      context 'when environment scope does not match' do
        before do
          cluster.update!(environment_scope: 'review/*/special')
        end

        it_behaves_like 'not matching environment scope'
      end

      context 'when environment scope has _' do
        before do
          stub_licensed_features(multiple_clusters: true)
        end

        it 'does not treat it as wildcard' do
          cluster.update!(environment_scope: 'foo_bar/*')

          is_expected.to eq(default_cluster.platform_kubernetes)
        end

        it 'matches literally for _' do
          cluster.update!(environment_scope: 'foo_bar/*')
          environment.update!(name: 'foo_bar/test')

          is_expected.to eq(cluster.platform_kubernetes)
        end
      end

      # The environment name and scope cannot have % at the moment,
      # but we're considering relaxing it and we should also make sure
      # it doesn't break in case some data sneaked in somehow as we're
      # not checking this integrity in database level.
      context 'when environment scope has %' do
        before do
          stub_licensed_features(multiple_clusters: true)
        end

        it 'does not treat it as wildcard' do
          cluster.update_attribute(:environment_scope, '*%*')

          is_expected.to eq(default_cluster.platform_kubernetes)
        end

        it 'matches literally for %' do
          cluster.update_attribute(:environment_scope, 'foo%bar/*')
          environment.update_attribute(:name, 'foo%bar/test')

          is_expected.to eq(cluster.platform_kubernetes)
        end
      end

      context 'when perfectly matched cluster exists' do
        let!(:perfectly_matched_cluster) { create(:cluster, :provided_by_user, projects: [project], environment_scope: 'review/name') }

        before do
          stub_licensed_features(multiple_clusters: true)
        end

        it 'returns perfectly matched cluster as highest precedence' do
          is_expected.to eq(perfectly_matched_cluster.platform_kubernetes)
        end
      end
    end
  end
end
