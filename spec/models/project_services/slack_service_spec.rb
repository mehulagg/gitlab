# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SlackService do
  it_behaves_like "slack or mattermost notifications", 'Slack'

  describe '#execute' do
    before do
      stub_request(:post, "https://slack.service.url/")
    end

    let_it_be(:slack_service) { create(:slack_service) }

    context 'hook data includes a user object' do
      let_it_be(:data) { Gitlab::DataBuilder::Note.build(create(:note_on_issue), create(:user)) }
      let(:user_id) { data[:user][:id] }

      it 'increases the usage data counter' do
        expect(user_id).to be_a_kind_of(Numeric)
        expect(Gitlab::UsageDataCounters::HLLRedisCounter).to receive(:track_event).with('i_ecosystem_slack_service_note_notification', values: user_id)

        slack_service.execute(data)
      end
    end

    context 'hook data does not include a user' do
      let(:data) { Gitlab::DataBuilder::Pipeline.build(create(:ci_pipeline)) }

      it 'increases the usage data counter' do
        expect(Gitlab::UsageDataCounters::HLLRedisCounter).not_to receive(:track_event)

        slack_service.execute(data)
      end
    end
  end
end
