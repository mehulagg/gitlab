# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespaceStatistics do
  it { is_expected.to belong_to(:namespace) }

  it { is_expected.to validate_presence_of(:namespace) }

  describe '#shared_runners_minutes' do
    let(:namespace_statistics) { build(:namespace_statistics, shared_runners_seconds: 120) }

    it { expect(namespace_statistics.shared_runners_minutes).to eq(2) }
  end

  describe '#extra_shared_runners_minutes' do
    subject { namespace_statistics.extra_shared_runners_minutes }

    let(:namespace) { create(:namespace, shared_runners_minutes_limit: 100) }
    let(:namespace_statistics) { create(:namespace_statistics, namespace: namespace) }

    context 'when limit is defined' do
      before do
        namespace.update_attribute(:extra_shared_runners_minutes_limit, 50)
      end

      context 'when usage is above the main quota' do
        before do
          namespace_statistics.update_attribute(:shared_runners_seconds, 101 * 60)
        end

        it { is_expected.to eq(1) }
      end

      context 'when usage is below the main quota' do
        before do
          namespace_statistics.update_attribute(:shared_runners_seconds, 99 * 60)
        end

        it { is_expected.to eq(0) }
      end
    end

    context 'without limit' do
      before do
        namespace.update_attribute(:extra_shared_runners_minutes_limit, nil)
      end

      it { is_expected.to eq(0) }
    end

    context 'when limit is defined globally' do
      before do
        namespace.update_attribute(:shared_runners_minutes_limit, nil)

        stub_application_setting(shared_runners_minutes: 100)
      end

      context 'when usage is above the main quota' do
        before do
          namespace_statistics.update_attribute(:shared_runners_seconds, 101 * 60)
        end

        context 'and extra CI minutes have been assigned' do
          before do
            namespace.update_attribute(:extra_shared_runners_minutes_limit, 50)
          end

          it { is_expected.to eq(1) }
        end

        context 'and extra CI minutes have not been assigned' do
          before do
            namespace.update_attribute(:extra_shared_runners_minutes_limit, nil)
          end

          it { is_expected.to eq(0) }
        end
      end

      context 'when usage is below the main quota' do
        before do
          namespace_statistics.update_attribute(:shared_runners_seconds, 90 * 60)
        end

        context 'and extra CI minutes have been assigned' do
          before do
            namespace.update_attribute(:extra_shared_runners_minutes_limit, 50)
          end

          it { is_expected.to eq(0) }
        end
      end
    end
  end
end
