# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::Lists::Update do
  include GraphqlHelpers

  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board) { create(:board, group: group) }
  let_it_be(:reporter) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:list, reload: true) { create(:list, board: board, position: 0) }

  let(:mutation) { described_class.new(object: nil, context: { current_user: current_user }, field: nil) }
  let(:list_update_params) { { collapsed: true, max_issue_count: 10, max_issue_weight: 55 } }

  before_all do
    group.add_guest(guest)
    group.add_reporter(reporter)
  end

  subject { mutation.resolve(list: list, **list_update_params) }

  describe '#resolve' do
    context 'with permission to admin board lists' do
      let(:current_user) { reporter }

      it 'updates the max_issue_count and max_issue_weight' do
        updated_list = subject[:list]

        expect(updated_list.max_issue_count).to eq(10)
        expect(updated_list.max_issue_weight).to eq(55)
      end
    end

    context 'with permission to read board lists' do
      let(:current_user) { guest }

      it 'does not update max_issue_count or max_issue_weight' do
        updated_list = subject[:list]

        expect(updated_list.max_issue_count).to eq(0)
        expect(updated_list.max_issue_weight).to eq(0)
      end
    end

    context 'without permission to read board lists' do
      let(:current_user) { create(:user) }

      it 'raises Resource Not Found error' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end
  end
end
