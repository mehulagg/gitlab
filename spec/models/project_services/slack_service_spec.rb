# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SlackService do
  it_behaves_like "slack or mattermost notifications", 'Slack'

  describe '#execute' do
    let(:service) { described_class.new(webhook: 'http://example.com', branches_to_be_notified: 'all', project: create(:project, :repository)) }
    let(:data) { Gitlab::DataBuilder::Push.build_sample(service.project, create(:user)) }

    it 'increases the usage data counter' do
      expect(Gitlab::UsageDataCounters::ChatNotificationServicesCounter).to receive(:count).with('slack')
      expect_next_instance_of(Slack::Messenger) do |slack_messenger|
        expect(slack_messenger).to receive(:ping)
      end

      service.execute(data)
    end
  end
end
