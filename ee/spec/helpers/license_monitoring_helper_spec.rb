# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LicenseMonitoringHelper do
  describe '#show_active_user_count_threshold_banner?' do
    let_it_be(:admin) { create(:admin) }
    let_it_be(:user) { create(:user) }
    let_it_be(:license_seats_limit) { 10 }
    let_it_be(:license) do
      create(:license, data: build(:gitlab_license, restrictions: { active_user_count: license_seats_limit }).export)
    end

    subject { helper.show_active_user_count_threshold_banner? }

    shared_examples 'banner hidden when below the threshold' do
      before do
        allow(license).to receive(:active_user_count_threshold_reached?).and_return(false)
      end

      it { is_expected.to be_falsey }
    end

    context 'on GitLab.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      it { is_expected.to be_falsey }
    end

    context 'on self-managed instance' do
      before do
        allow(Gitlab).to receive(:com?).and_return(false)
      end

      context 'when callout dismissed' do
        before do
          allow(helper).to receive(:user_dismissed?).with(UserCalloutsHelper::ACTIVE_USER_COUNT_THRESHOLD).and_return(true)
        end

        it { is_expected.to be_falsey }
      end

      context 'when license' do
        context 'is not available' do
          before do
            allow(License).to receive(:current).and_return(nil)
          end

          it { is_expected.to be_falsey }
        end

        context 'is trial' do
          before do
            allow(license).to receive(:trial?).and_return(true)
            allow(License).to receive(:current).and_return(license)
          end

          it { is_expected.to be_falsey }
        end
      end

      context 'when current active user count greater than total user count' do
        before do
          allow(license).to receive(:restricted_user_count).and_return(license_seats_limit)
          allow(license).to receive(:daily_billable_users_count).and_return(license_seats_limit + 1)
          allow(License).to receive(:current).and_return(license)
        end

        it { is_expected.to be_falsey }
      end

      context 'when logged in as an admin user' do
        before do
          allow(helper).to receive(:current_user).and_return(admin)
          allow(helper).to receive(:admin_section?).and_return(true)
        end

        context 'when above the threshold' do
          before do
            allow(license).to receive(:active_user_count_threshold_reached?).and_return(license_seats_limit + 1)
            allow(License).to receive(:current).and_return(license)
          end

          it { is_expected.to be_truthy }
        end

        it_behaves_like 'banner hidden when below the threshold'
      end

      context 'when logged in as a regular user' do
        before do
          allow(helper).to receive(:current_user).and_return(user)
        end

        it_behaves_like 'banner hidden when below the threshold'
      end

      context 'when not logged in' do
        before do
          allow(helper).to receive(:current_user).and_return(nil)
        end

        it_behaves_like 'banner hidden when below the threshold'
      end
    end
  end

  describe '#users_over_license' do
    context 'with an user overage' do
      let(:license) { build(:license) }

      before do
        allow(helper).to receive(:license_is_over_capacity?).and_return true
        allow(License).to receive(:current).and_return(license)
        allow(license).to receive(:overage_with_historical_max) { 5 }
      end

      it 'shows overage as a number' do
        expect(helper.users_over_license).to eq 5
      end
    end

    context 'without an user overage' do
      before do
        allow(helper).to receive(:license_is_over_capacity?).and_return false
      end

      it 'shows overage as a number' do
        expect(helper.users_over_license).to eq 0
      end
    end
  end
end
