# frozen_string_literal: true

RSpec.shared_examples 'milestone board list' do
  before do
    stub_licensed_features(board_milestone_lists: true)
  end

  context 'when milestone_id is sent' do
    it 'returns 400 if milestone is not found' do
      other_milestone = create(:milestone)
      post api(url, user), params: { milestone_id: other_milestone.id }

      expect(response).to have_gitlab_http_status(:bad_request)
      expect(json_response.dig('message', 'error')).to eq('Milestone not found')
    end

    it 'returns 400 if milestone list feature is not available' do
      stub_licensed_features(board_milestone_lists: false)

      post api(url, user), params: { milestone_id: milestone.id }

      expect(response).to have_gitlab_http_status(:bad_request)
      expect(json_response.dig('message', 'error'))
        .to eq('Milestone lists not available with your current license')
    end

    it 'creates a milestone list if milestone is found' do
      post api(url, user), params: { milestone_id: milestone.id }

      expect(response).to have_gitlab_http_status(:created)
      expect(json_response.dig('milestone', 'id')).to eq(milestone.id)
    end
  end
end
