# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::IssuesController, '(JavaScript fixtures)', type: :controller do
  include JavaScriptFixturesHelpers

  let(:user) { create(:user, feed_token: 'feedtoken:coldfeed') }
  let(:group) { create(:group) }
  let(:project) { create(:project_empty_repo, namespace: group, path: 'issues-project') }

  render_views

  before(:all) do
    clean_frontend_fixtures('ee/issues/')
  end

  before do
    project.add_developer(user)

    sign_in(user)
  end

  after do
    remove_repository(project)
  end

  it 'ee/issues/blocked-issue.html' do
    issue = create(:issue, project: project)
    related_issue = create(:issue, project: project)
    create(:issue_link, source: related_issue, target: issue, link_type: IssueLink::TYPE_BLOCKS)
    render_issue(issue)
  end

  private

  def render_issue(issue)
    get :show, params: {
      namespace_id: project.namespace.to_param,
      project_id: project,
      id: issue.to_param
    }

    expect(response).to be_successful
  end
end
