# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::SecurityOrchestrationPolicies::ProcessPolicyService do
  describe '#execute' do
    let_it_be(:policy_configuration) { create(:security_orchestration_policy_configuration) }

    let(:policy) do
      <<-EOS
          name: Run DAST in every pipeline
          description: This policy enforces to run DAST for every pipeline within the project
          enabled: false
          rules:
          - type: pipeline
            branches:
            - "production"
          actions:
          - scan: dast
            site_profile: Site Profile
            scanner_profile: Scanner Profile
      EOS
    end

    let(:repository_with_existing_policy_yaml) do
      <<-EOS
        scan_execution_policy:
        - name: Run DAST in every pipeline
          description: This policy enforces to run DAST for every pipeline within the project
          enabled: true
          rules:
          - type: pipeline
            branches:
            - "production"
          actions:
          - scan: dast
            site_profile: Site Profile
            scanner_profile: Scanner Profile
        - name: Scheduled DAST
          description: This policy executes DAST in a scheduled pipeline
          enabled: true
          rules:
          - type: schedule
            branches:
            - "production"
            cadence: '*/15 * * * *'
          actions:
          - scan: dast
            site_profile: Site Profile
            scanner_profile: Scanner Profile
      EOS
    end

    let(:repository_policy_yaml) do
      <<-EOS
        scan_execution_policy:
        - name: Execute DAST in every pipeline
          description: This policy enforces to run DAST for every pipeline within the project
          enabled: true
          rules:
          - type: pipeline
            branches:
            - "production"
          actions:
          - scan: dast
            site_profile: Site Profile
            scanner_profile: Scanner Profile
        - name: Scheduled DAST
          description: This policy executes DAST in a scheduled pipeline
          enabled: true
          rules:
          - type: schedule
            branches:
            - "production"
            cadence: '*/15 * * * *'
          actions:
          - scan: dast
            site_profile: Site Profile
            scanner_profile: Scanner Profile
      EOS
    end

    let(:policy_yaml) { Gitlab::Config::Loader::Yaml.new(policy).load! }
    let(:type) { :scan_execution_policy }
    let(:operation) { :append }

    subject(:service) { described_class.new(policy_configuration: policy_configuration, params: { policy: policy_yaml, operation: operation, type: type }) }

    context 'when policy is invalid' do
      let(:policy) do
        <<-EOS
          invalid_name: invalid
        EOS
      end

      it 'raises StandardError' do
        expect { service.execute }.to raise_error(StandardError, 'Invalid policy yaml')
      end
    end

    context 'when type is invalid' do
      let(:type) { :invalid_type}

      it 'raises StandardError' do
        expect { service.execute }.to raise_error(StandardError, 'Invalid policy type')
      end
    end

    context 'append policy' do
      context 'when policy is present in repository' do
        before do
          allow(policy_configuration).to receive(:policy_hash).and_return(Gitlab::Config::Loader::Yaml.new(repository_policy_yaml).load!)
        end

        it 'appends the new policy' do
          result = service.execute

          expect(result[:scan_execution_policy].count).to eq(3)
        end
      end

      context 'when policy with same name already exists in repository' do
        before do
          allow(policy_configuration).to receive(:policy_hash).and_return(Gitlab::Config::Loader::Yaml.new(repository_with_existing_policy_yaml).load!)
        end

        it 'raises StandardError' do
          expect { service.execute }.to raise_error(StandardError, 'Policy already exists with same name')
        end
      end

      context 'when policy is not present in repository' do
        before do
          allow(policy_configuration).to receive(:policy_hash).and_return(nil)
        end

        it 'appends the new policy' do
          result = service.execute

          expect(result[:scan_execution_policy].count).to eq(1)
        end
      end
    end

    context 'replace policy' do
      let(:operation) { :replace }

      context 'when policy is not present in repository' do
        before do
          allow(policy_configuration).to receive(:policy_hash).and_return(Gitlab::Config::Loader::Yaml.new(repository_policy_yaml).load!)
        end

        it 'raises StandardError' do
          expect { service.execute }.to raise_error(StandardError, 'Policy does not exist')
        end
      end

      context 'when policy with same name already exists in repository' do
        before do
          allow(policy_configuration).to receive(:policy_hash).and_return(Gitlab::Config::Loader::Yaml.new(repository_with_existing_policy_yaml).load!)
        end

        it 'replaces the policy' do
          result = service.execute

          expect(result[:scan_execution_policy].first[:enabled]).to be_falsey
        end
      end
    end

    context 'remove policy' do
      let(:operation) { :remove }

      context 'when policy is not present in repository' do
        before do
          allow(policy_configuration).to receive(:policy_hash).and_return(Gitlab::Config::Loader::Yaml.new(repository_policy_yaml).load!)
        end

        it 'raises StandardError' do
          expect { service.execute }.to raise_error(StandardError, 'Policy does not exist')
        end
      end

      context 'when policy with same name already exists in repository' do
        before do
          allow(policy_configuration).to receive(:policy_hash).and_return(Gitlab::Config::Loader::Yaml.new(repository_with_existing_policy_yaml).load!)
        end

        it 'removes the policy' do
          result = service.execute

          expect(result[:scan_execution_policy].count).to eq(1)
        end
      end
    end
  end
end
