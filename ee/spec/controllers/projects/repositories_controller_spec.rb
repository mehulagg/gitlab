# frozen_string_literal: true

require "spec_helper"

RSpec.describe Projects::RepositoriesController do
  let(:project) { create(:project, :repository) }

  describe "GET archive" do
    shared_examples 'logs the audit event' do
      it 'logs the audit event' do
        expect do
          get :archive, params: { namespace_id: project.namespace, project_id: project, id: "master" }, format: "zip"
        end.to change { AuditEvent.count }.by(1)
      end
    end

    context 'when unauthenticated', 'for a public project' do
      it_behaves_like 'logs the audit event' do
        let(:project) { create(:project, :repository, :public) }
      end
    end

    context 'when authenticated', 'as a developer' do
      before do
        project.add_developer(user)
        sign_in(user)
      end

      it_behaves_like 'logs the audit event' do
        let(:user) { create(:user) }
      end
    end
  end
end
