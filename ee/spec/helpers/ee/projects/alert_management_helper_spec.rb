# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::AlertManagementHelper do
  let(:project) { build_stubbed(:project) }
  let(:current_user) { build_stubbed(:user) }

  before do
    allow(helper).to receive(:can?)
      .with(current_user, :admin_operations, project) { true }
  end

  describe '#alert_management_data' do
    let(:alerts_service) do
      build_stubbed(:alerts_service,
        project: project,
        opsgenie_mvc_enabled: false,
        opsgenie_mvc_target_url: 'https://appname.app.opsgenie.com/alert/list'
      )
    end

    subject { helper.alert_management_data(current_user, project) }

    before do
      allow(project).to receive(:alerts_service).and_return(alerts_service)
      allow(alerts_service).to receive(:opsgenie_mvc_available?)
        .and_return(opsgenie_available)
    end

    context 'when available' do
      let(:opsgenie_available) { true }

      it do
        is_expected.to include(
          'opsgenie_mvc_available' => 'true',
          'opsgenie_mvc_enabled' => 'false',
          'opsgenie_mvc_target_url' => 'https://appname.app.opsgenie.com/alert/list'
        )
      end
    end

    context 'when not available' do
      let(:opsgenie_keys) do
        %w[opsgenie_mvc_available opsgenie_mvc_enabled opsgenie_mvc_target_url]
      end

      let(:opsgenie_available) { false }

      it { is_expected.not_to include(opsgenie_keys) }
    end
  end
end
