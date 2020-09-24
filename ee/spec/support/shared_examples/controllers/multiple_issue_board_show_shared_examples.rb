# frozen_string_literal: true

RSpec.shared_examples 'multiple issue boards show' do
  let!(:board1) { create(:board, resource_parent: parent, name: 'b') }
  let!(:board2) { create(:board, resource_parent: parent, name: 'a') }

  context 'when multiple issue boards is enabled' do
    it 'lets user view board1' do
      show(board1)

      expect(response).to have_gitlab_http_status(:ok)
      expect(assigns(:board)).to eq(board1)
    end

    it 'lets user view board2' do
      show(board2)

      expect(response).to have_gitlab_http_status(:ok)
      expect(assigns(:board)).to eq(board2)
    end
  end

  context 'when multiple issue boards is disabled' do
    before do
      stub_licensed_features(multiple_group_issue_boards: false)
    end

    it 'let user view the default shown board' do
      show(board2)

      expect(response).to have_gitlab_http_status(:ok)
      expect(assigns(:board)).to eq(board2)
    end

    it 'renders 200 when project board is not the default' do
      show(board1)

      if parent.is_a?(Project)
        expect(response).to have_gitlab_http_status(:ok)
      else
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  def show(board)
    params = {}
    params[:id] = board.to_param

    if board.group_board?
      params[:group_id] = parent
    else
      params.merge!(namespace_id: parent.namespace, project_id: parent)
    end

    get :show, params: params
  end
end
