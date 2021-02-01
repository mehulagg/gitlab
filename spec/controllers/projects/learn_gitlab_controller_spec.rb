# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::LearnGitlabController do
  describe 'GET #index' do
    using RSpec::Parameterized::TableSyntax

    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project, namespace: user.namespace) }

    let(:params) { { namespace_id: project.namespace.to_param, project_id: project } }

    subject { get :index, params: params }

    where(:is_com, :experiment_a, :experiment_b, :onboarded, :success) do
      true    | true        | false         | true      | true
      true    | false       | true          | true      | true
      true    | false       | false         | true      | false
      false   | true        | true          | true      | false
      true    | true        | true          | false     | false
    end

    with_them do
      before do
        allow(Gitlab).to receive(:com?).and_return(is_com)
        stub_experiment(learn_gitlab_a: experiment_a, learn_gitlab_b: experiment_b)
        stub_experiment_for_subject(learn_gitlab_a: experiment_a, learn_gitlab_b: experiment_b)
        allow(OnboardingProgress).to receive(:onboarded?).with(project.namespace).and_return(onboarded)

        sign_in(user)
      end

      it do
        if success
          expect(subject).to render_template(:index)
        else
          expect(subject).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end
end
