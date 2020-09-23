# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::MilestonesController do
  let(:project) { create(:project, :private) }
  let(:board) { create(:board, project: project) }
  let(:user)  { create(:user) }

  describe 'GET index' do
    context 'with authorized user' do
      before do
        create(:milestone, project: project)

        project.add_maintainer(user)
        sign_in(user)
      end

      shared_examples 'authorized board milestone listing' do
        it 'returns a list of all milestones of board parent' do
          get :index, params: { board_id: board.to_param }, format: :json

          expect(response).to have_gitlab_http_status(:ok)

          expect(response.content_type).to eq('application/json')
          expect(json_response).to all(match_schema('entities/milestone', dir: 'ee'))
          expect(json_response.size).to eq(1)
        end
      end

      context 'with private group board' do
        let(:group) { create(:group, :private) }
        let(:board) { create(:board, group: group) }

        before do
          create(:milestone, group: group)
          group.add_maintainer(user)
        end

        it_behaves_like 'authorized board milestone listing'
      end

      context 'with private project board' do
        it_behaves_like 'authorized board milestone listing'
      end
    end

    context 'with unauthorized user' do
      before do
        sign_in(user)
      end

      shared_examples 'unauthorized board milestone listing' do
        it 'returns a forbidden 403 response' do
          get :index, params: { board_id: board.to_param }, format: :json

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      context 'with private group board' do
        let(:group) { create(:group, :private) }
        let(:board) { create(:board, group: group) }

        it_behaves_like 'unauthorized board milestone listing'
      end

      context 'with private project board' do
        it_behaves_like 'unauthorized board milestone listing'
      end
    end
  end
end
