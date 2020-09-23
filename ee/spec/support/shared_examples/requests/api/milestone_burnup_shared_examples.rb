# frozen_string_literal: true

RSpec.shared_examples 'group and project milestone burnups' do |route_definition|
  let(:resource_route) { "#{route}/#{milestone.id}/burnup_events" }

  let(:event_time) { milestone.start_date.beginning_of_day }

  let!(:event1) { create(:resource_milestone_event, issue: issue1, action: :add, milestone: milestone, created_at: event_time - 1.hour) }
  let!(:event2) { create(:resource_milestone_event, issue: issue2, action: :add, milestone: milestone, created_at: event_time + 1.hour) }
  let!(:event3) { create(:resource_milestone_event, issue: issue1, action: :remove, milestone: nil, created_at: event_time + 2.hours) }

  describe "GET #{route_definition}" do
    it 'returns burnup events list' do
      get api(resource_route, user)

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to be_an Array
      expect(json_response).to match_schema('burnup_events', dir: 'ee')

      expect(json_response.size).to eq(3)

      expect(json_response.first).to include('issue_id' => issue1.id, 'milestone_id' => milestone.id, 'action' => 'add', 'created_at' => event_time - 1.hour)
      expect(json_response.second).to include('issue_id' => issue2.id, 'milestone_id' => milestone.id, 'action' => 'add', 'created_at' => event_time + 1.hour)
      expect(json_response.third).to include('issue_id' => issue1.id, 'milestone_id' => milestone.id, 'action' => 'remove', 'created_at' => event_time + 2.hours)
    end

    it 'returns 404 when user is not authorized to read milestone' do
      outside_user = create(:user)

      get api(resource_route, outside_user)

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end
end
