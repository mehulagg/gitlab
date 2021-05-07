# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::IssuesAnalyticsController do
  it_behaves_like 'issue analytics controller' do
    let_it_be(:user)  { create(:user) }
    let_it_be(:group) { create(:group) }
    let_it_be(:project1) { create(:project, :empty_repo, namespace: group) }
    let_it_be(:project2) { create(:project, :empty_repo, namespace: group) }
    let_it_be(:issue1) { create(:issue, project: project1, confidential: true) }
    let_it_be(:issue2) { create(:issue, :closed, project: project2) }

    before do
      group.add_owner(user)
      sign_in(user)
    end

    let(:params) { { group_id: group.to_param } }
  end

  describe 'GET #show' do
    let_it_be(:user) { create(:user) }
    let_it_be(:group) { create(:group) }

    before do
      group.add_owner(user)
      sign_in(user)
      stub_licensed_features(issues_analytics: true)
    end

    it_behaves_like 'tracking unique visits', :show do
      let(:request_params) { { group_id: group.to_param } }
      let(:target_id) { 'g_analytics_issues' }
    end
  end
end
