require 'spec_helper'

describe API::Issues, :mailer do
  set(:user) { create(:user) }
  set(:project) do
    create(:project, :public, creator_id: user.id, namespace: user.namespace)
  end

  let(:user2)       { create(:user) }
  set(:author)      { create(:author) }
  set(:assignee)    { create(:assignee) }
  let(:issue_title)       { 'foo' }
  let(:issue_description) { 'closed' }
  let!(:issue) do
    create :issue,
           author: user,
           assignees: [user],
           project: project,
           milestone: milestone,
           created_at: generate(:past_time),
           updated_at: 1.hour.ago,
           title: issue_title,
           description: issue_description
  end
  set(:milestone) { create(:milestone, title: '1.0.0', project: project) }

  before(:all) do
    project.add_reporter(user)
  end

  describe "GET /issues" do
    context "when authenticated" do
      it 'matches V4 response schema' do
        get api('/issues', user)

        expect(response).to have_gitlab_http_status(200)
        expect(response).to match_response_schema('public_api/v4/issues', dir: 'ee')
      end

      context "filtering by weight" do
        let!(:issue1) { create(:issue, author: user2, project: project, weight: 1, created_at: 3.days.ago) }
        let!(:issue2) { create(:issue, author: user2, project: project, weight: 5, created_at: 2.days.ago) }
        let!(:issue3) { create(:issue, author: user2, project: project, weight: 3, created_at: 1.day.ago) }

        it 'returns issues with specific weight' do
          get api('/issues', user), params: { weight: 5, scope: 'all' }

          expect_paginated_array_response(issue2.id)
        end

        it 'returns issues with no weight' do
          get api('/issues', user), params: { weight: 'None', scope: 'all' }

          expect_paginated_array_response(issue.id)
        end

        it 'returns issues with any weight' do
          get api('/issues', user), params: { weight: 'Any', scope: 'all' }

          expect_paginated_array_response([issue3.id, issue2.id, issue1.id])
        end
      end

      context 'filtering by assignee_username' do
        let(:another_assignee) { create(:assignee) }
        let!(:issue1) { create(:issue, author: user2, project: project, weight: 1, created_at: 3.days.ago) }
        let!(:issue2) { create(:issue, author: user2, project: project, weight: 5, created_at: 2.days.ago) }
        let!(:issue3) { create(:issue, author: user2, assignees: [assignee, another_assignee], project: project, weight: 3, created_at: 1.day.ago) }

        it 'returns issues with multiple assignees' do
          get api("/issues", user), params: { assignee_username: [assignee.username, another_assignee.username], scope: 'all' }

          expect_paginated_array_response(issue3.id)
        end
      end
    end
  end

  describe 'GET /groups/:id/issues' do
    let!(:group)            { create(:group) }
    let!(:group_project)    { create(:project, :public, creator_id: user.id, namespace: group) }

    context 'filtering by assignee_username' do
      let(:another_assignee) { create(:assignee) }
      let!(:issue1) { create(:issue, author: user2, project: group_project, weight: 1, created_at: 3.days.ago) }
      let!(:issue2) { create(:issue, author: user2, project: group_project, weight: 5, created_at: 2.days.ago) }
      let!(:issue3) { create(:issue, author: user2, assignees: [assignee, another_assignee], project: group_project, weight: 3, created_at: 1.day.ago) }

      it 'returns issues with multiple assignees' do
        get api("/groups/#{group.id}/issues", user),
             params: { assignee_username: [assignee.username, another_assignee.username], scope: 'all' }

        expect_paginated_array_response(issue3.id)
      end
    end
  end

  describe "GET /projects/:id/issues" do
    context 'filtering by assignee_username' do
      let(:another_assignee) { create(:assignee) }
      let!(:issue1) { create(:issue, author: user2, project: project, weight: 1, created_at: 3.days.ago) }
      let!(:issue2) { create(:issue, author: user2, project: project, weight: 5, created_at: 2.days.ago) }
      let!(:issue3) { create(:issue, author: user2, assignees: [assignee, another_assignee], project: project, weight: 3, created_at: 1.day.ago) }

      it 'returns issues with multiple assignees' do
        get api("/projects/#{project.id}/issues", user),
             params: { assignee_username: [assignee.username, another_assignee.username], scope: 'all' }

        expect_paginated_array_response(issue3.id)
      end
    end
  end

  describe "POST /projects/:id/issues" do
    it 'creates a new project issue' do
      post api("/projects/#{project.id}/issues", user),
        params: { title: 'new issue', labels: 'label, label2', weight: 101, assignee_ids: [user2.id] }

      expect(response).to have_gitlab_http_status(201)
      expect(json_response['title']).to eq('new issue')
      expect(json_response['description']).to be_nil
      expect(json_response['labels']).to eq(%w(label label2))
      expect(json_response['confidential']).to be_falsy
      expect(json_response['weight']).to eq(101)
      expect(json_response['assignee']['name']).to eq(user2.name)
      expect(json_response['assignees'].first['name']).to eq(user2.name)
    end
  end

  describe 'PUT /projects/:id/issues/:issue_id to update weight' do
    it 'updates an issue with no weight' do
      put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: 101 }

      expect(response).to have_gitlab_http_status(200)
      expect(json_response['weight']).to eq(101)
    end

    it 'removes a weight from an issue' do
      weighted_issue = create(:issue, project: project, weight: 2)

      put api("/projects/#{project.id}/issues/#{weighted_issue.iid}", user), params: { weight: nil }

      expect(response).to have_gitlab_http_status(200)
      expect(json_response['weight']).to be_nil
    end

    it 'returns 400 if weight is less than minimum weight' do
      put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: -1 }

      expect(response).to have_gitlab_http_status(400)
      expect(json_response['message']['weight']).to be_present
    end

    it 'adds a note when the weight is changed' do
      expect do
        put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: 9 }
      end.to change { Note.count }.by(1)

      expect(response).to have_gitlab_http_status(200)
      expect(json_response['weight']).to eq(9)
    end

    context 'issuable weights unlicensed' do
      before do
        stub_licensed_features(issue_weights: false)
      end

      it 'ignores the update' do
        put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: 5 }

        expect(response).to have_gitlab_http_status(200)
        expect(json_response['weight']).to be_nil
        expect(issue.reload.read_attribute(:weight)).to be_nil
      end
    end
  end
end
