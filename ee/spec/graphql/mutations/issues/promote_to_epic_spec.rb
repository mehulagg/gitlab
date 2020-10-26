# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Mutations::Issues::PromoteToEpic do
  let(:new_epic_group) { nil }
  let(:group) { create(:group) }
  let(:project) { create(:project, group: group) }
  let(:issue) { create(:issue, project: project) }
  let(:user) { create(:user) }

  before do
    stub_licensed_features(epics: true)
  end

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  RSpec.shared_examples 'successfully promotes issue to epic' do
    it 'returns the issue and the epic', :aggregate_failures do
      expect(mutated_issue).to eq(issue)
      expect(mutated_issue.state).to eq('closed')
      expect(issue.reload.promoted_to_epic_id).to eq(epic.id)
      expect(epic).not_to be_nil
      expect(epic.title).to eq(issue.title)
      expect(epic.group).to eq(epic_group)
      expect(subject[:errors]).to be_empty
    end
  end

  describe '#resolve' do
    let(:mutated_issue) { subject[:issue] }
    let(:epic) { subject[:epic] }

    subject { mutation.resolve(project_path: issue.project.full_path, iid: issue.iid, epic_group_id: new_epic_group&.to_global_id) }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when issue is accessible to the user' do
      before do
        project.add_developer(user)
      end

      context 'when the user cannot promote the issue' do
        it 'returns the issue and the epic', :aggregate_failures do
          expect(mutated_issue).to eq(issue)
          expect(epic).to be_nil
          expect(subject[:errors]).to eq(['Cannot promote issue due to insufficient permissions.'])
        end
      end

      context 'when the user can promote the issue' do
        before do
          group.add_reporter(user)
        end

        it_behaves_like 'successfully promotes issue to epic' do
          let(:epic_group) { group }
        end

        context 'when promoting epic to a different group' do
          let(:new_epic_group) { create(:group) }

          before do
            new_epic_group.add_reporter(user)
          end

          it_behaves_like 'successfully promotes issue to epic' do
            let(:epic_group) { new_epic_group }
          end
        end

        context 'when an issue belongs to an epic' do
          let(:parent_epic) { create(:epic, group: group) }
          let!(:epic_issue) { create(:epic_issue, epic: parent_epic, issue: issue) }

          it_behaves_like 'successfully promotes issue to epic' do
            let(:epic_group) { group }
          end

          context 'when promoting epic to a different group within the hierarchy' do
            let(:new_epic_group) { create(:group, parent: group) }

            before do
              new_epic_group.add_reporter(user)
            end

            it_behaves_like 'successfully promotes issue to epic' do
              let(:epic_group) { new_epic_group }
            end
          end

          context 'when promoting epic to a different group out of hierarchy' do
            let(:new_epic_group) { create(:group) }

            before do
              new_epic_group.add_reporter(user)
            end

            it 'returns the issue and the epic', :aggregate_failures do
              expect(mutated_issue).to eq(issue)
              expect(mutated_issue.state).to eq('opened')
              expect(issue.reload.promoted_to_epic_id).to be_nil
              expect(epic).to be_nil
              expect(subject[:errors]).to eq(['Validation failed: Parent This epic cannot be added. An epic must belong to the same group or subgroup as its parent epic.'])
            end
          end
        end
      end
    end
  end
end
