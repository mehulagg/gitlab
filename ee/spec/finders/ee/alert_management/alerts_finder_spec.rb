# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::AlertsFinder, '#execute' do
  let_it_be_with_refind(:project) { create(:project) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:general_alert) do
    create( :alert_management_alert, project: project, domain: :operations, monitoring_tool: 'Monitor')
  end

  let_it_be(:cilium_alert) do
    create( :alert_management_alert, project: project, domain: :threat_monitoring, monitoring_tool: 'Cilium')
  end

  let(:params) { {} }

  describe '#execute' do
    before do
      project.add_developer(current_user)
    end

    subject(:execute) { described_class.new(current_user, project, params).execute }

    context 'filtering by domain' do
      using RSpec::Parameterized::TableSyntax

      where(:domain, :license_enabled, :alerts) do
        'threat_monitoring' | true  | [:cilium_alert]
        'threat_monitoring' | false | :general_alert
        'operations'        | true  | :general_alert
        'operations'        | false | :general_alert
        'unknown'           | true  | :general_alert
        'unknown'           | false | :general_alert
        nil                 | true  | :general_alert
        nil                 | false | :general_alert
      end

      with_them do
        let(:params) { { domain: domain }.compact }
        let(:expected_alerts) { Array(alerts).map { |symbol| send(symbol) } }

        before do
          stub_licensed_features(cilium_alerts: license_enabled)
        end

        it { is_expected.to match_array(expected_alerts) }
      end
    end
  end
end
