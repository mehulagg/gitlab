# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::OrchestrationPolicyConfiguration do
  let_it_be(:security_policy_management_project) { create(:project, :repository) }
  let_it_be(:security_orchestration_policy_configuration) { create(:security_orchestration_policy_configuration, security_policy_management_project: security_policy_management_project) }

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

    let(:disabled_policy_yaml) do
      <<-EOS
      type: scan_execution_policy
      name: Disabled policy
      description: This policy is disabled
      enabled: false
      rules: []
      actions: []
      EOS
    end

    let(:expected_active_policies) do
      [
        {
          type: 'scan_execution_policy',
          name: 'Run DAST in every pipeline',
          description: 'This policy enforces to run DAST for every pipeline within the project',
          enabled: true,
          rules: [{ type: 'pipeline', branches: ['production'] }],
          actions: [{ scan: 'dast', site_profile: 'Site Profile', scanner_profile: 'Scanner Profile' }]
        }
      ]
    end

    subject(:active_policies) { security_orchestration_policy_configuration.active_policies }

    before do
      allow(security_policy_management_project).to receive(:repository).and_return(repository)
      allow(repository).to receive(:ls_files).and_return(['README.md', '.gitlab/security-policies/enforce-dast.yml', '.gitlab/security-policies/disabled-policy.yml', '.gitlab-ci.yml'])
      allow(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/enforce-dast.yml').and_return(enforce_dast_yaml)
      allow(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/disabled-policy.yml').and_return(disabled_policy_yaml)
    end

    it 'reads yml file from repository' do
      expect(repository).to receive(:ls_files).with(default_branch)
      expect(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/enforce-dast.yml')
      expect(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/disabled-policy.yml')

      active_policies
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
    let(:policy_1_yaml) do
      <<-EOS
      type: scan_execution_policy
      name: Run DAST in every pipeline
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

    let(:policy_2_yaml) do
      <<-EOS
      type: scan_execution_policy
      name: Run DAST in every pipeline
      enabled: true
      rules:
      - type: pipeline
        branches:
        - "release/*"
      actions:
      - scan: dast
        site_profile: Site Profile 2
        scanner_profile: Scanner Profile 2
      EOS
    end

    let(:policy_3_yaml) do
      <<-EOS
      type: scan_execution_policy
      name: Run DAST in every pipeline
      enabled: true
      rules:
      - type: pipeline
        branches:
        - "*"
      actions:
      - scan: dast
        site_profile: Site Profile 3
        scanner_profile: Scanner Profile 3
      EOS
    end

    let(:policy_4_yaml) do
      <<-EOS
      type: scan_execution_policy
      name: Run SAST in every pipeline
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

    subject(:on_demand_scan_actions) { security_orchestration_policy_configuration.on_demand_scan_actions('release/123') }

    before do
      allow(security_policy_management_project).to receive(:repository).and_return(repository)
      allow(repository).to receive(:ls_files).and_return(['.gitlab/security-policies/policy-1.yml', '.gitlab/security-policies/policy-2.yml', '.gitlab/security-policies/policy-3.yml', '.gitlab/security-policies/policy-4.yml'])
      allow(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/policy-1.yml').and_return(policy_1_yaml)
      allow(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/policy-2.yml').and_return(policy_2_yaml)
      allow(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/policy-3.yml').and_return(policy_3_yaml)
      allow(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/policy-4.yml').and_return(policy_4_yaml)
    end

    it 'returns only actions for on-demand scans applicable for branch' do
      expect(on_demand_scan_actions).to eq(expected_actions)
    end
  end

  describe '#active_policy_names_with_dast_site_profile' do
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
      - scan: dast
        site_profile: Site Profile
        scanner_profile: Scanner Profile 2
      EOS
    end

    before do
      allow(security_policy_management_project).to receive(:repository).and_return(repository)
      allow(repository).to receive(:ls_files).and_return(['.gitlab/security-policies/enforce-dast.yml'])
      allow(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/enforce-dast.yml').and_return(enforce_dast_yaml)
    end

    it 'returns list of policy names where site profile is referenced' do
      expect(security_orchestration_policy_configuration.active_policy_names_with_dast_site_profile('Site Profile')).to contain_exactly('Run DAST in every pipeline')
    end
  end

  describe '#active_policy_names_with_dast_scanner_profile' do
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
      - scan: dast
        site_profile: Site Profile 2
        scanner_profile: Scanner Profile
      EOS
    end

    before do
      allow(security_policy_management_project).to receive(:repository).and_return(repository)
      allow(repository).to receive(:ls_files).and_return(['.gitlab/security-policies/enforce-dast.yml'])
      allow(repository).to receive(:blob_data_at).with(default_branch, '.gitlab/security-policies/enforce-dast.yml').and_return(enforce_dast_yaml)
    end

    it 'returns list of policy names where site profile is referenced' do
      expect(security_orchestration_policy_configuration.active_policy_names_with_dast_scanner_profile('Scanner Profile')).to contain_exactly('Run DAST in every pipeline')
    end
  end
end
