# frozen_string_literal: true

require 'spec_helper'

describe Issues::CreateService do
  let_it_be(:group) { create(:group) }
  let(:project) { create(:project, group: group) }
  let(:user) { create(:user) }
  let(:params) { { title: 'Awesome issue', description: 'please fix', weight: 9 } }
  let(:service) { described_class.new(project, user, params) }

  describe '#execute' do
    context 'when current user cannot admin issues in the project' do
      before do
        project.add_guest(user)
      end

      it 'filters out params that cannot be set without the :admin_issue permission' do
        issue = service.execute

        expect(issue).to be_persisted
        expect(issue.weight).to be_nil
      end
    end

    context 'when current user can admin issues in the project' do
      before do
        stub_licensed_features(epics: true)
        project.add_reporter(user)
      end

      it 'sets permitted params correctly' do
        issue = service.execute

        expect(issue).to be_persisted
        expect(issue.weight).to eq(9)
      end

      context 'when epics are enabled' do
        let_it_be(:epic) { create(:epic, group: group, start_date_is_fixed: false, due_date_is_fixed: false) }

        before do
          stub_licensed_features(epics: true)
          project.add_reporter(user)
        end

        it_behaves_like 'issue with epic_id parameter' do
          let(:execute) { service.execute }
        end

        context 'when using quick actions' do
          before do
            group.add_reporter(user)
          end

          context '/epic action' do
            let(:params) { { title: 'New issue', description: "/epic #{epic.to_reference(project)}" } }

            it 'adds an issue to the passed epic' do
              issue = service.execute

              expect(issue).to be_persisted
              expect(issue.epic).to eq(epic)
            end
          end

          context 'with epic and milestone in commands only' do
            let(:milestone) { create(:milestone, group: group, start_date: Date.current, due_date: 7.days.from_now) }
            let(:params) do
              {
                title: 'Awesome issue',
                description: %(/epic #{epic.to_reference}\n/milestone #{milestone.to_reference}")
              }
            end

            it 'sets epic and milestone to issuable and update epic start and due date' do
              issue = service.execute

              expect(issue.milestone).to eq(milestone)
              expect(issue.epic).to eq(epic)
              expect(epic.reload.start_date).to eq(milestone.start_date)
              expect(epic.due_date).to eq(milestone.due_date)
            end
          end
        end
      end
    end

    it_behaves_like 'new issuable with scoped labels' do
      let(:parent) { project }
    end

    describe 'publish to status page' do
      let(:execute) { service.execute }
      let(:issue_id) { execute&.id }

      context 'when creation succeeds' do
        let_it_be(:params) { { title: 'New title' } }

        include_examples 'trigger status page publish'
      end

      context 'when creation fails' do
        let_it_be(:params) { { title: nil } }

        include_examples 'no trigger status page publish'
      end
    end
  end
end
