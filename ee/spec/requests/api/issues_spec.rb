# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Issues, :mailer do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) do
    create(:project, :public, creator_id: user.id, namespace: user.namespace)
  end
  let_it_be(:group) { create(:group) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:group_project) { create(:project, :public, creator_id: user.id, namespace: group) }

  let(:user2)             { create(:user) }

  let_it_be(:author)      { create(:author) }
  let_it_be(:assignee)    { create(:assignee) }

  before_all do
    project.add_reporter(user)
  end

  shared_examples 'exposes epic' do
    context 'with epics feature' do
      before do
        stub_licensed_features(epics: true)
      end

      it 'contains epic_iid in response' do
        subject

        expect(response).to have_gitlab_http_status(:success)
        expect(epic_issue_response_for(issue_with_epic)['epic_iid']).to eq(epic.iid)
      end

      it 'contains epic in response' do
        subject

        expect(response).to have_gitlab_http_status(:success)
        expect(epic_issue_response_for(issue_with_epic)['epic']).to eq({ "id" => epic.id,
                                                                    "iid" => epic.iid,
                                                                    "group_id" => epic.group_id,
                                                                    "title" => epic.title,
                                                                    "url" => group_epic_path(epic.group, epic) })
      end

      context 'and epic issue is not present' do
        it 'exposes epic as nil' do
          issue_with_epic.epic_issue.destroy

          subject

          response = epic_issue_response_for(issue_with_epic)
          expect(response['epic']).to eq(nil)
          expect(response['epic_id']).to eq(nil)
        end
      end
    end

    context 'without epics feature' do
      before do
        stub_licensed_features(epics: false)
      end

      it 'does not contain epic_iid in response' do
        subject

        expect(response).to have_gitlab_http_status(:success)
        expect(epic_issue_response_for(issue_with_epic)).not_to have_key('epic_iid')
      end

      it 'does not contain epic_iid in response' do
        subject

        expect(response).to have_gitlab_http_status(:success)
        expect(epic_issue_response_for(issue_with_epic)).not_to have_key('epic')
      end
    end
  end

  shared_examples 'filtering by epic_id' do
    let_it_be(:epic1) { create :epic, group: group_project.namespace }
    let_it_be(:epic2) { create :epic, group: group_project.namespace }
    let_it_be(:issue1) { create(:issue, { author: user, epic: epic1, project: group_project }) }
    let_it_be(:issue2) { create(:issue, { author: user, epic: epic2, project: group_project }) }
    let_it_be(:issue3) { create(:issue, { author: user, project: group_project }) }

    before do
      stub_licensed_features(epics: true)
    end

    it 'returns issues without epic when epic_id is "None"' do
      get api(endpoint, user), params: { epic_id: 'None', scope: 'all' }

      expect_response_contain_exactly(issue3.id)
    end

    it 'returns issues with any epic when epic_id is "Any"' do
      get api(endpoint, user), params: { epic_id: 'Any', scope: 'all' }

      expect_response_contain_exactly(issue1.id, issue2.id)
    end

    it 'returns issues with any epic when epic_id is specific' do
      get api(endpoint, user), params: { epic_id: epic1.id, scope: 'all' }

      expect_response_contain_exactly(issue1.id)
    end
  end

  describe "GET /issues" do
    context "when authenticated" do
      it 'matches V4 response schema' do
        get api('/issues', user)

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('public_api/v4/issues', dir: 'ee')
      end

      context "blocking issues count" do
        let!(:issue) { create :issue, author: user, project: project }

        it 'returns a blocking issues count of 0 if there are no blocking issues' do
          get api('/issues', user)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.first).to include('blocking_issues_count' => 0)
        end

        it 'returns a blocking issues count of 1 if there exists a blocking issue' do
          blocked_issue = build(:issue, author: user2, project: project, created_at: 1.day.ago)
          create(:issue_link, source: issue, target: blocked_issue, link_type: IssueLink::TYPE_BLOCKS)

          get api('/issues', user)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.first).to include('blocking_issues_count' => 1)
        end
      end

      context "filtering by weight" do
        let!(:issue) { create(:issue, author: user2, project: project, weight: nil, created_at: 4.days.ago) }
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

      it_behaves_like 'filtering by epic_id' do
        let(:endpoint) { '/issues' }
      end
    end
  end

  describe 'GET /groups/:id/issues' do
    subject { get api("/groups/#{group.id}/issues", user) }

    context 'filtering by assignee_username' do
      let(:another_assignee) { create(:assignee) }
      let!(:issue1) { create(:issue, author: user2, project: group_project, weight: 1, created_at: 3.days.ago) }
      let!(:issue2) { create(:issue, author: user2, project: group_project, weight: 5, created_at: 2.days.ago) }
      let!(:issue3) { create(:issue, author: user2, assignees: [assignee, another_assignee], project: group_project, weight: 3, created_at: 1.day.ago) }

      subject do
        get api("/groups/#{group.id}/issues", user),
            params: { assignee_username: [assignee.username, another_assignee.username], scope: 'all' }
      end

      it 'returns issues with multiple assignees' do
        subject

        expect_paginated_array_response(issue3.id)
      end
    end

    it_behaves_like 'filtering by epic_id' do
      let(:endpoint) { "/groups/#{group_project.group.id}/issues" }
    end

    it_behaves_like 'exposes epic' do
      let!(:issue_with_epic) { create(:issue, project: group_project, epic: epic) }
    end
  end

  describe "GET /projects/:id/issues" do
    subject { get api("/projects/#{project.id}/issues", user) }

    context 'filtering by assignee_username' do
      let(:another_assignee) { create(:assignee) }
      let!(:issue1) { create(:issue, author: user2, project: project, weight: 1, created_at: 3.days.ago) }
      let!(:issue2) { create(:issue, author: user2, project: project, weight: 5, created_at: 2.days.ago) }
      let!(:issue3) { create(:issue, author: user2, assignees: [assignee, another_assignee], project: project, weight: 3, created_at: 1.day.ago) }

      subject do
        get api("/projects/#{project.id}/issues", user),
            params: { assignee_username: [assignee.username, another_assignee.username], scope: 'all' }
      end

      it 'returns issues with multiple assignees' do
        subject

        expect_paginated_array_response(issue3.id)
      end
    end

    it_behaves_like 'filtering by epic_id' do
      let(:endpoint) { "/projects/#{group_project.id}/issues" }
    end

    context 'on personal project' do
      let!(:issue_with_epic) { create(:issue, project: project, epic: epic) }

      before do
        stub_licensed_features(epics: true)
      end

      it 'does not contain epic_iid in response' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(epic_issue_response_for(issue_with_epic)).not_to have_key('epic_iid')
      end
    end

    context 'on group project' do
      let!(:issue_with_epic) { create(:issue, project: group_project, epic: epic) }

      subject { get api("/projects/#{group_project.id}/issues", user) }

      it_behaves_like 'exposes epic'
    end
  end

  describe 'GET /project/:id/issues/:issue_id' do
    context 'on personal project' do
      let!(:issue_with_epic) { create(:issue, project: project, epic: epic) }

      subject { get api("/projects/#{project.id}/issues/#{issue_with_epic.iid}", user) }

      before do
        stub_licensed_features(epics: true)
      end

      it 'does not contain epic_iid in response' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(epic_issue_response_for(issue_with_epic)).not_to have_key('epic_iid')
      end
    end

    context 'on group project' do
      let!(:issue_with_epic) { create(:issue, project: group_project, epic: epic) }

      subject { get api("/projects/#{group_project.id}/issues/#{issue_with_epic.iid}", user) }

      it_behaves_like 'exposes epic'
    end
  end

  shared_examples 'with epic parameter' do
    let(:params) { { title: 'issue with epic', epic_id: epic.id } }

    context 'for a group project' do
      let(:target_project) { group_project }

      context 'with epics feature' do
        before do
          stub_licensed_features(epics: true)
        end

        context 'when user can admin epics' do
          before do
            group.add_owner(user)
          end

          context 'with epic_id parameter' do
            let(:params) { { title: 'issue with epic', epic_id: epic.id } }

            it 'sets epic on issue' do
              request

              expect(response).to have_gitlab_http_status(:success)
              expect(json_response['epic_iid']).to eq(epic.iid)
            end
          end

          context 'with deprecated epic_iid parameter' do
            let(:params) { { title: 'issue with epic', epic_iid: epic.iid } }

            it 'sets epic on issue' do
              request

              expect(response).to have_gitlab_http_status(:success)
              expect(json_response['epic_iid']).to eq(epic.iid)
            end
          end
        end

        context 'when user can not edit epics' do
          before do
            group.add_guest(user)
          end

          it 'returns an error' do
            request

            expect(response).to have_gitlab_http_status(:forbidden)
            expect(json_response['message']).to eq('403 Forbidden')
          end
        end
      end

      context 'without epics feature' do
        before do
          stub_licensed_features(epics: false)
          group.add_owner(user)
        end

        it 'does not set epic on issue' do
          request

          expect(response).to have_gitlab_http_status(:not_found)
          expect(json_response['message']).to eq('404 Not found')
        end
      end

      context 'when both epic_id and epic_iid is used' do
        let(:params) { { title: 'issue with epic', epic_id: epic.id, epic_iid: epic.iid } }

        it 'returns an error' do
          request

          expect(response).to have_gitlab_http_status(:bad_request)
        end
      end
    end

    context 'for a user project' do
      let(:target_project) { project }

      it 'does not set epic on issue' do
        request

        expect(response).to have_gitlab_http_status(:success)
        expect(json_response).not_to have_key('epic_iid')
      end
    end
  end

  describe "POST /projects/:id/issues" do
    it 'creates a new project issue' do
      post api("/projects/#{project.id}/issues", user),
        params: { title: 'new issue', labels: 'label, label2', weight: 101, assignee_ids: [user2.id] }

      expect(response).to have_gitlab_http_status(:created)
      expect(json_response['title']).to eq('new issue')
      expect(json_response['description']).to be_nil
      expect(json_response['labels']).to eq(%w(label label2))
      expect(json_response['confidential']).to be_falsy
      expect(json_response['weight']).to eq(101)
      expect(json_response['assignee']['name']).to eq(user2.name)
      expect(json_response['assignees'].first['name']).to eq(user2.name)
    end

    it_behaves_like 'with epic parameter' do
      let(:request) { post api("/projects/#{target_project.id}/issues", user), params: params }
    end
  end

  describe 'PUT /projects/:id/issues/:issue_id to update weight' do
    let!(:issue) { create :issue, author: user, project: project }

    it 'updates an issue with no weight' do
      put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: 101 }

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response['weight']).to eq(101)
    end

    it 'removes a weight from an issue' do
      weighted_issue = create(:issue, project: project, weight: 2)

      put api("/projects/#{project.id}/issues/#{weighted_issue.iid}", user), params: { weight: nil }

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response['weight']).to be_nil
    end

    it 'returns 400 if weight is less than minimum weight' do
      put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: -1 }

      expect(response).to have_gitlab_http_status(:bad_request)
      expect(json_response['message']['weight']).to be_present
    end

    it 'creates a ResourceWeightEvent' do
      expect do
        put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: 9 }
      end.to change { ResourceWeightEvent.count }.by(1)
    end

    it 'does not create a system note' do
      expect do
        put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: 9 }
      end.not_to change { Note.count }
    end

    it 'adds a note when the weight is changed' do
      put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: 9 }

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response['weight']).to eq(9)
    end

    context 'issuable weights unlicensed' do
      before do
        stub_licensed_features(issue_weights: false)
      end

      it 'ignores the update' do
        put api("/projects/#{project.id}/issues/#{issue.iid}", user), params: { weight: 5 }

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['weight']).to be_nil
        expect(issue.reload.read_attribute(:weight)).to be_nil
      end
    end
  end

  describe 'PUT /projects/:id/issues/:issue_id to update epic' do
    it_behaves_like 'with epic parameter' do
      let(:issue_with_epic) { create(:issue, project: target_project) }
      let(:request) { put api("/projects/#{target_project.id}/issues/#{issue_with_epic.iid}", user), params: params }
    end
  end

  private

  def epic_issue_response_for(epic_issue)
    Array.wrap(json_response).find { |issue| issue['id'] == epic_issue.id }
  end
end
