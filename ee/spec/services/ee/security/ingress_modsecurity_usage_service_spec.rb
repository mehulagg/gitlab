# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Security::IngressModsecurityUsageService do
  describe '#execute' do
    let(:environment) { create(:environment) }
    let(:ingress_mode) { :modsecurity_blocking }
    let(:deployments) { [] }
    let!(:cluster) { create(:cluster, deployments: deployments) }
    let!(:ingress) { create(:clusters_applications_ingress, ingress_mode, cluster: cluster) }
    let!(:elastic_stack) { create(:clusters_applications_elastic_stack, :installed, cluster: cluster) }

    subject { described_class.new.execute }

    before do
      allow_any_instance_of(::Security::WafAnomalySummaryService).to receive(:execute)
    end

    context 'when cluster is disabled' do
      let(:cluster) { create(:cluster, :disabled, deployments: deployments) }

      it 'gathers ingress data' do
        expect(subject[:statistics_unavailable]).to eq(0)
        expect(subject[:packets_processed]).to eq(0)
        expect(subject[:packets_anomalous]).to eq(0)
      end
    end

    context 'when environment is not available' do
      let(:environment) { create(:environment, state: :stopped) }

      it 'gathers ingress data' do
        expect(subject[:statistics_unavailable]).to eq(0)
        expect(subject[:packets_processed]).to eq(0)
        expect(subject[:packets_anomalous]).to eq(0)
      end
    end

    context 'when environment is available' do
      context 'when deployment is unsuccessful' do
        let(:deployments) { [deployment] }
        let!(:deployment) { create(:deployment, :failed, environment: environment) }

        it 'gathers ingress data' do
          expect(subject[:statistics_unavailable]).to eq(0)
          expect(subject[:packets_processed]).to eq(0)
          expect(subject[:packets_anomalous]).to eq(0)
        end
      end

      context 'when deployment is successful' do
        let(:deployments) { [deployment] }
        let!(:deployment) { create(:deployment, :success, environment: environment) }
        let(:waf_anomaly_summary) { { total_traffic: 1000, total_anomalous_traffic: 200 } }

        before do
          allow_any_instance_of(::Security::WafAnomalySummaryService).to receive(:execute).and_return(waf_anomaly_summary)
          allow(::Gitlab::ErrorTracking).to receive(:track_exception)
        end

        context 'when modsecurity statistics are available' do
          it 'gathers ingress data' do
            expect(subject[:statistics_unavailable]).to eq(0)
            expect(subject[:packets_processed]).to eq(1000)
            expect(subject[:packets_anomalous]).to eq(200)
          end
        end

        context 'when modsecurity statistics are not available' do
          let(:waf_anomaly_summary) { nil }

          it 'gathers ingress data' do
            expect(subject[:statistics_unavailable]).to eq(1)
            expect(subject[:packets_processed]).to eq(0)
            expect(subject[:packets_anomalous]).to eq(0)
          end
        end

        context 'when modsecurity statistics process is raising exception' do
          before do
            allow_any_instance_of(::Security::WafAnomalySummaryService).to receive(:execute).and_raise(StandardError)
          end

          it 'gathers ingress data' do
            expect(subject[:statistics_unavailable]).to eq(1)
            expect(subject[:packets_processed]).to eq(0)
            expect(subject[:packets_anomalous]).to eq(0)
          end

          it 'tracks exception' do
            expect(::Gitlab::ErrorTracking).to receive(:track_exception).with(StandardError, environment_id: environment.id, cluster_id: cluster.id)
            subject
          end
        end

        context 'with multiple environments' do
          let!(:environment_2) { create(:environment) }
          let!(:cluster_2) { create(:cluster, deployments: [deployment_2]) }
          let!(:deployment_2) { create(:deployment, :success, environment: environment_2) }

          let!(:ingress_2) { create(:clusters_applications_ingress, ingress_mode, cluster: cluster_2) }
          let!(:elastic_stack_2) { create(:clusters_applications_elastic_stack, :installed, cluster: cluster_2) }

          it 'gathers ingress data from multiple environments' do
            expect(subject[:statistics_unavailable]).to eq(0)
            expect(subject[:packets_processed]).to eq(2000)
            expect(subject[:packets_anomalous]).to eq(400)
          end
        end
      end
    end
  end
end
