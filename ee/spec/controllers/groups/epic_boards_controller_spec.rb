# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::EpicBoardsController do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  before do
    group.add_maintainer(user)
    sign_in(user)
  end

  describe 'GET index' do
    it 'creates a new board when group does not have one' do
      expect { list_boards }.to change(group.epic_boards, :count).by(1)
    end

    context 'with unauthorized user' do
      let(:other_user) { create(:user) }

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

    def list_boards(format: :html)
      get :index, params: { group_id: group }, format: format
    end
  end

  describe 'GET show' do
    let!(:board) { create(:epic_board, group: group) }

    context 'when format is HTML' do
      it 'renders template' do
        # epic board visits not supported yet
        expect { read_board board: board }.not_to change(BoardGroupRecentVisit, :count)

        expect(response).to render_template :show
        expect(response.media_type).to eq 'text/html'
      end

      context 'with unauthorized user' do
        let(:group) { create(:group, :private) }

        before do
          sign_in(create(:user))
        end

        it 'returns a not found 404 response' do
          read_board board: board

          expect(response).to have_gitlab_http_status(:not_found)
          expect(response.media_type).to eq 'text/html'
        end
      end

      context 'when user is signed out' do
        let(:group) { create(:group, :public) }

        it 'does not save visit' do
          sign_out(user)

          # epic board visits not supported yet
          expect { read_board board: board }.not_to change(BoardGroupRecentVisit, :count)

          expect(response).to render_template :show
          expect(response.media_type).to eq 'text/html'
        end
      end
    end

    context 'json request' do
      it 'is not supported' do
        read_board(board: board, format: :json)

        expect(response).to have_gitlab_http_status(:not_found)
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

    def read_board(board:, format: :html)
      get :show, params: {
          group_id: group,
          id: board.to_param
      },
          format: format
    end
  end
end
