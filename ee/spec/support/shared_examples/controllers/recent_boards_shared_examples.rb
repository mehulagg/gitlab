# frozen_string_literal: true

RSpec.shared_examples 'returns recently visited boards' do
  let(:boards) { create_list(:board, 8, resource_parent: parent) }

  it 'returns last 4 visited boards' do
    [0, 2, 5, 3, 7, 1].each_with_index do |board_index, i|
      visit_board(boards[board_index], Time.now + i.minutes)
    end

    list_boards(recent: true)

    expect(json_response.length).to eq(4)
    expect(json_response.map { |b| b['id'] }).to eq([1, 7, 3, 5].map { |i| boards[i].id })
  end
end

RSpec.shared_examples 'redirects to last visited board' do
  let(:boards) { create_list(:board, 3, resource_parent: parent) }

  before do
    visit_board(boards[2], Time.now + 1.minute)
    visit_board(boards[0], Time.now + 2.minutes)
    visit_board(boards[1], Time.now + 5.minutes)
  end

  context 'when multiple boards are disabled' do
    before do
      stub_licensed_features(multiple_group_issue_boards: false)
    end

    it 'renders first board' do
      list_boards(format: :html)

      if parent.is_a?(Group)
        expect(response).to render_template :index
        expect(response.content_type).to eq 'text/html'
        expect(response).to have_gitlab_http_status(:ok)
      else
        expect(response.content_type).to eq 'text/html'
        expect(response).to have_gitlab_http_status(:found)
      end
    end
  end

  context 'when multiple boards are enabled' do
    before do
      stub_licensed_features(multiple_group_issue_boards: true)
    end

    it 'redirects to latest visited board' do
      list_boards(format: :html)

      board_path = if parent.is_a?(Group)
                     group_board_path(group_id: parent, id: boards[1].id)
                   else
                     namespace_project_board_path(namespace_id: parent.namespace, project_id: parent, id: boards[1].id)
                   end

      expect(response).to redirect_to(board_path)
    end
  end
end

def list_boards(recent: false, format: :json)
  action = recent ? :recent : :index
  params = if parent.is_a?(Group)
             { group_id: parent }
           else
             { namespace_id: parent.namespace, project_id: parent }
           end

  get action, params: params, format: format
end

def visit_board(board, time)
  if parent.is_a?(Group)
    create(:board_group_recent_visit, group: parent, board: board, user: user, updated_at: time)
  else
    create(:board_project_recent_visit, project: parent, board: board, user: user, updated_at: time)
  end
end
