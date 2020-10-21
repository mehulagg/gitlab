# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Ci::LintsController do
  include StubRequests

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'GET #show' do
    context 'with enough privileges' do
      before do
        project.add_developer(user)

        get :show, params: { namespace_id: project.namespace, project_id: project }
      end

      it { expect(response).to have_gitlab_http_status(:ok) }

      it 'renders show page' do
        expect(response).to render_template :show
      end

      it 'retrieves project' do
        expect(assigns(:project)).to eq(project)
      end
    end

    context 'without enough privileges' do
      before do
        project.add_guest(user)

        get :show, params: { namespace_id: project.namespace, project_id: project }
      end

      it 'responds with 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: params }

    let(:format) { :html }
    let(:params) { { namespace_id: project.namespace, project_id: project, content: content, format: format } }
    let(:remote_file_path) { 'https://gitlab.com/gitlab-org/gitlab-foss/blob/1234/.gitlab-ci-1.yml' }

    let(:remote_file_content) do
      <<~HEREDOC
      before_script:
        - apt-get update -qq && apt-get install -y -qq sqlite3 libsqlite3-dev nodejs
        - ruby -v
        - which ruby
        - bundle install --jobs $(nproc)  "${FLAGS[@]}"
      HEREDOC
    end

    let(:content) do
      <<~HEREDOC
      include:
        - #{remote_file_path}

      rubocop:
        script:
          - bundle exec rubocop
      HEREDOC
    end

    shared_examples 'successful request with format json' do
      context 'with format json' do
        let(:format) { :json }
        let(:parsed_body) { Gitlab::Json.parse(response.body) }

        it 'renders json' do
          expect(response).to have_gitlab_http_status :ok
          expect(response.content_type).to eq 'application/json'
          expect(parsed_body).to include('errors', 'warnings', 'jobs', 'valid')
          expect(parsed_body).to match_schema('entities/lint_result_entity')
        end
      end
    end

    context 'with a valid gitlab-ci.yml' do
      before do
        stub_full_request(remote_file_path).to_return(body: remote_file_content)
        project.add_developer(user)
      end

      shared_examples 'returns a successful validation' do
        before do
          subject
        end

        it 'returns successfully' do
          expect(response).to have_gitlab_http_status :ok
        end

        it 'renders show page' do
          expect(response).to render_template :show
        end

        it 'retrieves project' do
          expect(assigns(:project)).to eq(project)
        end

        it_behaves_like 'successful request with format json'
      end

      context 'using legacy validation (YamlProcessor)' do
        it_behaves_like 'returns a successful validation'

        it 'runs validations through YamlProcessor' do
          expect(Gitlab::Ci::YamlProcessor).to receive(:new).and_call_original

          subject
        end
      end

      context 'using dry_run mode' do
        subject { post :create, params: params.merge(dry_run: 'true') }

        it_behaves_like 'returns a successful validation'

        it 'runs validations through Ci::CreatePipelineService' do
          expect(Ci::CreatePipelineService)
            .to receive(:new)
            .with(project, user, ref: 'master')
            .and_call_original

          subject
        end

        context 'when dry_run feature flag is disabled' do
          before do
            stub_feature_flags(ci_lint_creates_pipeline_with_dry_run: false)
          end

          it_behaves_like 'returns a successful validation'

          it 'runs validations through YamlProcessor' do
            expect(Gitlab::Ci::YamlProcessor).to receive(:new).and_call_original

            subject
          end
        end
      end
    end

    context 'with an invalid gitlab-ci.yml' do
      let(:content) do
        <<~HEREDOC
        rubocop:
          scriptt:
            - bundle exec rubocop
        HEREDOC
      end

      before do
        project.add_developer(user)
        subject
      end

      it 'assigns result with errors' do
        expect(assigns[:result].errors).to match_array([
          'jobs rubocop config should implement a script: or a trigger: keyword',
          'jobs config should contain at least one visible job'
        ])
      end

      it 'render show page' do
        expect(response).to render_template :show
      end

      it_behaves_like 'successful request with format json'

      context 'with dry_run mode' do
        subject { post :create, params: params.merge(dry_run: 'true') }

        it 'assigns result with errors' do
          expect(assigns[:result].errors).to eq(['jobs rubocop config should implement a script: or a trigger: keyword'])
        end

        it_behaves_like 'successful request with format json'
      end
    end

    context 'without enough privileges' do
      before do
        project.add_guest(user)

        post :create, params: { namespace_id: project.namespace, project_id: project, content: content }
      end

      it 'responds with 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end

      context 'with format json' do
        let(:format) { :json }

        it 'responds with 404' do
          expect(response).to have_gitlab_http_status :not_found
        end
      end
    end
  end
end
