# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Iterations::RollOverIssuesService do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:closed_iteration1) { create(:closed_iteration, group: group) }
  let_it_be(:closed_iteration2) { create(:closed_iteration, group: group) }
  let_it_be(:started_iteration) { create(:started_iteration, group: group) }
  let_it_be(:upcoming_iteration) { create(:upcoming_iteration, group: group) }
  let_it_be(:open_issues) { create_list(:issue, 5, :opened, iteration: closed_iteration1)}
  let_it_be(:closed_issues) { create_list(:issue, 5, :closed, iteration: closed_iteration1)}

  let(:from_iteration) { closed_iteration1 }
  let(:to_iteration) { started_iteration }

  subject { described_class.new(user, from_iteration, to_iteration).execute }

  context 'when from iteration or null iteration or both are nil' do
    context 'when to iteration is nil' do
      let(:to_iteration) { nil }

      it { is_expected.to be_error }
    end

    context 'when from iteration is nil' do
      let(:from_iteration) { nil }

      it { is_expected.to be_error }
    end

    context 'when both from_iteration and to_iteration are nil' do
      let(:from_iteration) { nil }
      let(:to_iteration) { nil }

      it { is_expected.to be_error }
    end
  end

  context 'when iterations are present' do
    context 'when issues are rolled-over to a closed iteration' do
      let(:to_iteration) { closed_iteration2 }

      it { is_expected.to be_error }
    end

    context 'when user does not have permission to roll-over issues' do
      context 'when user is not a team member' do
        it { is_expected.to be_error }
      end

      context 'when user is a bot other than automation bot' do
        let(:user) { User.security_bot }

        it { is_expected.to be_error }
      end

      context 'when user is a team member' do
        before do
          group.add_reporter(user)
        end

        it { is_expected.to be_error }
      end
    end

    context 'when user has permissions to roll-over issues' do
      context 'when user is a team member' do
        before do
          group.add_developer(user)
        end

        it { is_expected.not_to be_error }
      end

      context 'when user is the automation bot' do
        let(:user) { User.automation_bot }

        it { is_expected.not_to be_error }

        it 'rolls-over issues to next iteration' do
          expect { subject }.to change { started_iteration.reload.issues }.from([]).to(open_issues)
                                .and(change { closed_iteration1.reload.issues }.from(open_issues + closed_issues).to(closed_issues) )
                                .and(change(ResourceIterationEvent, :count).by(10))
        end
      end
    end
  end
end
