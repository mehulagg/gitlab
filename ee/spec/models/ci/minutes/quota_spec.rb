# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Ci::Minutes::Quota do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:namespace) do
    create(:namespace, namespace_statistics: create(:namespace_statistics))
  end

  let(:quota) { described_class.new(namespace) }

  describe '#monthly_minutes_report' do
    context 'when unlimited' do
      before do
        allow(namespace).to receive(:shared_runners_minutes_limit_enabled?).and_return(false)
      end

      context 'when minutes are not used' do
        it 'returns unlimited report with no usage' do
          report = quota.monthly_minutes_report

          expect(report.limit).to eq 'Unlimited'
          expect(report.used).to eq 0
          expect(report.status).to eq :disabled
        end
      end

      context 'when minutes are used' do
        before do
          namespace.namespace_statistics.shared_runners_seconds = 20.minutes
        end

        it 'returns unlimited report with usage' do
          report = quota.monthly_minutes_report

          expect(report.limit).to eq 'Unlimited'
          expect(report.used).to eq 20
          expect(report.status).to eq :disabled
        end
      end
    end

    context 'when limited' do
      before do
        allow(namespace).to receive(:shared_runners_minutes_limit_enabled?).and_return(true)
        namespace.shared_runners_minutes_limit = 100
      end

      context 'when minutes are not all used' do
        before do
          namespace.namespace_statistics.shared_runners_seconds = 30.minutes
        end

        it 'returns report with under quota' do
          report = quota.monthly_minutes_report

          expect(report.limit).to eq 100
          expect(report.used).to eq 30
          expect(report.status).to eq :under_quota
        end
      end

      context 'when minutes are all used' do
        before do
          namespace.namespace_statistics.shared_runners_seconds = 101.minutes
        end

        it 'returns report with over quota' do
          report = quota.monthly_minutes_report

          expect(report.limit).to eq 100
          expect(report.used).to eq 101
          expect(report.status).to eq :over_quota
        end
      end
    end
  end

  describe '#purchased_minutes_report' do
    context 'when limit enabled' do
      before do
        allow(namespace).to receive(:shared_runners_minutes_limit_enabled?).and_return(true)
        namespace.shared_runners_minutes_limit = 200
      end

      context 'when extra minutes have been purchased' do
        before do
          namespace.extra_shared_runners_minutes_limit = 100
        end

        context 'when all monthly minutes are used and some puarchased minutes are used' do
          before do
            namespace.namespace_statistics.shared_runners_seconds = 250.minutes
          end

          it 'returns report with under quota' do
            report = quota.purchased_minutes_report

            expect(report.limit).to eq 100
            expect(report.used).to eq 50
            expect(report.status).to eq :under_quota
          end
        end

        context 'when all monthly and all puarchased minutes have been used' do
          before do
            namespace.namespace_statistics.shared_runners_seconds = 301.minutes
          end

          it 'returns report with over quota' do
            report = quota.purchased_minutes_report

            expect(report.limit).to eq 100
            expect(report.used).to eq 101
            expect(report.status).to eq :over_quota
          end
        end

        context 'when not all monthly minutes have been used' do
          before do
            namespace.namespace_statistics.shared_runners_seconds = 190.minutes
          end

          it 'returns report with no usage' do
            report = quota.purchased_minutes_report

            expect(report.limit).to eq 100
            expect(report.used).to eq 0
            expect(report.status).to eq :under_quota
          end
        end
      end

      context 'when no extra minutes have been purchased' do
        before do
          namespace.extra_shared_runners_minutes_limit = nil
        end

        context 'when all monthly minutes have been used' do
          before do
            namespace.namespace_statistics.shared_runners_seconds = 201.minutes
          end

          it 'returns report without usage' do
            report = quota.purchased_minutes_report

            expect(report.limit).to eq 0
            expect(report.used).to eq 0
            expect(report.status).to eq :under_quota
          end
        end

        context 'when not all monthly minutes have been used' do
          before do
            namespace.namespace_statistics.shared_runners_seconds = 190.minutes
          end

          it 'returns report with no usage' do
            report = quota.purchased_minutes_report

            expect(report.limit).to eq 0
            expect(report.used).to eq 0
            expect(report.status).to eq :under_quota
          end
        end
      end
    end
  end

  describe '#monthly_percent_used' do
    subject { quota.monthly_percent_used }

    where(:limit_enabled, :monthly_limit, :purchased_limit, :minutes_used, :result, :title) do
      false | 200 | 0   | 40  | 0   | 'limit not enabled'
      true  | 200 | 0   | 0   | 0   | 'monthly limit set and no usage'
      true  | 200 | 0   | 40  | 20  | 'monthly limit set and usage lower than 100%'
      true  | 200 | 0   | 200 | 100 | 'monthly limit set and usage at 100%'
      true  | 200 | 0   | 210 | 105 | 'monthly limit set and usage above 100%'
      true  | 0   | 0   | 0   | 0   | 'monthly limit not set and no usage'
      true  | 0   | 0   | 40  | 0   | 'monthly limit not set and some usage'
      true  | 200 | 100 | 0   | 0   | 'monthly and purchased limits set and no usage'
      true  | 200 | 100 | 40  | 20  | 'monthly and purchased limits set and low usage'
      true  | 200 | 100 | 210 | 100 | 'usage capped to 100% and overflows into purchased minutes'
    end

    with_them do
      before do
        allow(namespace).to receive(:shared_runners_minutes_limit_enabled?).and_return(limit_enabled)
        namespace.shared_runners_minutes_limit = monthly_limit
        namespace.extra_shared_runners_minutes_limit = purchased_limit
        namespace.namespace_statistics.shared_runners_seconds = minutes_used.minutes
      end

      it 'returns the percentage' do
        is_expected.to eq result
      end
    end
  end

  describe '#purchased_percent_used' do
    subject { quota.purchased_percent_used }

    where(:limit_enabled, :monthly_limit, :purchased_limit, :minutes_used, :result, :title) do
      false | 0   | 0   | 40  | 0   | 'limit not enabled'
      true  | 0   | 200 | 40  | 20  | 'monthly limit not set and purchased limit set and low usage'
      true  | 200 | 0   | 40  | 0   | 'monthly limit set and purchased limit not set and usage below monthly'
      true  | 200 | 0   | 240 | 0   | 'monthly limit set and purchased limit not set and usage above monthly'
      true  | 200 | 200 | 0   | 0   | 'monthly and purchased limits set and no usage'
      true  | 200 | 200 | 40  | 0   | 'monthly and purchased limits set and usage below monthly'
      true  | 200 | 200 | 200 | 0   | 'monthly and purchased limits set and monthly minutes maxed out'
      true  | 200 | 200 | 300 | 50  | 'monthly and purchased limits set and some purchased minutes used'
      true  | 200 | 200 | 400 | 100 | 'monthly and purchased limits set and all minutes used'
      true  | 200 | 200 | 430 | 115 | 'monthly and purchased limits set and usage beyond all limits'
    end

    with_them do
      before do
        allow(namespace).to receive(:shared_runners_minutes_limit_enabled?).and_return(limit_enabled)
        namespace.shared_runners_minutes_limit = monthly_limit
        namespace.extra_shared_runners_minutes_limit = purchased_limit
        namespace.namespace_statistics.shared_runners_seconds = minutes_used.minutes
      end

      it 'returns the percentage' do
        is_expected.to eq result
      end
    end
  end
end
