# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Settings::AccessTokensController do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  before_all do
    project.add_maintainer(user)
  end

  before do
    sign_in(user)
  end

  shared_examples 'feature unavailable' do
    context 'on GitLab.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      context 'with a free plan' do
        it { is_expected.to have_gitlab_http_status(:not_found) }
      end

      context 'with a paid group plan' do
        let_it_be(:group) { create(:group_with_plan, plan: :bronze_plan) }
        let_it_be(:project) { create(:project, group: group) }

        before do
          project.add_developer(user)
        end

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end
    end
  end

  describe '#index' do
    subject { get :index, params: { namespace_id: project.namespace, project_id: project } }

    it_behaves_like 'feature unavailable'
  end

  describe '#create', :clean_gitlab_redis_shared_state do
    subject { post :create, params: { namespace_id: project.namespace, project_id: project }.merge(project_access_token: access_token_params) }

    let_it_be(:access_token_params) { {} }

    it_behaves_like 'feature unavailable'
  end

  describe '#revoke' do
    let_it_be(:bot_user) { create(:user, :project_bot) }
    let_it_be(:project_access_token) { create(:personal_access_token, user: bot_user) }

    subject { put :revoke, params: { namespace_id: project.namespace, project_id: project, id: project_access_token } }

    before_all do
      project.add_maintainer(bot_user)
    end

    it_behaves_like 'feature unavailable'
  end
end
