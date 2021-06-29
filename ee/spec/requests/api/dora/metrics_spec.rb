# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Dora::Metrics do
  describe 'GET /projects/:id/dora/metrics' do
    subject { get api(url, user), params: params }

    let_it_be(:project) { create(:project) }
    let_it_be(:production) { create(:environment, :production, project: project) }
    let_it_be(:maintainer) { create(:user) }
    let_it_be(:guest) { create(:user) }

    let(:url) { "/projects/#{project.id}/dora/metrics" }
    let(:params) { { metric: :deployment_frequency } }
    let(:user) { maintainer }

    around do |example|
      travel_to '2021-01-03'.to_time do
        example.run
      end
    end

    before_all do
      project.add_maintainer(maintainer)
      project.add_guest(guest)
      create(:dora_daily_metrics, deployment_frequency: 1, environment: production, date: '2021-01-01')
      create(:dora_daily_metrics, deployment_frequency: 2, environment: production, date: '2021-01-02')
    end

    before do
      stub_licensed_features(dora4_analytics: true)
    end

    it 'returns data' do
      subject

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to eq([{ 'date' => '2021-01-01', 'value' => 1 },
                                   { 'date' => '2021-01-02', 'value' => 2 }])
    end

    context 'when user is guest' do
      let(:user) { guest }

      it 'returns authorization error' do
        subject

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(json_response['message']).to eq('You do not have permission to access dora metrics.')
      end
    end
  end

  describe 'GET /groups/:id/dora/metrics' do
    subject { get api(url, user), params: params }

    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, group: group) }
    let_it_be(:production) { create(:environment, :production, project: project) }
    let_it_be(:maintainer) { create(:user) }
    let_it_be(:guest) { create(:user) }

    let(:url) { "/groups/#{group.id}/dora/metrics" }
    let(:params) { { metric: :deployment_frequency } }
    let(:user) { maintainer }

    around do |example|
      freeze_time do
        example.run
      end
    end

    before_all do
      group.add_maintainer(maintainer)
      group.add_guest(guest)
      create(:dora_daily_metrics, deployment_frequency: 1, environment: production, date: 1.day.ago.to_date)
      create(:dora_daily_metrics, deployment_frequency: 2, environment: production, date: Time.current.to_date)
    end

    before do
      stub_licensed_features(dora4_analytics: true)
    end

    it 'returns data' do
      subject

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to eq([{ 'date' => 1.day.ago.to_date.to_s, 'value' => 1 },
                                   { 'date' => Time.current.to_date.to_s, 'value' => 2 }])
    end

    context 'when user is guest' do
      let(:user) { guest }

      it 'returns authorization error' do
        subject

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(json_response['message']).to eq('You do not have permission to access dora metrics.')
      end
    end
  end
end
