# frozen_string_literal: true

RSpec.shared_examples 'assignee board list' do
  before do
    stub_licensed_features(board_assignee_lists: true)
  end

  context 'when assignee_id is sent' do
    it 'returns 400 if user is not found' do
      other_user = create(:user)
      post api(url, user), params: { assignee_id: other_user.id }

      expect(response).to have_gitlab_http_status(:bad_request)
      expect(json_response.dig('message', 'error')).to eq('Assignee not found')
    end

    it 'returns 400 if assignee list feature is not available' do
      stub_licensed_features(board_assignee_lists: false)

      post api(url, user), params: { assignee_id: user.id }

      expect(response).to have_gitlab_http_status(:bad_request)
      expect(json_response.dig('message', 'error'))
          .to eq('Assignee lists not available with your current license')
    end

    it 'creates an assignee list if user is found' do
      post api(url, user), params: { assignee_id: user.id }

      expect(response).to have_gitlab_http_status(:created)
      expect(json_response.dig('assignee', 'id')).to eq(user.id)
    end
  end
end
