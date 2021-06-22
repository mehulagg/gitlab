# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::UpcomingReconciliation do
  describe 'associations' do
    it { is_expected.to belong_to(:namespace).optional }
  end

  describe 'validations' do
    # This is needed for the validate_uniqueness_of expectation.
    let_it_be(:upcoming_reconciliation) { create(:upcoming_reconciliation, :saas) }

    it { is_expected.to validate_presence_of(:next_reconciliation_date) }
    it { is_expected.to validate_presence_of(:display_alert_from) }

    it 'does not allow multiple rows with namespace_id nil' do
      create(:upcoming_reconciliation, :self_managed)

      expect { create(:upcoming_reconciliation, :self_managed) }.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: Namespace has already been taken'
      )
    end

    context 'when instance has paid namespaces (ex: gitlab.com)' do
      before do
        stub_application_setting(check_namespace_plan: true)
      end

      it { is_expected.to validate_presence_of(:namespace) }
      it { is_expected.not_to validate_uniqueness_of(:namespace) }
    end

    context 'when namespaces are not paid (ex: self managed instance)' do
      it { is_expected.not_to validate_presence_of(:namespace) }
      it { is_expected.to validate_uniqueness_of(:namespace) }
    end
  end

  describe 'scopes' do
    let_it_be(:namespace1) { create(:namespace) }
    let_it_be(:namespace2) { create(:namespace) }
    let_it_be(:namespace3) { create(:namespace) }
    let_it_be(:upcoming_reconciliation1) { create(:upcoming_reconciliation, :saas, namespace: namespace1) }
    let_it_be(:upcoming_reconciliation2) { create(:upcoming_reconciliation, :saas, namespace: namespace2) }
    let_it_be(:upcoming_reconciliation3) { create(:upcoming_reconciliation, :saas, namespace: namespace3) }

    describe '.by_namespace_ids' do
      it 'returns only upcoming reconciliations for given namespaces' do
        expect(described_class.by_namespace_ids([namespace1.id, namespace3.id]))
          .to contain_exactly(upcoming_reconciliation1, upcoming_reconciliation3)
      end
    end
  end

  describe '#display_alert?' do
    let(:upcoming_reconciliation) { build(:upcoming_reconciliation, :saas) }

    subject(:display_alert?) { upcoming_reconciliation.display_alert? }

    context 'with next_reconciliation_date in future' do
      it { is_expected.to eq(true) }
    end

    context 'with next_reconciliation_date in past' do
      before do
        upcoming_reconciliation.next_reconciliation_date = Date.yesterday
      end

      it { is_expected.to eq(false) }
    end

    context 'with display_alert_from in future' do
      before do
        upcoming_reconciliation.display_alert_from = 2.days.from_now
      end

      it { is_expected.to eq(false) }
    end

    context 'with display_alert_from in past' do
      it { is_expected.to eq(true) }
    end
  end

  describe '.next' do
    context 'when self managed' do
      it 'returns row where namespace_id is nil' do
        upcoming_reconciliation = create(:upcoming_reconciliation, :self_managed)

        expect(described_class.next).to eq(upcoming_reconciliation)
      end

      it 'returns nil when there is no row with namespace_id nil' do
        expect(described_class.next).to eq(nil)
      end
    end

    context 'when instance has paid namespaces (ex: gitlab.com)' do
      let_it_be(:upcoming_reconciliation) { create(:upcoming_reconciliation, :saas) }

      let(:namespace_id) { upcoming_reconciliation.namespace_id }

      before do
        stub_application_setting(check_namespace_plan: true)
      end

      it 'returns row for given namespace' do
        expect(described_class.next(namespace_id)).to eq(upcoming_reconciliation)
      end

      it 'returns nil when there is no row with given namespace_id' do
        expect(described_class.next(non_existing_record_id)).to eq(nil)
      end

      it 'returns nil if namespace_id is nil' do
        expect(described_class.next).to eq(nil)
      end
    end
  end
end
