# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::LearnGitlabController do
  include AfterNextHelpers

  describe 'GET #index' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project, namespace: user.namespace) }

    let(:experiment_enabled) { true }
    let(:params) { { namespace_id: project.namespace.to_param, project_id: project } }

    subject { get :index, params: params }

    before do
      allow_next(Namespaces::LearnGitlabExperiment, user, project.namespace).to receive(:enabled?).and_return(experiment_enabled)
    end

    context 'unauthenticated user' do
      it { is_expected.to have_gitlab_http_status(:redirect) }
    end

    context 'authenticated user' do
      before do
        sign_in(user)
      end

      it { is_expected.to render_template(:index) }

      it 'pushes experiment to frontend' do
        expect(controller).to receive(:push_frontend_experiment).with(:learn_gitlab_a, subject: user)
        expect(controller).to receive(:push_frontend_experiment).with(:learn_gitlab_b, subject: user)

        subject
      end

      context 'learn_gitlab experiment not enabled' do
        let(:experiment_enabled) { false }

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end
    end
  end
end
