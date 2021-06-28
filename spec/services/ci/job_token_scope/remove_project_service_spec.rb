# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Ci::JobTokenScope::RemoveProjectService do
  let(:service) { described_class.new(project, current_user) }

  let_it_be(:project) { create(:project, ci_job_token_scope_enabled: true).tap(&:save!) }
  let_it_be(:target_project) { create(:project) }
  let_it_be(:current_user) { create(:user) }

  let_it_be(:link) do
    create(:ci_job_token_project_scope_link,
      source_project: project,
      target_project: target_project)
  end

  describe '#execute' do
    subject(:result) { service.execute(target_project) }

    it_behaves_like 'editable job token scope' do
      context 'when user has permissions on source and target project' do
        before do
          project.add_maintainer(current_user)
          target_project.add_developer(current_user)
        end

        it 'temporarily disallows the operation' do
          expect(result).to be_error
          expect(result.message).to eq('Job token scope is disabled for this project')
        end
      end

      context 'when target project is same as the source project' do
        before do
          project.add_maintainer(current_user)
        end

        let(:target_project) { project }

        it_behaves_like 'returns error', "Job token scope is disabled for this project"
      end
    end
  end
end
