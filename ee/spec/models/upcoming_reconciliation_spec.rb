# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UpcomingReconciliation do
  describe 'validations' do
    context 'when gitlab.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      it { is_expected.to validate_presence_of(:namespace) }
    end

    context 'when not gitlab.com' do
      it { is_expected.not_to validate_presence_of(:namespace) }
    end
  end

  describe '#display_alert?' do
    let(:upcoming_reconciliation) { build(:sm_upcoming_reconciliation) }

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
        upcoming_reconciliation.display_alert_from = Date.tomorrow.beginning_of_day
      end

      it { is_expected.to eq(false) }
    end

    context 'with display_alert_from in past' do
      it { is_expected.to eq(true) }
    end
  end
end
