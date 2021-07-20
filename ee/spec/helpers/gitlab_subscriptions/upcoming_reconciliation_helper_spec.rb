# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::UpcomingReconciliationHelper do
  include AdminModeHelper

  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  context 'with namespace' do
    let_it_be(:user) { create(:user) }
    let_it_be(:namespace) { create(:namespace, owner: user) }
    let_it_be(:upcoming_reconciliation) { create(:upcoming_reconciliation, :saas, namespace: namespace) }

    let(:cookie_key) do
      "hide_upcoming_reconciliation_alert_#{user.id}_#{namespace.id}_#{upcoming_reconciliation.next_reconciliation_date}"
    end

    before do
      stub_application_setting(check_namespace_plan: true)
    end

    it 'returns true and reconciliation date' do
      expect(helper.display_upcoming_reconciliation_alert?(namespace)).to eq(true)
      expect(helper.upcoming_reconciliation_hash(namespace)).to eq(
        reconciliation_date: upcoming_reconciliation.next_reconciliation_date.to_s,
        cookie_key: cookie_key,
        uses_namespace_plan: true
      )
    end

    context 'with a group' do
      let_it_be(:group) { create(:group) }
      let_it_be(:upcoming_reconciliation2) { create(:upcoming_reconciliation, :saas, namespace: group) }

      let(:cookie_key) do
        "hide_upcoming_reconciliation_alert_#{user.id}_#{group.id}_#{upcoming_reconciliation.next_reconciliation_date}"
      end

      before do
        group.add_owner(user)
      end

      it 'returns true and reconciliation date' do
        expect(helper.display_upcoming_reconciliation_alert?(group)).to eq(true)
        expect(helper.upcoming_reconciliation_hash(group)).to eq(
          reconciliation_date: upcoming_reconciliation2.next_reconciliation_date.to_s,
          cookie_key: cookie_key,
          uses_namespace_plan: true
        )
      end
    end

    context 'when instance does not have paid namespaces (ex: self managed instance)' do
      it 'returns false and empty hash' do
        stub_application_setting(check_namespace_plan: false)

        expect(helper.display_upcoming_reconciliation_alert?(namespace)).to eq(false)
        expect(helper.upcoming_reconciliation_hash(namespace)).to eq({})
      end
    end

    context 'when user is not owner' do
      before do
        allow(helper).to receive(:current_user).and_return(create(:user))
      end

      it 'returns false and empty hash' do
        expect(helper.display_upcoming_reconciliation_alert?(namespace)).to eq(false)
        expect(helper.upcoming_reconciliation_hash(namespace)).to eq({})
      end
    end

    context 'when namespace does not exist in upcoming_reconciliations table' do
      before do
        upcoming_reconciliation.destroy!
      end

      it 'returns false and empty hash' do
        expect(helper.display_upcoming_reconciliation_alert?(namespace)).to eq(false)
        expect(helper.upcoming_reconciliation_hash(namespace)).to eq({})
      end
    end
  end

  context 'without namespace' do
    let_it_be(:upcoming_reconciliation) { create(:upcoming_reconciliation, :self_managed) }
    let_it_be(:user) { create(:user, :admin) }

    let(:cookie_key) do
      "hide_upcoming_reconciliation_alert_#{user.id}_#{upcoming_reconciliation.next_reconciliation_date}"
    end

    it 'returns true and reconciliation date' do
      enable_admin_mode!(user)

      expect(helper.display_upcoming_reconciliation_alert?).to eq(true)
      expect(helper.upcoming_reconciliation_hash).to eq(
        reconciliation_date: upcoming_reconciliation.next_reconciliation_date.to_s,
        cookie_key: cookie_key,
        uses_namespace_plan: false
      )
    end

    context 'when not in admin mode or user is not admin' do
      it 'returns false and empty hash' do
        expect(helper.display_upcoming_reconciliation_alert?).to eq(false)
        expect(helper.upcoming_reconciliation_hash).to eq({})
      end
    end

    context 'when there is no row in upcoming_reconciliations table' do
      before do
        upcoming_reconciliation.destroy!
      end

      it 'returns false and empty hash' do
        expect(helper.display_upcoming_reconciliation_alert?).to eq(false)
        expect(helper.upcoming_reconciliation_hash).to eq({})
      end

      it 'returns false and empty hash' do
        stub_application_setting(check_namespace_plan: true)
        enable_admin_mode!(user)

        expect(helper.display_upcoming_reconciliation_alert?).to eq(false)
        expect(helper.upcoming_reconciliation_hash).to eq({})
      end
    end
  end
end
