# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::UpcomingReconciliationHelper do
  include AdminModeHelper

  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe '#upcoming_reconciliation_hash' do
    context 'with namespace' do
      let_it_be(:user) { create(:user) }
      let_it_be(:group) { create(:group) }
      let_it_be(:upcoming_reconciliation) { create(:upcoming_reconciliation, :saas, namespace: group) }

      before do
        group.add_owner(user)
        allow(helper).to receive(:can?).with(user, :admin_group, group).and_return(true)

        allow(::Gitlab).to receive(:com?).and_return(true)
      end

      it 'returns true' do
        expect(helper.upcoming_reconciliation_hash(group)).to eq(
          reconciliation_date: upcoming_reconciliation.next_reconciliation_date.to_s,
          display_alert: true
        )
      end

      context 'when not gitlab.com' do
        it 'returns false' do
          allow(::Gitlab).to receive(:com?).and_return(false)

          expect(helper.upcoming_reconciliation_hash(group)).to eq(
            reconciliation_date: '',
            display_alert: false
          )
        end
      end

      context 'when user is not owner' do
        before do
          group.group_member(user).destroy!
          allow(helper).to receive(:can?).with(user, :admin_group, group).and_return(false)
        end

        it 'returns false' do
          expect(helper.upcoming_reconciliation_hash(group)).to eq(
            reconciliation_date: upcoming_reconciliation.next_reconciliation_date.to_s,
            display_alert: false
          )
        end
      end

      context 'when namespace does not exist in upcoming_reconciliations table' do
        before do
          upcoming_reconciliation.destroy!
        end

        it 'returns false' do
          expect(helper.upcoming_reconciliation_hash(group)).to eq(
            reconciliation_date: '',
            display_alert: false
          )
        end
      end
    end

    context 'on self managed' do
      let_it_be(:upcoming_reconciliation) { create(:upcoming_reconciliation, :self_managed) }
      let_it_be(:user) { create(:user, :admin) }

      it 'returns true' do
        enable_admin_mode!(user)

        expect(helper.upcoming_reconciliation_hash).to eq(
          reconciliation_date: upcoming_reconciliation.next_reconciliation_date.to_s,
          display_alert: true
        )
      end
    end
  end
end
