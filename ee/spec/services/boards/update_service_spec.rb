# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::UpdateService, services: true do
  describe '#execute' do
    let(:project) { create(:project, group: group) }
    let(:group) { create(:group) }
    let!(:board)  { create(:board, group: group, name: 'Backend') }

    it "updates board's name" do
      service = described_class.new(group, double, name: 'Engineering')

      service.execute(board)

      expect(board).to have_attributes(name: 'Engineering')
    end

    it 'returns true with valid params' do
      service = described_class.new(group, double, name: 'Engineering')

      expect(service.execute(board)).to eq true
    end

    it 'returns false with invalid params' do
      service = described_class.new(group, double, name: nil)

      expect(service.execute(board)).to eq false
    end

    it 'updates the configuration params when scoped issue board is enabled' do
      stub_licensed_features(scoped_issue_board: true)
      assignee = create(:user)
      milestone = create(:milestone, group: group)
      label = create(:group_label, group: board.group)
      user = create(:user)
      params = { milestone_id: milestone.id, assignee_id: assignee.id, label_ids: [label.id], hide_backlog_list: true, hide_closed_list: true }
      service = described_class.new(group, user, params)

      service.execute(board)

      expected_attributes = { milestone: milestone, assignee: assignee, labels: [label], hide_backlog_list: true, hide_closed_list: true }
      expect(board.reload).to have_attributes(expected_attributes)
    end

    it 'filters unpermitted params when scoped issue board is not enabled' do
      stub_licensed_features(scoped_issue_board: false)
      params = { milestone_id: double, assignee_id: double, label_ids: double, weight: double, hide_backlog_list: true, hide_closed_list: true }

      service = described_class.new(project, double, params)
      service.execute(board)

      expected_attributes = { milestone: nil, assignee: nil, labels: [], hide_backlog_list: false, hide_closed_list: false }
      expect(board.reload).to have_attributes(expected_attributes)
    end

    it_behaves_like 'setting a milestone scope' do
      subject { board.reload }

      before do
        described_class.new(parent, double, milestone_id: milestone.id).execute(board)
      end
    end

    describe '#set_labels' do
      def expect_label_assigned(user, board, input_labels, expected_labels)
        service = described_class.new(board.resource_parent, user, input_labels)
        service.execute(board)

        expect(board.reload.labels.map(&:title)).to contain_exactly(*expected_labels)
      end

      let(:user) { create(:user) }
      let(:role) { :guest }
      let(:input_labels) { %w{group_label new_label} }
      let(:labels_input) { { labels: input_labels.join(',') } }
      let(:label_ids_input) { { label_ids: [group_label.id] } }

      context 'group board labels' do
        let!(:group_label) { create(:group_label, title: 'group_label', group: group) }

        before do
          group.add_user(user, role)
          stub_licensed_features(scoped_issue_board: true)
        end

        it 'updates using only existing label' do
          expect_label_assigned(user, board, labels_input, %w{group_label})
        end

        context 'user with admin_label ability' do
          let(:role) { :reporter }

          it 'finds and creates labels' do
            expect_label_assigned(user, board, labels_input, input_labels)
          end

          context 'when scoped_issue_board disabled' do
            before do
              stub_licensed_features(scoped_issue_board: false)
            end

            it 'does not create labels' do
              expect_label_assigned(user, board, labels_input, [])
              expect_label_assigned(user, board, label_ids_input, [])
            end
          end

          context 'nested group' do
            let!(:child_group) { create(:group, parent: group)}
            let!(:board) { create(:board, group: child_group, name: 'Child Backend') }

            it "allows using ancestor group's label" do
              expect_label_assigned(user, board, labels_input, input_labels)
            end
          end
        end
      end

      context 'project board labels' do
        let(:project) { create(:project, group: group) }
        let!(:board) { create(:board, project: project, name: 'Backend') }
        let!(:group_label) { create(:group_label, title: 'group_label', group: group) }
        let!(:label) { create(:label, title: 'project_label', project: project) }

        let(:input_labels) { %w{group_label project_label new_label} }
        let(:labels_input) { { labels: input_labels.join(',') } }
        let(:label_ids_input) { { label_ids: [group_label.id, label.id] } }

        before do
          project.add_user(user, role)
          stub_licensed_features(scoped_issue_board: true)
        end

        context 'user with admin_label ability' do
          let(:role) { :reporter }

          it 'finds and creates labels' do
            expect_label_assigned(user, board, labels_input, input_labels)
          end

          context 'when scoped_issue_board disabled' do
            before do
              stub_licensed_features(scoped_issue_board: false)
            end

            it 'does not create labels' do
              expect_label_assigned(user, board, labels_input, [])
              expect_label_assigned(user, board, label_ids_input, [])
            end
          end
        end

        it 'updates using only existing label' do
          expect_label_assigned(user, board, labels_input, %w{group_label project_label})
        end

        context 'nested group' do
          let!(:child_group) { create(:group, parent: group)}
          let(:project) { create(:project, group: child_group) }

          it "allows using ancestor group's label" do
            expect_label_assigned(user, board, labels_input, %w{group_label project_label})
          end
        end

        context 'when label_ids param is provided' do
          it 'updates using only labels accessible by the project board' do
            other_project_label = create(:label, title: 'other_project_label')
            other_group_label = create(:group_label, title: 'other_group_label')
            label_ids = [group_label.id, label.id, other_project_label.id, other_group_label.id]

            described_class.new(board.resource_parent, user, label_ids: label_ids).execute(board)

            expect(board.reload.labels).to contain_exactly(group_label, label)
          end
        end
      end
    end
  end
end
