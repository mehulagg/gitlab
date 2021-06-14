# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Analytics::CycleAnalytics::SummaryController do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:author) { create(:user) }

  let_it_be(:issue_with_author) { create(:issue, project: project, author: author, created_at: Date.new(2015, 1, 1)) }
  let_it_be(:issue_with_other_author) { create(:issue, project: project, author: user, created_at: Date.new(2015, 1, 1)) }

  let(:params) { { namespace_id: project.namespace.to_param, project_id: project.to_param, created_after: '2010-01-01', created_before: '2020-01-02' } }

  before do
    sign_in(user)
  end

  describe 'GET "show"' do
    subject { get :show, params: params }

    before do
      project.add_reporter(user)

      params[:author_username] = issue_with_author.author.username
    end

    context 'when cycle_analytics_for_projects feature is available' do
      before do
        stub_licensed_features(cycle_analytics_for_projects: true)
      end
      it 'filters by author username' do
        subject

        expect(response).to be_successful

        issue_count = json_response.first
        expect(issue_count['value']).to eq('1')
      end
    end

    context 'when cycle_analytics_for_projects feature is not available' do
      it 'does not apply the filter' do
        subject

        expect(response).to be_successful

        issue_count = json_response.first
        expect(issue_count['value']).to eq('2')
      end
    end
  end
end
