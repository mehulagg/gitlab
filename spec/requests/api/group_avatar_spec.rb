# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::GroupAvatar do
  def avatar_path(group)
    "/groups/#{group.id}/avatar"
  end

  describe 'GET /groups/:id/avatar' do
    context 'when the group is public' do
      it 'retrieves the avatar successfully' do
        group = create(:group, :public, :with_avatar)

        get api(avatar_path(group))

        expect(response).to have_gitlab_http_status(:ok)
      end

      context 'when the group does not have avatar' do
        it 'returns :not_found' do
          group = create(:group, :public)

          get api(avatar_path(group))

          expect(response).to have_gitlab_http_status(:not_found)
          expect(json_response["message"])
            .to eq('Group does not have avatar')
        end
      end
    end

    context 'when the group is private' do
      let_it_be(:owner) { create(:user) }
      let_it_be(:group) { create(:group, :private, :with_avatar) }

      before do
        group.add_owner(owner)
      end

      context 'when the user is not authenticated' do
        it 'returns :not_found' do
          get api(avatar_path(group))

          expect(response).to have_gitlab_http_status(:not_found)
          expect(json_response["message"])
            .to eq('404 Group Not Found')
        end
      end

      context 'when the the group user is authenticated' do
        context 'and have access to the group' do
          it 'retrieves the avatar successfully' do
            get api(avatar_path(group), owner)

            expect(response).to have_gitlab_http_status(:ok)
          end
        end

        context 'and does not have access to the group' do
          it 'returns :not_found' do
            get api(avatar_path(group), create(:user))

            expect(response).to have_gitlab_http_status(:not_found)
            expect(json_response["message"])
              .to eq('404 Group Not Found')
          end
        end
      end
    end
  end
end
