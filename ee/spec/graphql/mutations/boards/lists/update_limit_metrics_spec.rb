# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::Lists::UpdateLimitMetrics do
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board) { create(:board, group: group) }
  let_it_be(:user)  { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:list)  { create(:list, board: board) }

  let(:current_user) { user }
  let(:mutation) { described_class.new(object: nil, context: { current_user: current_user }, field: nil) }
  let(:list_update_params) { { limit_metric: :all_metrics, max_issue_count: 10, max_issue_weight: 50 } }

  before_all do
    group.add_maintainer(user)
    group.add_guest(guest)
  end

  subject { mutation.resolve(list_id: list.to_global_id, **list_update_params) }

  describe '#ready?' do
    it 'raises an error if required arguments are missing' do
      expect { mutation.ready?(list_id: 'some id') }.to raise_error(Gitlab::Graphql::Errors::ArgumentError, "At least one of the arguments " \
        "limitMetric, maxIssueCount or maxIssueWeight is required")
    end
  end

  describe '#resolve' do
    context 'with admin rights' do
      it 'updates the list as expected' do
        subject

        reloaded_list = list.reload

        expect(reloaded_list.limit_metric).to eq('all_metrics')
        expect(reloaded_list.max_issue_count).to eq(10)
        expect(reloaded_list.max_issue_weight).to eq(50)
      end

      it 'returns the correct response' do
        expect(subject.keys).to match_array([:list, :errors])
      end
    end

    context 'without admin rights' do
      let(:current_user) { guest }

      it 'fails' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end
  end
end
