# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::TimelogResolver do
  include GraphqlHelpers

  specify do
    expect(described_class).to have_non_null_graphql_type(::Types::TimelogType.connection_type)
  end

  context "with a group" do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, :empty_repo, :public, group: group) }

    before_all do
      group.add_developer(current_user)
      project.add_developer(current_user)
    end

    before do
      group.clear_memoization(:timelogs)
    end

    describe '#resolve' do
      let_it_be(:issue) { create(:issue, project: project) }
      let_it_be(:merge_request) { create(:merge_request, source_project: project) }
      let_it_be(:timelog1) { create(:issue_timelog, issue: issue, spent_at: 2.days.ago.beginning_of_day) }
      let_it_be(:timelog2) { create(:issue_timelog, issue: issue, spent_at: 2.days.ago.end_of_day) }
      let_it_be(:timelog3) { create(:merge_request_timelog, merge_request: merge_request, spent_at: 10.days.ago) }

      let(:args) { { start_time: 6.days.ago, end_time: 2.days.ago.noon } }

      it 'finds all timelogs within given dates' do
        timelogs = resolve_timelogs(**args)

        expect(timelogs).to contain_exactly(timelog1)
      end

      it 'return nothing when user has insufficient permissions' do
        user = create(:user)
        group.add_guest(current_user)

        expect(resolve_timelogs(user: user, **args)).to be_empty
      end

      context 'when start_time and end_date are present' do
        let(:args) { { start_time: 6.days.ago, end_date: 2.days.ago } }

        it 'finds timelogs until the end of day of end_date' do
          timelogs = resolve_timelogs(**args)

          expect(timelogs).to contain_exactly(timelog1, timelog2)
        end
      end

      context 'when start_date and end_time are present' do
        let(:args) { { start_date: 6.days.ago, end_time: 2.days.ago.noon } }

        it 'finds all timelogs within start_date and end_time' do
          timelogs = resolve_timelogs(**args)

          expect(timelogs).to contain_exactly(timelog1)
        end
      end

      context 'when arguments are invalid' do
        let_it_be(:error_class) { Gitlab::Graphql::Errors::ArgumentError }

        context 'when start_time and start_date are present' do
          let(:args) { { start_time: 6.days.ago, start_date: 6.days.ago } }

          it 'returns correct error' do
            expect { resolve_timelogs(**args) }
              .to raise_error(error_class, /Both date and time arguments must not be present/)
          end
        end

        context 'when end_time and end_date are present' do
          let(:args) { { end_time: 2.days.ago, end_date: 2.days.ago } }

          it 'returns correct error' do
            expect { resolve_timelogs(**args) }
              .to raise_error(error_class, /Both date and time arguments must not be present/)
          end
        end

        context 'when start argument is after end argument' do
          let(:args) { { start_time: 2.days.ago, end_time: 6.days.ago } }

          it 'returns correct error' do
            expect { resolve_timelogs(**args) }
              .to raise_error(error_class, /Start argument must be before End argument/)
          end
        end
      end
    end
  end

  def resolve_timelogs(user: current_user, **args)
    context = { current_user: user }
    resolve(described_class, obj: group, args: args, ctx: context)
  end
end
