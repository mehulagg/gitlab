# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Analytics::CycleAnalyticsController do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  before do
    group.add_maintainer(user)
    sign_in(user)
  end

  context 'when the license is available' do
    before do
      stub_licensed_features(cycle_analytics_for_groups: true)
    end

    it 'succeeds' do
      get(:show, params: { group_id: group })

      expect(response).to be_successful
    end

    it 'increments usage counter' do
      expect(Gitlab::UsageDataCounters::CycleAnalyticsCounter).to receive(:count).with(:views)

      get(:show, params: { group_id: group })

      expect(response).to be_successful
    end

    it 'renders `show` template when feature flag is enabled' do
      get(:show, params: { group_id: group })

      expect(response).to render_template :show
    end
  end

  context 'when the license is missing' do
    it 'renders 403 error' do
      get(:show, params: { group_id: group })

      expect(response).to have_gitlab_http_status(:forbidden)
    end
  end

  context 'when non-existent group is given' do
    it 'renders 403 error' do
      get(:show, params: { group_id: 'unknown' })

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  context 'with group and value stream params' do
    let(:value_stream) { create(:cycle_analytics_group_value_stream, group: group) }

    it 'builds request params with group and value stream' do
      expect_next_instance_of(Gitlab::Analytics::CycleAnalytics::RequestParams) do |instance|
        expect(instance).to have_attributes(group: group, value_stream: value_stream)
      end

      get(:show, params: { group_id: group, value_stream_id: value_stream })
    end
  end
end
