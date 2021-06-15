# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Ci::JobTokenScope::AddProjectService do
  let(:service) { described_class.new(project, current_user) }

  let_it_be(:project) { create(:project) }
  let_it_be(:target_project) { create(:project) }
  let_it_be(:current_user) { create(:user) }

  describe '#execute' do
    subject(:result) { service.execute(target_project) }

    shared_examples 'returns error' do |error|
      it 'returns an error response', :aggregate_failures do
        expect(result).to be_error
        expect(result.message).to eq(error)
      end
    end

    context 'when user does not have permissions to edit the job token scope' do
      it_behaves_like 'returns error', 'Insufficient permissions to modify the job token scope'
    end

    context 'when user has permissions to edit the job token scope' do
      before do
        project.add_maintainer(current_user)
      end

      context 'when target project is not provided' do
        let(:target_project) { nil }

        it_behaves_like 'returns error', 'Target project must be provided'
      end

      context 'when target project is provided' do
        context 'when user does not have permissions to read the target project' do
          it_behaves_like 'returns error', 'Insufficient permissions to add the target project'
        end

        context 'when user has permissions to read the target project' do
          before do
            target_project.add_developer(current_user)
          end

          it 'adds the project to the scope' do
            expect do
              expect(result).to be_success
            end.to change { Ci::JobToken::ProjectScopeLink.count }.by(1)
          end
        end

        context 'when target project is same as the source project' do
          let(:target_project) { project }

          it_behaves_like 'returns error', "Target project can't be the same as the source project"
        end
      end
    end
  end
end
