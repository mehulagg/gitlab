# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::Lists::CreateService do
  describe '#execute' do
    let(:project) { create(:project) }
    let(:board) { create(:board, project: project) }
    let(:user) { create(:user) }

    context 'when assignee_id param is sent' do
      let(:other_user) { create(:user) }

      subject(:service) { described_class.new(project, user, 'assignee_id' => other_user.id) }

      before do
        project.add_developer(user)
        project.add_developer(other_user)

        stub_licensed_features(board_assignee_lists: true)
      end

      it 'creates a new assignee list' do
        list = service.execute(board)

        expect(list.list_type).to eq('assignee')
        expect(list).to be_valid
      end
    end

    context 'when milestone_id param is sent' do
      let(:user) { create(:user) }
      let(:milestone) { create(:milestone, project: project) }

      subject(:service) { described_class.new(project, user, 'milestone_id' => milestone.id) }

      before do
        project.add_developer(user)

        stub_licensed_features(board_milestone_lists: true)
      end

      it 'creates a milestone list when param is valid' do
        list = service.execute(board)

        expect(list.list_type).to eq('milestone')
        expect(list).to be_valid
      end
    end

    context 'max limits' do
      describe '#create_list_attributes' do
        shared_examples 'attribute provider for list creation' do
          before do
            stub_feature_flags(wip_limits: wip_limits_enabled)
          end

          where(:params, :expected_max_issue_count, :expected_max_issue_weight, :expected_limit_metric) do
            [
              [{ max_issue_count: 0 }, 0, 0, nil],
              [{ max_issue_count: nil }, 0, 0, nil],
              [{ max_issue_count: 1 }, 1, 0, nil],

              [{ max_issue_weight: 0 }, 0, 0, nil],
              [{ max_issue_weight: nil }, 0, 0, nil],
              [{ max_issue_weight: 1 }, 0, 1, nil],

              [{ max_issue_count: 1, max_issue_weight: 0 }, 1, 0, nil],
              [{ max_issue_count: 0, max_issue_weight: 1 }, 0, 1, nil],
              [{ max_issue_count: 1, max_issue_weight: 1 }, 1, 1, nil],

              [{ max_issue_count: nil, max_issue_weight: 1 }, 0, 1, nil],
              [{ max_issue_count: 1, max_issue_weight: nil }, 1, 0, nil],

              [{ max_issue_count: nil, max_issue_weight: nil }, 0, 0, nil],

              [{ limit_metric: 'all_metrics' }, 0, 0, 'all_metrics'],
              [{ limit_metric: 'issue_count' }, 0, 0, 'issue_count'],
              [{ limit_metric: 'issue_weights' }, 0, 0, 'issue_weights'],
              [{ limit_metric: '' }, 0, 0, ''],
              [{ limit_metric: nil }, 0, 0, nil]
            ]
          end

          with_them do
            it 'contains the expected max limits' do
              service = described_class.new(project, user, params)

              attrs = service.create_list_attributes(nil, nil, nil)

              if wip_limits_enabled
                expect(attrs).to include(max_issue_count: expected_max_issue_count,
                                         max_issue_weight: expected_max_issue_weight,
                                         limit_metric: expected_limit_metric)
              else
                expect(attrs).not_to include(max_issue_count: 0, max_issue_weight: 0, limit_metric: nil)
              end
            end
          end
        end

        it_behaves_like 'attribute provider for list creation' do
          let(:wip_limits_enabled) { true }
        end

        it_behaves_like 'attribute provider for list creation' do
          let(:wip_limits_enabled) { false }
        end
      end
    end
  end
end
