# frozen_string_literal: true

RSpec.shared_examples 'group and project milestone burndowns' do |route_definition|
  let(:resource_route) { "#{route}/#{milestone.id}/burndown_events" }

  describe "GET #{route_definition}" do
    it 'returns burndown events list' do
      get api(resource_route, user)

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to be_an Array
      expect(json_response.first['created_at'].to_time).to eq(Date.today.middle_of_day)
      expect(json_response.first['weight']).to eq(5)
      expect(json_response.first['action']).to eq('created')
      expect(json_response.last['created_at'].to_time).to eq(Date.today.beginning_of_day)
      expect(json_response.last['weight']).to eq(2)
      expect(json_response.last['action']).to eq('created')
    end

    it 'returns 404 when user is not authorized to read milestone' do
      outside_user = create(:user)

      get api(resource_route, outside_user)

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end
end
