# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BilledUsersFinder do
  let_it_be_with_refind(:group) { create(:group) }

  let(:search_term) { nil }
  let(:order_by) { nil }

  describe '#execute' do
    let_it_be(:maria) { create(:group_member, group: group, user: create(:user, name: 'Maria Gomez')) }
    let_it_be(:john_smith) { create(:group_member, group: group, user: create(:user, name: 'John Smith')) }
    let_it_be(:john_doe) { create(:group_member, group: group, user: create(:user, name: 'John Doe')) }
    let_it_be(:sophie) { create(:group_member, group: group, user: create(:user, name: 'Sophie Dupont')) }

    subject { described_class.new(group, search_term: search_term, order_by: order_by) }

    context 'when a group does not have any billed users' do
      it 'returns an empty object' do
        allow(group).to receive(:billed_user_ids).and_return({ user_ids: [] })

        expect(subject.execute).to eq({})
      end
    end

    context 'when a search parameter is provided' do
      let(:search_term) { 'John' }

      context 'when a sorting parameter is provided (eg name descending)' do
        let(:order_by) { 'name_desc' }

        it 'sorts results accordingly' do
          expect(subject.execute[:users]).to eq([john_smith, john_doe].map(&:user))
        end
      end

      context 'when a sorting parameter is not provided' do
        subject { described_class.new(group, search_term: search_term) }

        it 'sorts expected results in name_asc order' do
          expect(subject.execute[:users]).to eq([john_doe, john_smith].map(&:user))
        end
      end
    end

    context 'when a search parameter is not present' do
      subject { described_class.new(group) }

      it 'returns expected users in name asc order when a sorting is not provided either' do
        allow(group).to receive(:billed_user_members).and_return([john_doe, john_smith, sophie, maria])

        expect(subject.execute[:users]).to eq([john_doe, john_smith, maria, sophie].map(&:user))
      end

      context 'and when a sorting parameter is provided (eg name descending)' do
        let(:order_by) { 'name_desc' }

        subject { described_class.new(group, search_term: search_term, order_by: order_by) }

        it 'sorts results accordingly' do
          expect(subject.execute[:users]).to eq([sophie, maria, john_smith, john_doe].map(&:user))
        end
      end
    end

    context 'with billable group members including shared members' do
      let_it_be(:shared_with_group_member) { create(:group_member, user: create(:user, name: 'Shared Group User')) }
      let_it_be(:shared_with_project_member) { create(:group_member, user: create(:user, name: 'Shared Project User')) }
      let_it_be(:project) { create(:project, group: group) }

      before do
        create(:group_group_link, shared_group: group, shared_with_group: shared_with_group_member.group)
        create(:project_group_link, group: shared_with_project_member.group, project: project)
      end

      it 'returns a hash of users and user ids' do
        expect(subject.execute.keys).to eq([
          :users,
          :group_member_user_ids,
          :project_member_user_ids,
          :shared_group_user_ids,
          :shared_project_user_ids
        ])
      end

      it 'returns the correct user ids' do
        result = subject.execute

        aggregate_failures do
          expect(result[:group_member_user_ids]).to contain_exactly(*[maria, john_smith, john_doe, sophie].map(&:user_id))
          expect(result[:shared_group_user_ids]).to contain_exactly(shared_with_group_member.user_id)
          expect(result[:shared_project_user_ids]).to contain_exactly(shared_with_project_member.user_id)
        end
      end
    end
  end
end
