# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::IterationsResolver do
  include GraphqlHelpers

  describe '#resolve' do
    let_it_be(:current_user) { create(:user) }

    context 'for group iterations' do
      let_it_be(:now) { Time.now }
      let_it_be(:group) { create(:group, :private) }

      def resolve_group_iterations(args = {}, obj = group, context = { current_user: current_user })
        resolve(described_class, obj: obj, args: args, ctx: context)
      end

      before do
        group.add_developer(current_user)
      end

      it 'calls IterationsFinder#execute' do
        expect_next_instance_of(IterationsFinder) do |finder|
          expect(finder).to receive(:execute)
        end

        resolve_group_iterations
      end

      context 'without parameters' do
        it 'calls IterationsFinder to retrieve all iterations' do
          params = { id: nil, iid: nil, group_ids: Group.where(id: group.id).select(:id), state: 'all', start_date: nil, end_date: nil, search_title: nil }

          expect(IterationsFinder).to receive(:new).with(current_user, params).and_call_original

          resolve_group_iterations
        end
      end

      context 'with parameters' do
        it 'calls IterationsFinder with correct parameters' do
          start_date = now
          end_date = start_date + 1.hour
          search = 'wow'
          id = '1'
          iid = 2
          params = { id: id, iid: iid, group_ids: group.id, state: 'closed', start_date: start_date, end_date: end_date, search_title: search }

          expect(IterationsFinder).to receive(:new).with(current_user, params).and_call_original

          resolve_group_iterations(start_date: start_date, end_date: end_date, state: 'closed', title: search, id: 'gid://gitlab/Iteration/1', iid: iid)
        end

        it 'accepts a raw model id for backward compatibility' do
          id = 1
          iid = 2
          params = { id: id, iid: iid, group_ids: group.id, state: 'all', start_date: nil, end_date: nil, search_title: nil }

          expect(IterationsFinder).to receive(:new).with(current_user, params).and_call_original

          resolve_group_iterations(id: id, iid: iid)
        end
      end

      context 'with subgroup' do
        let_it_be(:subgroup) { create(:group, :private, parent: group) }

        it 'defaults to include_ancestors' do
          params = { id: nil, iid: nil, group_ids: subgroup.self_and_ancestors.select(:id), state: 'all', start_date: nil, end_date: nil, search_title: nil }

          expect(IterationsFinder).to receive(:new).with(current_user, params).and_call_original

          resolve_group_iterations({}, subgroup)
        end

        it 'does not default to include_ancestors if IID is supplied' do
          params = { id: nil, iid: 1, group_ids: subgroup.id, state: 'all', start_date: nil, end_date: nil, search_title: nil }

          expect(IterationsFinder).to receive(:new).with(current_user, params).and_call_original

          resolve_group_iterations({ iid: 1, include_ancestors: false }, subgroup)
        end

        it 'accepts include_ancestors false' do
          params = { id: nil, iid: nil, group_ids: subgroup.id, state: 'all', start_date: nil, end_date: nil, search_title: nil }

          expect(IterationsFinder).to receive(:new).with(current_user, params).and_call_original

          resolve_group_iterations({ include_ancestors: false }, subgroup)
        end
      end

      context 'by timeframe' do
        context 'when start_date and end_date are present' do
          context 'when start date is after end_date' do
            it 'raises error' do
              expect do
                resolve_group_iterations(start_date: now, end_date: now - 2.days)
              end.to raise_error(Gitlab::Graphql::Errors::ArgumentError, "startDate is after endDate")
            end
          end
        end

        context 'when only start_date is present' do
          it 'raises error' do
            expect do
              resolve_group_iterations(start_date: now)
            end.to raise_error(Gitlab::Graphql::Errors::ArgumentError, /Both startDate and endDate/)
          end
        end

        context 'when only end_date is present' do
          it 'raises error' do
            expect do
              resolve_group_iterations(end_date: now)
            end.to raise_error(Gitlab::Graphql::Errors::ArgumentError, /Both startDate and endDate/)
          end
        end
      end

      context 'when user cannot read iterations' do
        it 'raises error' do
          unauthorized_user = create(:user)

          expect do
            resolve_group_iterations({}, group, { current_user: unauthorized_user })
          end.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end
  end
end
