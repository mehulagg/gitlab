# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::SecurityComplianceMenu do
  let(:project) { build(:project) }
  let(:user) { project.owner }
  let(:show_promotions) { true }
  let(:show_discover_project_security) { true }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project, show_promotions: show_promotions, show_discover_project_security: show_discover_project_security) }

  subject { described_class.new(context) }

  it { is_expected.not_to be_nil }

  # describe '#link' do

  # end

  # describe '#top_level_link' do
  #   context 'when user can read project security dashboard and audit events' do
  #     before do
  #       allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(true)
  #       allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(true)
  #     end

  #     it 'returns security dashboard link' do
  #       is_expected.to eq("/#{project.full_path}/-/security/dashboard") }
  #     end
  #   end

  #   subject { helper.top_level_link(project) }

  #   before do
  #     # allow(helper).to receive(:can?).and_return(false)
  #     # allow(helper).to receive(:can?).with(user, :access_security_and_compliance, project).and_return(true)
  #   end

  #   context 'when user can read project security dashboard and audit events' do
  #     before do
  #       allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(true)
  #       allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(true)
  #     end

  #     it { is_expected.to eq("/#{project.full_path}/-/security/dashboard") }
  #   end

  #   context 'when user can read audit events' do
  #     before do
  #       allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(false)
  #       allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(true)
  #     end

  #     context 'when the feature is enabled' do
  #       before do
  #         stub_licensed_features(audit_events: true)
  #       end

  #       it { is_expected.to eq("/#{project.full_path}/-/audit_events") }
  #     end

  #     context 'when the feature is disabled' do
  #       before do
  #         stub_licensed_features(audit_events: false)
  #       end

  #       it { is_expected.to eq("/#{project.full_path}/-/dependencies") }
  #     end
  #   end

  #   context "when user can't read both project security dashboard and audit events" do
  #     before do
  #       allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(false)
  #       allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(false)
  #     end

  #     it { is_expected.to eq("/#{project.full_path}/-/dependencies") }
  #   end
  # end

  # describe '#sidebar_security_paths' do
  #   let(:expected_security_paths) do
  #     %w[
  #       projects/security/configuration#show
  #       projects/security/sast_configuration#show
  #       projects/security/api_fuzzing_configuration#show
  #       projects/security/vulnerabilities#show
  #       projects/security/vulnerability_report#index
  #       projects/security/dashboard#index
  #       projects/on_demand_scans#index
  #       projects/on_demand_scans#new
  #       projects/on_demand_scans#edit
  #       projects/security/dast_profiles#show
  #       projects/security/dast_site_profiles#new
  #       projects/security/dast_site_profiles#edit
  #       projects/security/dast_scanner_profiles#new
  #       projects/security/dast_scanner_profiles#edit
  #       projects/dependencies#index
  #       projects/licenses#index
  #       projects/threat_monitoring#show
  #       projects/threat_monitoring#new
  #       projects/threat_monitoring#edit
  #       projects/threat_monitoring#alert_details
  #       projects/security/policies#show
  #       projects/audit_events#index
  #     ]
  #   end

  #   subject { helper.sidebar_security_paths }

  #   it { is_expected.to eq(expected_security_paths) }
  # end

  # describe 'Configuration' do
  #   describe '#sidebar_security_configuration_paths' do
  #     let(:expected_security_configuration_paths) do
  #       %w[
  #         projects/security/configuration#show
  #         projects/security/sast_configuration#show
  #         projects/security/api_fuzzing_configuration#show
  #         projects/security/dast_profiles#show
  #         projects/security/dast_site_profiles#new
  #         projects/security/dast_site_profiles#edit
  #         projects/security/dast_scanner_profiles#new
  #         projects/security/dast_scanner_profiles#edit
  #       ]
  #     end

  #     subject { helper.sidebar_security_configuration_paths }

  #     it { is_expected.to eq(expected_security_configuration_paths) }
  #   end
  # end

  # describe 'On Demand Scans' do

  #   describe '#sidebar_on_demand_scans_paths' do
  #     let(:expected_on_demand_scans_paths) do
  #       %w[
  #         projects/on_demand_scans#index
  #         projects/on_demand_scans#new
  #         projects/on_demand_scans#edit
  #       ]
  #     end

  #     subject { helper.sidebar_on_demand_scans_paths }

  #     it { is_expected.to eq(expected_on_demand_scans_paths) }
  #   end
  # end

  # describe 'Audit Events' do
  # end
end
