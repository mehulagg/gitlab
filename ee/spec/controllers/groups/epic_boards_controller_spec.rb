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
end
