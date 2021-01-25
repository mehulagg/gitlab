# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'view group invites' do
  describe 'GET /users/sign_up/groups/new' do
    let_it_be(:group) { create(:group) }
    let_it_be(:user) { create(:user) }

    before_all do
      group.add_owner(user)
    end

    before do
      login_as(user)
    end

    it 'returns 200 response' do
      get new_users_sign_up_group_invite_path(group_id: group)

      expect(response).to have_gitlab_http_status(:ok)
    end
  end
end
