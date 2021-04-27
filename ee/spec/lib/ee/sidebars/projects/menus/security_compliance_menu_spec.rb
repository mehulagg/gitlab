# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::SecurityComplianceMenu do
  let_it_be(:project) { create(:project) }

  let(:user) { project.owner }
  let(:show_promotions) { true }
  let(:show_discover_project_security) { true }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project, show_promotions: show_promotions, show_discover_project_security: show_discover_project_security) }

  subject { described_class.new(context) }

  describe 'render?' do
    context 'when user can access security and compliance' do
      it 'returns true' do
        expect(subject.render?).to eq true
      end
    end

    context 'when user cannot access security and compliance' do
      let(:user) { nil }

      context 'when show discover project security is enabled' do
        it 'returns true' do
          expect(subject.render?).to eq true
        end
      end

      context 'when show discover project security is disabled' do
        let(:show_discover_project_security) { false }

        it 'returns false' do
          expect(subject.render?).to eq false
        end
      end
    end
  end

  describe '#link' do
    using RSpec::Parameterized::TableSyntax

    where(:security_dashboard_feature, :audit_events_feature, :dependency_scanning_feature, :expected_link) do
      true  | true  | true  | "/-/security/dashboard"
      false | true  | true  | "/-/audit_events"
      false | false | true  | "/-/dependencies"
      false | false | false | "/-/security/configuration"
    end

    with_them do
      it 'returns the expected link' do
        stub_licensed_features(security_dashboard: security_dashboard_feature, audit_events: audit_events_feature, dependency_scanning: dependency_scanning_feature)

        expect(subject.link).to include(expected_link)
      end
    end

    context 'when no security menu item and show promotions' do
      let(:user) { nil }

      it 'returns the link to the discover security path', :aggregate_failures do
        expect(subject.items).to be_empty
        expect(subject.link).to eq("/#{project.full_path}/-/security/discover")
      end
    end
  end

  describe 'Configuration' do
    describe '#sidebar_security_configuration_paths' do
      let(:expected_security_configuration_paths) do
        %w[
          projects/security/configuration#show
          projects/security/sast_configuration#show
          projects/security/api_fuzzing_configuration#show
          projects/security/dast_profiles#show
          projects/security/dast_site_profiles#new
          projects/security/dast_site_profiles#edit
          projects/security/dast_scanner_profiles#new
          projects/security/dast_scanner_profiles#edit
        ]
      end

      subject { described_class.new(context).items.find { |i| i.item_id == :configuration } }

      it 'includes all the security configuration paths' do
        expect(subject.active_routes[:path]).to eq expected_security_configuration_paths
      end
    end
  end

  describe 'Security Dashboard' do
    before do
      stub_licensed_features(security_dashboard: true)
    end

    subject { described_class.new(context).items.find { |i| i.item_id == :dashboard } }

    context 'when user can access security dashboard' do
      it { is_expected.not_to be_nil }
    end

    context 'when user cannot access security dashboard' do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'Vulnerability Report' do
    subject { described_class.new(context).items.find { |i| i.item_id == :vulnerability_report } }

    context 'when user can access vulnerabilities report' do
      it { is_expected.not_to be_nil }
    end

    context 'when user cannot access vulnerabilities report' do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'On Demand Scans' do
    subject { described_class.new(context).items.find { |i| i.item_id == :on_demand_scans } }

    context 'when user can access vulnerabilities report' do
      it { is_expected.not_to be_nil }
    end

    context 'when user cannot access vulnerabilities report' do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'Dependency List' do
    subject { described_class.new(context).items.find { |i| i.item_id == :dependency_list } }

    context 'when user can access dependency list' do
      it { is_expected.not_to be_nil }
    end

    context 'when user cannot access dependency list' do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'License Compliance' do
    subject { described_class.new(context).items.find { |i| i.item_id == :license_compliance } }

    context 'when user can access license compliance' do
      it { is_expected.not_to be_nil }
    end

    context 'when user cannot access license compliance' do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'Threat monitoring' do
    subject { described_class.new(context).items.find { |i| i.item_id == :threat_monitoring } }

    context 'when user can access threat monitoring' do
      it { is_expected.not_to be_nil }
    end

    context 'when user cannot access threat monitoring' do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'Scan Policies' do
    subject { described_class.new(context).items.find { |i| i.item_id == :scan_policies } }

    context 'when user can access scan policies' do
      it { is_expected.not_to be_nil }
    end

    context 'when user cannot access scan policies' do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'Audit Events' do
    subject { described_class.new(context).items.find { |i| i.item_id == :audit_events } }

    context 'when user can access audit events' do
      it { is_expected.not_to be_nil }
    end

    context 'when user cannot access audit events' do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end
  end
end
