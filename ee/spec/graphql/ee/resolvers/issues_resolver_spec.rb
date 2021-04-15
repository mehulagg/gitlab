# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::IssuesResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group, skip_disk_validation: true) }

  context "with a project" do
    describe '#resolve' do
      let_it_be(:epic1) { create :epic, group: group }
      let_it_be(:epic2) { create :epic, group: group }

      let_it_be(:iteration1) { create(:iteration, group: group, start_date: 2.weeks.ago, due_date: 1.week.ago) }
      let_it_be(:current_iteration) { create(:iteration, :started, group: group, start_date: Date.today, due_date: 1.day.from_now) }

      let_it_be(:issue1) { create :issue, project: project, epic: epic1, iteration: iteration1 }
      let_it_be(:issue2) { create :issue, project: project, epic: epic2, weight: 1 }
      let_it_be(:issue3) { create :issue, project: project, weight: 3, iteration: current_iteration }
      let_it_be(:issue4) { create :issue, :published, project: project }

      before do
        project.add_developer(current_user)
      end

      describe 'sorting' do
        context 'when sorting by weight' do
          it 'sorts issues ascending' do
            expect(resolve_issues(sort: :weight_asc).to_a).to eq [issue2, issue3, issue4, issue1]
          end

          it 'sorts issues descending' do
            expect(resolve_issues(sort: :weight_desc).to_a).to eq [issue3, issue2, issue4, issue1]
          end
        end

        context 'when sorting by published' do
          it 'sorts issues ascending' do
            expect(resolve_issues(sort: :published_asc).to_a).to eq [issue3, issue2, issue1, issue4]
          end

          it 'sorts issues descending' do
            expect(resolve_issues(sort: :published_desc).to_a).to eq [issue4, issue3, issue2, issue1]
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
            expect(resolve_issues(sort: :sla_due_at_asc).to_a).to eq [sla_due_first, sla_due_last]
          end

          it 'sorts issues descending' do
            expect(resolve_issues(sort: :sla_due_at_desc).to_a).to eq [sla_due_last, sla_due_first]
          end
        end
      end

      describe 'filtering by iteration' do
        it 'returns issues with iteration' do
          expect(resolve_issues(iteration_id: [iteration1.id.to_s])).to contain_exactly(issue1)
        end
      end

      describe 'filter by epic' do
        it 'returns issues without epic when epic_id is "none"' do
          expect(resolve_issues(epic_id: 'none')).to contain_exactly(issue4, issue3)
        end

        it 'returns issues with any epic when epic_id is "any"' do
          expect(resolve_issues(epic_id: 'any')).to contain_exactly(issue1, issue2)
        end

        it 'returns issues with any epic when epic_id is specific' do
          expect(resolve_issues(epic_id: epic1.id.to_s)).to contain_exactly(issue1)
        end
      end

      describe 'filter by weight' do
        context 'when filtering by any weight' do
          it 'only returns issues that have a weight assigned' do
            expect(resolve_issues(weight: 'any')).to contain_exactly(issue2, issue3)
          end
        end

        context 'when filtering by no weight' do
          it 'only returns issues that have no weight assigned' do
            expect(resolve_issues(weight: 'none')).to contain_exactly(issue1, issue4)
          end
        end

        context 'when filtering by specific weight' do
          it 'only returns issues that have the specified weight assigned' do
            expect(resolve_issues(weight: '3')).to contain_exactly(issue3)
          end
        end
      end

      describe 'filtering by negated params' do
        describe 'filter by negated epic' do
          it 'returns issues without the specified epic_id' do
            expect(resolve_issues(not: { epic_id: epic2.id.to_s })).to contain_exactly(issue1, issue3, issue4)
          end
        end

        describe 'filtering by negated weight' do
          it 'only returns issues that do not have the specified weight assigned' do
            expect(resolve_issues(not: { weight: '3' })).to contain_exactly(issue1, issue2, issue4)
          end
        end
      end
    end
  end

  def resolve_issues(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
