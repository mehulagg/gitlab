# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Issues::Update do
  let(:user) { create(:user) }

  it_behaves_like 'updating health status' do
    let(:resource) { create(:issue) }
  end

  context 'updating parent epic' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, group: group) }
    let_it_be(:issue) { create(:issue, project: project) }
    let_it_be(:epic) { create(:epic, group: group) }

    let(:epic_id) { epic.to_global_id.to_s }
    let(:params) { { project_path: project.full_path, iid: issue.iid, epic_id: epic_id } }
    let(:mutated_issue) { subject[:issue] }
    let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

    subject { mutation.resolve(params) }

    context 'when epics feature is disabled' do
      it 'raises an error' do
        group.add_developer(user)

        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when epics feature is enabled' do
      before do
        stub_licensed_features(epics: true)
      end

      context 'for user without permissions' do
        it 'raises an error' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'for user with correct permissions' do
        before do
          group.add_developer(user)
        end

        context 'when a valid epic is given' do
          it 'updates the epic' do
            expect { subject }.to change { issue.reload.epic }.from(nil).to(epic)
          end

          it 'returns the updated issue' do
            expect(mutated_issue.epic).to eq(epic)
          end
        end

        context 'when nil epic is given' do
          before do
            issue.update!(epic: epic)
          end

          let(:epic_id) { nil }

          it 'set the epic to nil' do
            expect { subject }.to change { issue.reload.epic }.from(epic).to(nil)
          end

          it 'returns the updated issue' do
            expect(mutated_issue.epic).to be_nil
          end
        end
      end
    end
  end
end
