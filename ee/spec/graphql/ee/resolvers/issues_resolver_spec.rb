# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::IssuesResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group, skip_disk_validation: true) }

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

        context 'when sorting by published' do
          let_it_be(:not_published) { create(:issue, project: project) }
          let_it_be(:published) { create(:issue, :published, project: project) }

          it 'sorts issues ascending' do
            expect(resolve_issues(sort: :published_asc)).to eq [not_published, published]
          end

          it 'sorts issues descending' do
            expect(resolve_issues(sort: :published_desc)).to eq [published, not_published]
          end
        end

        context 'when sorting by sla due at' do
          let_it_be(:sla_due_first) { create(:incident, project: project) }
          let_it_be(:sla_due_last)  { create(:incident, project: project) }

          before_all do
            create(:issuable_sla, :exceeded, issue: sla_due_first)
            create(:issuable_sla, issue: sla_due_last)
          end

          it 'sorts issues ascending' do
            expect(resolve_issues(sort: :sla_due_at_asc)).to eq [sla_due_first, sla_due_last]
          end

          it 'sorts issues descending' do
            expect(resolve_issues(sort: :sla_due_at_desc)).to eq [sla_due_last, sla_due_first]
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

      describe 'filter by epic' do
        let_it_be(:epic) { create :epic, group: group }
        let_it_be(:epic2) { create :epic, group: group }
        let_it_be(:issue1) { create :issue, project: project, epic: epic }
        let_it_be(:issue2) { create :issue, project: project, epic: epic2 }
        let_it_be(:issue3) { create :issue, project: project }

        it 'returns issues without epic when epic_id is "none"' do
          expect(resolve_issues(epic_id: 'none')).to match_array([issue3])
        end

        it 'returns issues with any epic when epic_id is "any"' do
          expect(resolve_issues(epic_id: 'any')).to match_array([issue1, issue2])
        end

        it 'returns issues with any epic when epic_id is specific' do
          expect(resolve_issues(epic_id: epic.id)).to match_array([issue1])
        end
      end
    end
  end

  def resolve_issues(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
