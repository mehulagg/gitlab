# -*- coding: utf-8 -*-
require 'spec_helper'

describe API::ProjectMirror do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:project) { create(:project, namespace: user.namespace) }

  describe 'POST /projects/:id/mirror/pull' do
    context 'when the project is not mirrored' do
      it 'returns error' do
        allow(project).to receive(:mirror?).and_return(false)

        post api("/projects/#{project.id}/mirror/pull", user)

        expect(response).to have_gitlab_http_status(400)
      end
    end

    context 'when the project is mirrored' do
      before do
        allow_any_instance_of(Projects::UpdateMirrorService).to receive(:execute).and_return(status: :success)
      end

      context 'when import state is' do
        def project_in_state(state)
          project = create(:project, :repository, namespace: user.namespace)
          import_state = create(:import_state, :mirror, state, project: project)
          import_state.update(next_execution_timestamp: 10.minutes.from_now)

          project
        end

        it 'none it triggers the pull mirroring operation' do
          project = project_in_state(:none)

          expect(UpdateAllMirrorsWorker).to receive(:perform_async).once

          post api("/projects/#{project.id}/mirror/pull", user)

          expect(response).to have_gitlab_http_status(200)
        end

        it 'failed it triggers the pull mirroring operation' do
          project = project_in_state(:failed)

          expect(UpdateAllMirrorsWorker).to receive(:perform_async).once

          post api("/projects/#{project.id}/mirror/pull", user)

          expect(response).to have_gitlab_http_status(200)
        end

        it 'finished it triggers the pull mirroring operation' do
          project = project_in_state(:finished)

          expect(UpdateAllMirrorsWorker).to receive(:perform_async).once

          post api("/projects/#{project.id}/mirror/pull", user)

          expect(response).to have_gitlab_http_status(200)
        end

        it 'scheduled does not trigger the pull mirroring operation and returns 200' do
          project = project_in_state(:scheduled)

          expect(UpdateAllMirrorsWorker).not_to receive(:perform_async)

          post api("/projects/#{project.id}/mirror/pull", user)

          expect(response).to have_gitlab_http_status(200)
        end

        it 'started does not trigger the pull mirroring operation and returns 200' do
          project = project_in_state(:started)

          expect(UpdateAllMirrorsWorker).not_to receive(:perform_async)

          post api("/projects/#{project.id}/mirror/pull", user)

          expect(response).to have_gitlab_http_status(200)
        end
      end

      context 'when user' do
        let(:project_mirrored) { create(:project, :repository, :mirror, :import_finished, namespace: user.namespace) }

        def project_member(role, user)
          create(:project_member, role, user: user, project: project_mirrored)
        end

        context 'is unauthenticated' do
          it 'returns authentication error' do
            post api("/projects/#{project_mirrored.id}/mirror/pull")

            expect(response).to have_gitlab_http_status(401)
          end
        end

        context 'is authenticated as developer' do
          it 'returns forbidden error' do
            project_member(:developer, user2)

            post api("/projects/#{project_mirrored.id}/mirror/pull", user2)

            expect(response).to have_gitlab_http_status(403)
          end
        end

        context 'is authenticated as reporter' do
          it 'returns forbidden error' do
            project_member(:reporter, user2)

            post api("/projects/#{project_mirrored.id}/mirror/pull", user2)

            expect(response).to have_gitlab_http_status(403)
          end
        end

        context 'is authenticated as guest' do
          it 'returns forbidden error' do
            project_member(:guest, user2)

            post api("/projects/#{project_mirrored.id}/mirror/pull", user2)

            expect(response).to have_gitlab_http_status(403)
          end
        end

        context 'is authenticated as maintainer' do
          it 'triggers the pull mirroring operation' do
            project_member(:maintainer, user2)

            post api("/projects/#{project_mirrored.id}/mirror/pull", user2)

            expect(response).to have_gitlab_http_status(200)
          end
        end

        context 'is authenticated as owner' do
          it 'triggers the pull mirroring operation' do
            post api("/projects/#{project_mirrored.id}/mirror/pull", user)

            expect(response).to have_gitlab_http_status(200)
          end
        end
      end

      context 'authenticating from GitHub signature' do
        let(:visibility) { Gitlab::VisibilityLevel::PUBLIC }
        let(:project_mirrored) { create(:project, :repository, :mirror, :import_finished, visibility: visibility) }

        def do_post
          post api("/projects/#{project_mirrored.id}/mirror/pull"), params: {}, headers: { 'X-Hub-Signature' => 'signature' }
        end

        context "when it's valid" do
          before do
            Grape::Endpoint.before_each do |endpoint|
              allow(endpoint).to receive(:project).and_return(project_mirrored)
              allow(endpoint).to receive(:valid_github_signature?).and_return(true)
            end
          end

          it 'syncs the mirror' do
            expect(project_mirrored.import_state).to receive(:force_import_job!)

            do_post
          end
        end

        context "when it's invalid" do
          before do
            Grape::Endpoint.before_each do |endpoint|
              allow(endpoint).to receive(:project).and_return(project_mirrored)
              allow(endpoint).to receive(:valid_github_signature?).and_return(false)
            end
          end

          after do
            Grape::Endpoint.before_each nil
          end

          it "doesn't sync the mirror" do
            expect(project_mirrored.import_state).not_to receive(:force_import_job!)

            post api("/projects/#{project_mirrored.id}/mirror/pull"), params: {}, headers: { 'X-Hub-Signature' => 'signature' }
          end

          context 'with a public project' do
            let(:visibility) { Gitlab::VisibilityLevel::PUBLIC }

            it 'returns a 401 status' do
              do_post

              expect(response).to have_gitlab_http_status(401)
            end
          end

          context 'with an internal project' do
            let(:visibility) { Gitlab::VisibilityLevel::INTERNAL }

            it 'returns a 404 status' do
              do_post

              expect(response).to have_gitlab_http_status(404)
            end
          end

          context 'with a private project' do
            let(:visibility) { Gitlab::VisibilityLevel::PRIVATE }

            it 'returns a 404 status' do
              do_post

              expect(response).to have_gitlab_http_status(404)
            end
          end
        end
      end
    end
  end

  describe 'DELETE /projects/:project_id/mirror' do
    let(:project) { create(:project, :mirror) }
    let(:endpoint) { endpoint_path(project.id) }

    case_name = lambda {|user_type| "like a project #{user_type}"}

    context 'as an authorized user' do
      let(:owner) { project.owner }
      let(:maintainer) { project.add_maintainer(create(:user)).user }
      let(:authorized_users) { { owner: owner, maintainer: maintainer } }

      where(case_names: case_name, user_type: [:owner, :maintainer])

      with_them do
        let(:user) { authorized_users[user_type] }

        it 'deletes mirror' do
          delete api(endpoint, user)

          project.reload

          expect(response).to have_gitlab_http_status(200)
          expect(project.import_data).to be_nil
          expect(project).not_to be_mirror
        end

        context 'for an invalid project id' do
          it_behaves_like '404 response' do
            let(:message) { '404 Project Not Found' }
            let(:request) { delete api(endpoint_path('4321'), user) }
          end
        end
      end
    end

    context 'as an unauthorized user' do
      let(:developer) { project.add_developer(create(:user)).user }
      let(:reporter) { project.add_reporter(create(:user)).user }
      let(:guest) { project.add_guest(create(:user)).user }
      let(:unauthorized_users) { { developer: developer, reporter: reporter, guest: guest } }

      where(case_names: case_name, user_type: [:developer, :reporter, :guest])

      with_them do
        let(:user) { unauthorized_users[user_type] }

        it_behaves_like '403 response' do
          let(:request) { delete api(endpoint, user) }
        end
      end

      context 'as an anonymous user' do
        it_behaves_like '401 response' do
          let(:request) { delete api(endpoint, nil) }
        end
      end
    end

    def endpoint_path(project_id)
      "/projects/#{project_id}/mirror"
    end
  end
end
