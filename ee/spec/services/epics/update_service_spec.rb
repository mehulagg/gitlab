# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Epics::UpdateService do
  let(:group) { create(:group, :internal) }
  let(:user) { create(:user) }
  let(:epic) { create(:epic, group: group) }

  describe '#execute' do
    before do
      stub_licensed_features(epics: true)
      group.add_maintainer(user)
    end

    def find_note(starting_with)
      epic.notes.find do |note|
        note && note.note.start_with?(starting_with)
      end
    end

    def find_notes(action)
      epic
        .notes
        .joins(:system_note_metadata)
        .where(system_note_metadata: { action: action })
    end

    def update_epic(opts)
      described_class.new(group, user, opts).execute(epic)
    end

    context 'multiple values update' do
      let(:opts) do
        {
          title: 'New title',
          description: 'New description',
          start_date_fixed: '2017-01-09',
          start_date_is_fixed: true,
          due_date_fixed: '2017-10-21',
          due_date_is_fixed: true,
          state_event: 'close',
          confidential: true
        }
      end

      it 'updates the epic correctly' do
        update_epic(opts)

        expect(epic).to be_valid
        expect(epic).to have_attributes(opts.except(:due_date_fixed, :start_date_fixed))
        expect(epic).to have_attributes(
          start_date_fixed: Date.strptime(opts[:start_date_fixed]),
          due_date_fixed: Date.strptime(opts[:due_date_fixed]),
          confidential: true
        )
        expect(epic).to be_closed
      end

      it 'updates the last_edited_at value' do
        expect { update_epic(opts) }.to change { epic.last_edited_at }
      end
    end

    context 'when title has changed' do
      it 'creates system note about title change' do
        expect { update_epic(title: 'New title') }.to change { Note.count }.from(0).to(1)

        note = Note.last

        expect(note.note).to start_with('changed title')
        expect(note.noteable).to eq(epic)
      end
    end

    context 'when description has changed' do
      it 'creates system note about description change' do
        expect { update_epic(description: 'New description') }.to change { Note.count }.from(0).to(1)

        note = Note.last

        expect(note.note).to start_with('changed the description')
        expect(note.noteable).to eq(epic)
      end
    end

    context 'after_save callback to store_mentions' do
      let(:user2) { create(:user) }
      let(:epic) { create(:epic, group: group, description: "simple description") }
      let(:labels) { create_pair(:group_label, group: group) }

      context 'when mentionable attributes change' do
        let(:opts) { { description: "Description with #{user.to_reference}" } }

        it 'saves mentions' do
          expect(epic).to receive(:store_mentions!).and_call_original

          expect { update_epic(opts) }.to change { EpicUserMention.count }.by(1)

          expect(epic.referenced_users).to match_array([user])
        end
      end

      context 'when mentionable attributes do not change' do
        let(:opts) { { label_ids: labels.map(&:id) } }

        it 'does not call store_mentions!' do
          expect(epic).not_to receive(:store_mentions!).and_call_original

          expect { update_epic(opts) }.not_to change { EpicUserMention.count }

          expect(epic.referenced_users).to be_empty
        end
      end

      context 'when save fails' do
        let(:opts) { { title: '', label_ids: labels.map(&:id) } }

        it 'does not call store_mentions!' do
          expect(epic).not_to receive(:store_mentions!).and_call_original

          expect { update_epic(opts) }.not_to change { EpicUserMention.count }

          expect(epic.referenced_users).to be_empty
          expect(epic.valid?).to be false
        end
      end
    end

    context 'todos' do
      before do
        group.update(visibility: Gitlab::VisibilityLevel::PUBLIC)
      end

      context 'creating todos' do
        let(:mentioned1) { create(:user) }
        let(:mentioned2) { create(:user) }

        before do
          epic.update(description: "FYI: #{mentioned1.to_reference}")
        end

        it 'creates todos for only newly mentioned users' do
          expect do
            update_epic(description: "FYI: #{mentioned1.to_reference} #{mentioned2.to_reference}")
          end.to change { Todo.count }.by(1)
        end
      end

      context 'adding a label' do
        let(:label) { create(:group_label, group: group) }
        let(:user2) { create(:user) }
        let!(:todo1) do
          create(:todo, :mentioned, :pending,
            target: epic,
            group: group,
            project: nil,
            author: user,
            user: user)
        end

        let!(:todo2) do
          create(:todo, :mentioned, :pending,
            target: epic,
            group: group,
            project: nil,
            author: user2,
            user: user2)
        end

        before do
          group.add_developer(user)

          update_epic(label_ids: [label.id])
        end

        it 'marks todo as done for a user who added a label' do
          expect(todo1.reload.state).to eq('done')
        end

        it 'does not mark todos as done for other users' do
          expect(todo2.reload.state).to eq('pending')
        end
      end

      context 'mentioning a group in epic description' do
        let(:mentioned1) { create(:user) }
        let(:mentioned2) { create(:user) }

        before do
          group.add_developer(mentioned1)
          epic.update(description: "FYI: #{group.to_reference}")
        end

        context 'when the group is public' do
          before do
            group.update(visibility: Gitlab::VisibilityLevel::PUBLIC)
          end

          it 'creates todos for only newly mentioned users' do
            expect do
              update_epic(description: "FYI: #{mentioned1.to_reference} #{mentioned2.to_reference}")
            end.to change { Todo.count }.by(1)
          end
        end

        context 'when the group is private' do
          before do
            group.update(visibility: Gitlab::VisibilityLevel::PRIVATE)
          end

          it 'creates todos for only newly mentioned users that are group members' do
            expect do
              update_epic(description: "FYI: #{mentioned1.to_reference} #{mentioned2.to_reference}")
            end.to not_change { Todo.count }
          end
        end
      end

      it 'schedules deletion of todos when epic becomes confidential' do
        expect(TodosDestroyer::ConfidentialEpicWorker).to receive(:perform_in).with(Todo::WAIT_FOR_DELETE, epic.id)

        update_epic(confidential: true)
      end
    end

    context 'when Epic has tasks' do
      before do
        update_epic({ description: "- [ ] Task 1\n- [ ] Task 2" })
      end

      it { expect(epic.tasks?).to eq(true) }

      it_behaves_like 'updating a single task' do
        def update_issuable(opts)
          described_class.new(group, user, opts).execute(epic)
        end
      end

      context 'when tasks are marked as completed' do
        before do
          update_epic({ description: "- [x] Task 1\n- [X] Task 2" })
        end

        it 'creates system note about task status change' do
          note1 = find_note('marked the task **Task 1** as completed')
          note2 = find_note('marked the task **Task 2** as completed')

          expect(note1).not_to be_nil
          expect(note2).not_to be_nil

          description_notes = find_notes('description')
          expect(description_notes.length).to eq(1)
        end
      end

      context 'when tasks are marked as incomplete' do
        before do
          update_epic({ description: "- [x] Task 1\n- [X] Task 2" })
          update_epic({ description: "- [ ] Task 1\n- [ ] Task 2" })
        end

        it 'creates system note about task status change' do
          note1 = find_note('marked the task **Task 1** as incomplete')
          note2 = find_note('marked the task **Task 2** as incomplete')

          expect(note1).not_to be_nil
          expect(note2).not_to be_nil

          description_notes = find_notes('description')
          expect(description_notes.length).to eq(1)
        end
      end
    end

    context 'filter out start_date and end_date' do
      it 'ignores start_date and end_date' do
        expect { update_epic(start_date: Date.today, end_date: Date.today) }.not_to change { Note.count }

        expect(epic).to be_valid
        expect(epic).to have_attributes(start_date: nil, due_date: nil)
      end
    end

    context 'refresh epic dates' do
      context 'date fields are updated' do
        it 'calls UpdateDatesService' do
          expect(Epics::UpdateDatesService).to receive(:new).with([epic]).and_call_original

          update_epic(start_date_is_fixed: true, start_date_fixed: Date.today)
          epic.reload
          expect(epic.start_date).to eq(epic.start_date_fixed)
        end
      end

      context 'date fields are not updated' do
        it 'does not call UpdateDatesService' do
          expect(Epics::UpdateDatesService).not_to receive(:new)

          update_epic(title: 'foo')
        end
      end
    end

    it_behaves_like 'existing issuable with scoped labels' do
      let(:issuable) { epic }
      let(:parent) { group }
    end

    context 'with quick actions in the description' do
      let(:label) { create(:group_label, group: group) }

      it 'adds labels to the epic' do
        update_epic(description: "/label ~#{label.name}")

        expect(epic.label_ids).to contain_exactly(label.id)
      end
    end
  end
end
