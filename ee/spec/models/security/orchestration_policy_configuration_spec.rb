# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::OrchestrationPolicyConfiguration do
  let_it_be(:security_policy_management_project) { create(:project, :repository) }
  let_it_be(:security_orchestration_policy_configuration) do
    create( :security_orchestration_policy_configuration, security_policy_management_project: security_policy_management_project)
  end

  let(:default_branch) { security_policy_management_project.default_branch_or_master }
  let(:repository) { instance_double(Repository, root_ref: 'master') }

  describe 'associations' do
    it { is_expected.to belong_to(:project).inverse_of(:security_orchestration_policy_configuration) }
    it { is_expected.to belong_to(:security_policy_management_project).class_name('Project') }
  end

  describe 'validations' do
    subject { create(:security_orchestration_policy_configuration) }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:security_policy_management_project) }

    it { is_expected.to validate_uniqueness_of(:project) }
  end

  describe '#enabled?' do
    subject { security_orchestration_policy_configuration.enabled? }

    context 'when feature is enabled' do
      before do
        stub_feature_flags(security_orchestration_policies_configuration: true)
      end

      it { is_expected.to eq(true) }
    end

    context 'when feature is disabled' do
      before do
        stub_feature_flags(security_orchestration_policies_configuration: false)
      end

      it { is_expected.to eq(false) }
    end
  end

  describe '#active_policies' do
    let(:enforce_dast_yaml) do
      <<-EOS
      type: scan_execution_policy
      name: Run DAST in every pipeline
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
      EOS
    end

    let(:policy_yaml) { fixture_file('security_orchestration.yml', dir: 'ee') }

    let(:expected_active_policies) do
      [
        {
          name: 'Run DAST in every pipeline',
          description: 'This policy enforces to run DAST for every pipeline within the project',
          enabled: true,
          rules: [{ type: 'pipeline', branches: %w[production] }],
          actions: [
            { scan: 'dast', site_profile: 'Site Profile', scanner_profile: 'Scanner Profile' }
          ]
        },
        {
          name: 'Run DAST in every pipeline_v1',
          description: 'This policy enforces to run DAST for every pipeline within the project',
          enabled: true,
          rules: [{ type: 'pipeline', branches: %w[master] }],
          actions: [
            { scan: 'dast', site_profile: 'Site Profile', scanner_profile: 'Scanner Profile' }
          ]
        },
        {
          name: 'Run DAST in every pipeline_v3',
          description: 'This policy enforces to run DAST for every pipeline within the project',
          enabled: true,
          rules: [{ type: 'pipeline', branches: %w[master] }],
          actions: [
            { scan: 'dast', site_profile: 'Site Profile', scanner_profile: 'Scanner Profile' }
          ]
        },
        {
          name: 'Run DAST in every pipeline_v4',
          description: 'This policy enforces to run DAST for every pipeline within the project',
          enabled: true,
          rules: [{ type: 'pipeline', branches: %w[master] }],
          actions: [
            { scan: 'dast', site_profile: 'Site Profile', scanner_profile: 'Scanner Profile' }
          ]
        },
        {
          name: 'Run DAST in every pipeline_v5',
          description: 'This policy enforces to run DAST for every pipeline within the project',
          enabled: true,
          rules: [{ type: 'pipeline', branches: %w[master] }],
          actions: [
            { scan: 'dast', site_profile: 'Site Profile', scanner_profile: 'Scanner Profile' }
          ]
        }
      ]
    end

    subject(:active_policies) { security_orchestration_policy_configuration.active_policies }

    before do
      allow(security_policy_management_project).to receive(:repository).and_return(repository)
      allow(repository).to receive(:blob_data_at).with( default_branch, Security::OrchestrationPolicyConfiguration::POLICY_PATH).and_return(policy_yaml)
    end

    it 'returns only enabled policies' do
      expect(active_policies).to eq(expected_active_policies)
    end

    context 'when feature is disabled' do
      before do
        stub_feature_flags(security_orchestration_policies_configuration: false)
      end

      it 'returns empty array' do
        expect(active_policies).to eq([])
      end
    end
  end

  describe '#on_demand_scan_actions' do
    let(:policy_yaml) do
      <<-EOS
      scan_execution_policy:
        - name: Run DAST in every pipeline
          enabled: true
          rules:
          - type: pipeline
            branches:
            - "production"
          actions:
          - scan: dast
            site_profile: Site Profile
            scanner_profile: Scanner Profile
        - name: Run DAST in every pipeline
          enabled: true
          rules:
          - type: pipeline
            branches:
            - "release/*"
          actions:
          - scan: dast
            site_profile: Site Profile 2
            scanner_profile: Scanner Profile 2
        - name: Run DAST in every pipeline
          enabled: true
          rules:
          - type: pipeline
            branches:
            - "*"
          actions:
          - scan: dast
            site_profile: Site Profile 3
            scanner_profile: Scanner Profile 3
        - name: Run SAST in every pipeline
          enabled: true
          rules:
          - type: pipeline
            branches:
            - "release/*"
          actions:
          - scan: sast
      EOS
    end

    let(:expected_actions) do
      [
        { scan: 'dast', scanner_profile: 'Scanner Profile 2', site_profile: 'Site Profile 2' },
        { scan: 'dast', scanner_profile: 'Scanner Profile 3', site_profile: 'Site Profile 3' }
      ]
    end

    subject(:on_demand_scan_actions) do
      security_orchestration_policy_configuration.on_demand_scan_actions('release/123')
    end

    before do
      allow(security_policy_management_project).to receive(:repository).and_return(repository)
      allow(repository).to receive(:blob_data_at).with(default_branch, Security::OrchestrationPolicyConfiguration::POLICY_PATH).and_return(policy_yaml)
    end

    it 'returns only actions for on-demand scans applicable for branch' do
      expect(on_demand_scan_actions).to eq(expected_actions)
    end
  end

  describe '#active_policy_names_with_dast_site_profile' do
    let(:policy_yaml) do
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
          - scan: dast
            site_profile: Site Profile
            scanner_profile: Scanner Profile 2
      EOS
    end

    before do
      allow(security_policy_management_project).to receive(:repository).and_return(repository)
      allow(repository).to receive(:blob_data_at).with(default_branch, Security::OrchestrationPolicyConfiguration::POLICY_PATH).and_return(policy_yaml)
    end

    it 'returns list of policy names where site profile is referenced' do
      expect( security_orchestration_policy_configuration.active_policy_names_with_dast_site_profile('Site Profile')).to contain_exactly('Run DAST in every pipeline')
    end
  end

  describe '#active_policy_names_with_dast_scanner_profile' do
    let(:enforce_dast_yaml) do
      <<-EOS
      scan_execution_policy:
           type: scan_execution_policy
        -  name: Run DAST in every pipeline
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
           - scan: dast
             site_profile: Site Profile 2
             scanner_profile: Scanner Profile
      EOS
    end

    before do
      allow(security_policy_management_project).to receive(:repository).and_return(repository)
      allow(repository).to receive(:blob_data_at).with(default_branch, Security::OrchestrationPolicyConfiguration::POLICY_PATH).and_return(enforce_dast_yaml)
    end

    it 'returns list of policy names where site profile is referenced' do
      expect(security_orchestration_policy_configuration.active_policy_names_with_dast_scanner_profile('Scanner Profile')).to contain_exactly('Run DAST in every pipeline')
    end
  end
end
