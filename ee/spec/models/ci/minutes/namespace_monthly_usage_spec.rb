# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Minutes::NamespaceMonthlyUsage do
  let(:namespace) { create(:namespace) }

  describe 'unique index' do
    before do
      create(:ci_namespace_monthly_usage, namespace: namespace)
    end

    it 'raises unique index violation' do
      expect { create(:ci_namespace_monthly_usage, namespace: namespace) }
        .to raise_error { ActiveRecord::RecordNotUnique }
    end

    it 'does not raise exception if unique index is not violated' do
      expect { create(:ci_namespace_monthly_usage, namespace: namespace, created_at: 1.month.ago) }
        .to change { described_class.count }.by(1)
    end
  end

  describe '.current' do
    subject { described_class.current(namespace) }

    context 'when namespace usage does not exist' do
      it 'creates a usage record' do
        expect { subject }.to change { described_class.count }.by(1)

        expect(subject.amount_used).to eq(0)
        expect(subject.namespace).to eq(namespace)
      end
    end

    context 'when namespace usage exists for previous months' do
      before do
        create(:ci_namespace_monthly_usage, namespace: namespace, created_at: 2.months.ago)
      end

      it 'creates a usage record' do
        expect { subject }.to change { described_class.count }.by(1)

        expect(subject.amount_used).to eq(0)
        expect(subject.namespace).to eq(namespace)
      end
    end

    context 'when namespace usage exists for the current month' do
      let!(:usage) { create(:ci_namespace_monthly_usage, namespace: namespace) }

      it { is_expected.to eq(usage) }
    end

    context 'when a usage for another namespace exists for the current month' do
      let!(:usage) { create(:ci_namespace_monthly_usage) }

      it 'creates a usage record' do
        expect { subject }.to change { described_class.count }.by(1)

        expect(subject.amount_used).to eq(0)
        expect(subject.namespace).to eq(namespace)
      end
    end
  end

  describe '.increase_usage' do
    subject { described_class.increase_usage(namespace, amount) }

    let_it_be(:namespace) { create(:namespace) }

    context 'when usage for current month exists' do
      let!(:usage) { create(:ci_namespace_monthly_usage, namespace: namespace, amount_used: 100.0) }

      context 'when amount is greater than 0' do
        let(:amount) { 10.5 }

        it 'updates the current month usage' do
          subject

          expect(usage.reload.amount_used).to eq(110.5)
        end
      end

      context 'when amount is less or equal to 0' do
        let(:amount) { -2.0 }

        it 'does not update the current month usage' do
          subject

          expect(usage.reload.amount_used).to eq(100.0)
        end
      end
    end

    context 'when usage for current month does not exist' do
      let(:amount) { 17.0 }

      it 'creates a new record for the current month and records the usage' do
        expect { subject }.to change { described_class.count }.by(1)

        current_usage = described_class.current(namespace)
        expect(current_usage.amount_used).to eq(17.0)
      end
    end
  end
end
