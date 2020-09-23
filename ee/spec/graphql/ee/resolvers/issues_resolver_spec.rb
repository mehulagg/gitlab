# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::IssuesResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }

  context "with a project" do
    describe '#resolve' do
      before do
        project.add_developer(current_user)
      end

      describe 'sorting' do
        context 'when sorting by weight' do
          let_it_be(:weight_issue1) { create(:issue, project: project, weight: 5) }
          let_it_be(:weight_issue2) { create(:issue, project: project, weight: nil) }
          let_it_be(:weight_issue3) { create(:issue, project: project, weight: 1) }
          let_it_be(:weight_issue4) { create(:issue, project: project, weight: nil) }

          it 'sorts issues ascending' do
            expect(resolve_issues(sort: :weight_asc)).to eq [weight_issue3, weight_issue1, weight_issue4, weight_issue2]
          end

          it 'sorts issues descending' do
            expect(resolve_issues(sort: :weight_desc)).to eq [weight_issue1, weight_issue3, weight_issue4, weight_issue2]
          end
        end
      end

      describe 'filtering by iteration' do
        let_it_be(:iteration1) { create(:iteration, group: group) }
        let_it_be(:issue_with_iteration) { create(:issue, project: project, iteration: iteration1) }
        let_it_be(:issue_without_iteration) { create(:issue, project: project) }

        it 'returns issues with iteration' do
          expect(resolve_issues(iteration_id: iteration1.id)).to eq [issue_with_iteration]
        end
      end
    end
  end

  def resolve_issues(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
