# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::EpicBoardsController do
  let_it_be(:public_group) { create(:group, :public) }
  let_it_be(:private_group) { create(:group, :private) }
  let_it_be(:user) { create(:user) }
  let_it_be(:other_user) { create(:user) }

  let(:group) { public_group }

  before do
    group.add_maintainer(user)
    sign_in(user)
  end

  describe 'GET index' do
    it 'creates a new board when group does not have one' do
      expect { list_boards }.to change(group.epic_boards, :count).by(1)
    end

    context 'with unauthorized user' do
      before do
        sign_in(other_user)
      end

      it 'returns a not found 404 response' do
        list_boards

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'json request' do
      it 'is not supported' do
        list_boards(format: :json)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    it_behaves_like 'pushes wip limits to frontend' do
      let(:params) { { group_id: group } }
      let(:parent) { group }
    end

    it_behaves_like 'tracking unique hll events' do
      subject(:request) { list_boards }

      let(:target_id) { 'g_project_management_epic_board_viewed' }
      let(:expected_type) { instance_of(String) }
    end

    def list_boards(format: :html)
      get :index, params: { group_id: group }, format: format
    end
  end

  describe 'GET show' do
    let!(:board) { create(:epic_board, group: group) }

    context 'json request' do
      it 'is not supported' do
        read_board(board: board, format: :json)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when format is HTML' do
      it 'renders template' do
        # epic board visits not supported yet
        # https://gitlab.com/gitlab-org/gitlab/-/issues/321625
        expect { read_board board: board }.not_to change(BoardGroupRecentVisit, :count)

        expect(response).to render_template :show
        expect(response.media_type).to eq 'text/html'
      end

      context 'with unauthorized user' do
        let(:group) { private_group }

        before do
          # sign in some other user not in the private group
          sign_in(other_user)
        end

        it 'returns a not found 404 response' do
          read_board board: board

          expect(response).to have_gitlab_http_status(:not_found)
          expect(response.media_type).to eq 'text/html'
        end
      end

      context 'when user is signed out' do
        let(:group) { public_group }

        it 'does not save visit' do
          sign_out(user)

          # epic board visits not supported yet
          expect { read_board board: board }.not_to change(BoardGroupRecentVisit, :count)

          expect(response).to render_template :show
          expect(response.media_type).to eq 'text/html'
        end
      end
    end

    context 'when epic board does not belong to group' do
      it 'returns a not found 404 response' do
        another_board = create(:epic_board)
        read_board board: another_board

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    it_behaves_like 'disabled when using an external authorization service' do
      subject { read_board board: board }
    end

    it_behaves_like 'tracking unique hll events' do
      subject(:request) { read_board(board: board) }

      let(:target_id) { 'g_project_management_epic_board_viewed' }
      let(:expected_type) { instance_of(String) }
    end

    def read_board(board:, format: :html)
      get :show, params: {
          group_id: group,
          id: board.to_param
      },
          format: format
    end
  end
end
