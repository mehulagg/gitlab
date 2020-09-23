# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::GitHttpController, type: :request do
  include GitHttpHelpers
  include ::EE::GeoHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :repository, :private) }
  let(:env) { { user: user.username, password: user.password } }
  let(:path) { "#{project.full_path}.git" }

  before do
    project.add_developer(user)
  end

  describe 'GET #info_refs' do
    context 'smartcard session required' do
      subject { clone_get(path, env) }

      before do
        stub_licensed_features(smartcard_auth: true)
        stub_smartcard_setting(enabled: true, required_for_git_access: true)

        project.add_developer(user)
      end

      context 'user with a smartcard session', :clean_gitlab_redis_shared_state do
        let(:session_id) { '42' }
        let(:stored_session) do
          { 'smartcard_signins' => { 'last_signin_at' => 5.minutes.ago } }
        end

        before do
          Gitlab::Redis::SharedState.with do |redis|
            redis.set("session:gitlab:#{session_id}", Marshal.dump(stored_session))
            redis.sadd("session:lookup:user:gitlab:#{user.id}", [session_id])
          end
        end

        it "allows access" do
          subject

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'user without a smartcard session' do
        it "does not allow access" do
          subject

          expect(response).to have_gitlab_http_status(:forbidden)
          expect(response.body).to eq('Project requires smartcard login. Please login to GitLab using a smartcard.')
        end
      end

      context 'with the setting off' do
        before do
          stub_smartcard_setting(required_for_git_access: false)
        end

        it "allows access" do
          subject

          expect(response).to have_gitlab_http_status(:ok)
        end
      end
    end
  end

  describe 'POST #git_receive_pack' do
    subject { push_post(path, env) }

    context 'when node is a primary Geo one' do
      before do
        stub_primary_node
      end

      shared_examples 'triggers Geo' do
        it 'executes ::Gitlab::Geo::GitPushHttp' do
          expect_next_instance_of(::Gitlab::Geo::GitPushHttp) do |instance|
            expect(instance).to receive(:cache_referrer_node)
          end

          subject
        end

        it 'returns 200' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'with projects' do
        it_behaves_like 'triggers Geo'
      end

      context 'with personal snippet' do
        let_it_be(:snippet) { create(:personal_snippet, :repository, author: user) }
        let(:path) { "snippets/#{snippet.id}.git" }

        it_behaves_like 'triggers Geo'
      end

      context 'with project snippet' do
        let_it_be(:snippet) { create(:project_snippet, :repository, author: user, project: project) }
        let(:path) { "#{project.full_path}/snippets/#{snippet.id}.git" }

        it_behaves_like 'triggers Geo'
      end
    end
  end
end
