# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Releases do
  let(:project) { create(:project, :repository, :private) }
  let(:maintainer) { create(:user) }
  let(:reporter) { create(:user) }
  let(:developer) { create(:user) }
  let(:guest) { create(:user) }
  let(:non_project_member) { create(:user) }
  let(:commit) { create(:commit, project: project) }

  before do
    project.add_maintainer(maintainer)
    project.add_reporter(reporter)
    project.add_guest(guest)
    project.add_developer(developer)

    project.repository.add_tag(maintainer, 'v0.1', commit.id)
    project.repository.add_tag(maintainer, 'v0.2', commit.id)
  end

  describe 'POST /projects/:id/releases' do
    let(:params) do
      {
        name: 'New release',
        tag_name: 'v0.1',
        description: 'Super nice release'
      }
    end

    context 'updates the audit log' do
      subject { AuditEvent.last.details }

      it 'without milestone' do
        expect do
          post api("/projects/#{project.id}/releases", maintainer), params: params
        end.to change { AuditEvent.count }.by(1)

        release = project.releases.last

        expect(subject[:custom_message]).to eq("Created Release #{release.tag}")
        expect(subject[:target_type]).to eq('Release')
        expect(subject[:target_id]).to eq(release.id)
        expect(subject[:target_details]).to eq(release.name)
      end

      context 'with milestone' do
        let!(:milestone) { create(:milestone, project: project, title: 'v1.0') }

        it do
          expect do
            post api("/projects/#{project.id}/releases", maintainer), params: params.merge(milestones: ['v1.0'])
          end.to change { AuditEvent.count }.by(1)

          release = project.releases.last

          expect(subject[:custom_message]).to eq("Created Release v0.1 with Milestone v1.0")
          expect(subject[:target_type]).to eq('Release')
          expect(subject[:target_id]).to eq(release.id)
          expect(subject[:target_details]).to eq(release.name)
        end
      end
    end
  end

  describe 'PUT /projects/:id/releases/:tag_name' do
    let(:params) { { description: 'Best release ever!' } }

    let!(:release) do
      create(:release,
             project: project,
             tag: 'v0.1',
             name: 'New release',
             released_at: '2018-03-01T22:00:00Z',
             description: 'Super nice release')
    end

    it 'updates the audit log when a release is updated' do
      params = { name: 'A new name', description: 'a new description' }

      expect do
        put api("/projects/#{project.id}/releases/v0.1", maintainer), params: params
      end.to change { AuditEvent.count }.by(1)

      release = project.releases.last

      expect(AuditEvent.last.details[:custom_message]).to eq("Updated Release #{release.tag}")
    end

    shared_examples 'update with milestones' do
      it do
        expect do
          put api("/projects/#{project.id}/releases/v0.1", maintainer), params: params.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
        end.to change { AuditEvent.count }.by(2)

        release = project.releases.last

        expect(AuditEvent.first.details[:custom_message]).to eq("Updated Release #{release.tag}")
        expect(AuditEvent.second.details[:custom_message]).to eq(milestone_message)
      end
    end

    context 'with milestones' do
      context 'no existing milestones' do
        let!(:milestone) { create(:milestone, project: project, title: 'v1.0') }

        context 'add single milestone' do
          let(:params) { { milestones: ['v1.0'] } }
          let(:milestone_message) { "Milestones associated with release changed to v1.0" }

          it_behaves_like 'update with milestones'
        end

        context 'add multiple milestones' do
          let!(:milestone2) { create(:milestone, project: project, title: 'v2.0') }
          let(:params) { { milestones: ['v1.0', 'v2.0'] } }
          let(:milestone_message) { "Milestones associated with release changed to v1.0, v2.0" }

          it_behaves_like 'update with milestones'
        end
      end

      context 'existing milestone' do
        let!(:existing_milestone) { create(:milestone, project: project, title: 'v0.1') }
        let!(:milestone) { create(:milestone, project: project, title: 'v1.0') }

        before do
          release.milestones << existing_milestone
        end

        context 'add milestone' do
          let(:params) { { milestones: ['v0.1', 'v1.0'] } }
          let(:milestone_message) { "Milestones associated with release changed to v0.1, v1.0" }

          it_behaves_like 'update with milestones'
        end

        context 'replace milestone' do
          let(:params) { { milestones: ['v1.0'] } }
          let(:milestone_message) { "Milestones associated with release changed to v1.0" }

          it_behaves_like 'update with milestones'
        end

        context 'remove all milestones' do
          let(:params) { { milestones: [] } }
          let(:milestone_message) { "Milestones associated with release changed to [none]" }

          it_behaves_like 'update with milestones'
        end
      end
    end
  end

  describe 'POST /projects/:id/releases/:tag_name/evidence' do
    let(:tag_name) { 'v0.1' }
    let!(:release) do
      create(:release,
             project: project,
             tag: 'v0.1',
             name: 'New release',
             description: 'Super nice release')
    end

    it 'accepts the request' do
      post api("/projects/#{project.id}/releases/#{tag_name}/evidence", maintainer)

      expect(response).to have_gitlab_http_status(:accepted)
    end

    it 'creates the Evidence', :sidekiq_inline do
      expect do
        post api("/projects/#{project.id}/releases/#{tag_name}/evidence", maintainer)
      end.to change { Releases::Evidence.count }.by(1)
    end

    context 'when tag_name is invalid' do
      let(:tag_name) { 'v9.5.0' }

      it 'returns a 404' do
        post api("/projects/#{project.id}/releases/#{tag_name}/evidence", maintainer)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is a reporter' do
      it 'forbids the request' do
        post api("/projects/#{project.id}/releases/#{tag_name}/evidence", reporter)

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'when user is a developer' do
      it 'accepts the request' do
        post api("/projects/#{project.id}/releases/#{tag_name}/evidence", developer)

        expect(response).to have_gitlab_http_status(:accepted)
      end
    end

    context 'when user is not a project member' do
      it 'forbids the request' do
        post api("/projects/#{project.id}/releases/#{tag_name}/evidence", non_project_member)

        expect(response).to have_gitlab_http_status(:not_found)
      end

      context 'when project is public' do
        let(:project) { create(:project, :repository, :public) }

        it 'forbids the request' do
          post api("/projects/#{project.id}/releases/#{tag_name}/evidence", non_project_member)

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end
    end
  end
end
