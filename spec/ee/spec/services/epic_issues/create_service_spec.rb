require 'spec_helper'

describe EpicIssues::CreateService do
  describe '#execute' do
    let(:group) { create :group }
    let(:epic) { create :epic, group: group }
    let(:project) { create(:project, group: group) }
    let(:issue) { create :issue, project: project }
    let(:user) { create :user }
    let(:valid_reference) { issue.to_reference(full: true) }

    def assign_issue(references)
      params = { issue_references: references }

      described_class.new(epic, user, params).execute
    end

    shared_examples 'returns success' do
      it 'creates relationships' do
        expect { subject }.to change(EpicIssue, :count).from(0).to(1)

        expect(EpicIssue.find_by!(issue_id: issue.id)).to have_attributes(epic: epic)
      end

      it 'returns success status' do
        expect(subject).to eq(status: :success)
      end

      it 'creates 2 system notes' do
        expect { subject }.to change { Note.count }.from(0).to(2)
      end

      it 'creates a note for epic correctly' do
        subject
        note = Note.find_by(noteable_id: epic.id, noteable_type: 'Epic')

        expect(note.note).to eq("added issue #{issue.to_reference(epic.group)}")
        expect(note.author).to eq(user)
        expect(note.project).to be_nil
        expect(note.noteable_type).to eq('Epic')
        expect(note.system_note_metadata.action).to eq('epic_issue_added')
      end

      it 'creates a note for issue correctly' do
        subject
        note = Note.find_by(noteable_id: issue.id, noteable_type: 'Issue')

        expect(note.note).to eq("added to epic #{epic.to_reference(issue.project)}")
        expect(note.author).to eq(user)
        expect(note.project).to eq(issue.project)
        expect(note.noteable_type).to eq('Issue')
        expect(note.system_note_metadata.action).to eq('issue_added_to_epic')
      end
    end

    shared_examples 'returns an error' do
      it 'returns an error' do
        expect(subject).to eq(message: 'No Issue found for given params', status: :error, http_status: 404)
      end

      it 'no relationship is created' do
        expect { subject }.not_to change { EpicIssue.count }
      end
    end

    context 'when epics feature is disabled' do
      subject { assign_issue([valid_reference]) }

      include_examples 'returns an error'
    end

    context 'when epics feature is enabled' do
      before do
        stub_licensed_features(epics: true)
      end

      context 'when user has permissions to link the issue' do
        before do
          group.add_developer(user)
        end

        context 'when the reference list is empty' do
          it 'returns an error' do
            expect(assign_issue([])).to eq(message: 'No Issue found for given params', status: :error, http_status: 404)
          end

          it 'does not create a system note' do
            expect { assign_issue([]) }.not_to change { Note.count }
          end
        end

        context 'when there is an issue to relate' do
          context 'when shortcut for Issue is given' do
            subject { assign_issue([issue.to_reference]) }

            include_examples 'returns an error'
          end

          context 'when a full reference is given' do
            subject { assign_issue([valid_reference]) }

            include_examples 'returns success'

            it 'does not perofrm N + 1 queries' do
              allow(SystemNoteService).to receive(:epic_issue)
              allow(SystemNoteService).to receive(:issue_on_epic)

              params = { issue_references: [valid_reference] }
              control_count = ActiveRecord::QueryRecorder.new { described_class.new(epic, user, params).execute }.count

              user = create(:user)
              group = create(:group)
              project = create(:project, group: group)
              issues = create_list(:issue, 5, project: project)
              epic = create(:epic, group: group)
              group.add_developer(user)

              params = { issue_references: issues.map { |i| i.to_reference(full: true) } }

              expect { described_class.new(epic, user, params).execute }.not_to exceed_query_limit(control_count)
            end
          end

          context 'when an issue link is given' do
            subject { assign_issue([IssuesHelper.url_for_issue(issue.iid, issue.project)]) }

            include_examples 'returns success'
          end

          context 'when a link of an issue in a subgroup is given', :nested_groups do
            let(:subgroup) { create(:group, parent: group) }
            let(:project2) { create(:project, group: subgroup) }
            let(:issue) { create(:issue, project: project2) }

            subject { assign_issue([IssuesHelper.url_for_issue(issue.iid, issue.project)]) }

            include_examples 'returns success'
          end
        end
      end

      context 'when user does not have permissions to link the issue' do
        subject { assign_issue([valid_reference]) }

        include_examples 'returns an error'
      end

      context 'when an issue is already assigned to another epic' do
        before do
          group.add_developer(user)
          create(:epic_issue, epic: epic, issue: issue)
        end

        let(:another_epic) { create(:epic, group: group) }

        subject do
          params = { issue_references: [valid_reference] }

          described_class.new(another_epic, user, params).execute
        end

        it 'does not create a new association' do
          expect { subject }.not_to change(EpicIssue, :count).from(1)
        end

        it 'updates the existing association' do
          expect { subject }.to change { EpicIssue.last.epic }.from(epic).to(another_epic)
        end

        it 'returns success status' do
          is_expected.to eq(status: :success)
        end
      end

      context 'when issue from non group project is given' do
        subject { assign_issue([another_issue.to_reference(full: true)]) }

        let(:another_issue) { create :issue }

        before do
          group.add_developer(user)
          another_issue.project.add_developer(user)
        end

        include_examples 'returns an error'
      end
    end
  end
end
