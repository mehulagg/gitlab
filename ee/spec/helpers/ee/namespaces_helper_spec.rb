# frozen_string_literal: true
require 'spec_helper'

RSpec.describe EE::NamespacesHelper do
  let!(:admin) { create(:admin) }
  let!(:admin_project_creation_level) { nil }
  let!(:admin_group) do
    create(:group,
           :private,
           project_creation_level: admin_project_creation_level)
  end
  let!(:user) { create(:user) }
  let!(:user_project_creation_level) { nil }
  let!(:user_group) do
    create(:group,
           :private,
           project_creation_level: user_project_creation_level)
  end

  before do
    admin_group.add_owner(admin)
    user_group.add_owner(user)
  end

  describe '#ci_minutes_progress_bar' do
    it 'shows a green bar if percent is 0' do
      expect(helper.ci_minutes_progress_bar(0)).to match(/success.*0%/)
    end

    it 'shows a green bar if percent is lower than 70' do
      expect(helper.ci_minutes_progress_bar(69)).to match(/success.*69%/)
    end

    it 'shows a yellow bar if percent is 70' do
      expect(helper.ci_minutes_progress_bar(70)).to match(/warning.*70%/)
    end

    it 'shows a yellow bar if percent is higher than 70 and lower than 95' do
      expect(helper.ci_minutes_progress_bar(94)).to match(/warning.*94%/)
    end

    it 'shows a red bar if percent is 95' do
      expect(helper.ci_minutes_progress_bar(95)).to match(/danger.*95%/)
    end

    it 'shows a red bar if percent is higher than 100 and caps the value to 100' do
      expect(helper.ci_minutes_progress_bar(120)).to match(/danger.*100%/)
    end
  end

  describe '#ci_minutes_report' do
    let(:quota) { Ci::Minutes::Quota.new(user_group) }

    describe 'rendering monthly minutes report' do
      let(:report) { quota.monthly_minutes_report }

      context "when it's unlimited" do
        before do
          allow(user_group).to receive(:shared_runners_minutes_limit_enabled?).and_return(false)
        end

        it 'returns Unlimited for the limit section' do
          expect(helper.ci_minutes_report(report)).to match(%r{0 / Unlimited})
        end

        it 'returns the proper value for the used section' do
          allow(user_group).to receive(:shared_runners_seconds).and_return(100 * 60)

          expect(helper.ci_minutes_report(report)).to match(%r{100 / Unlimited})
        end
      end

      context "when it's limited" do
        before do
          allow(user_group).to receive(:shared_runners_minutes_limit_enabled?).and_return(true)
          allow(user_group).to receive(:shared_runners_seconds).and_return(100 * 60)

          user_group.update!(shared_runners_minutes_limit: 500)
        end

        it 'returns the proper values for used and limit sections' do
          expect(helper.ci_minutes_report(report)).to match(%r{100 / 500})
        end
      end
    end

    describe 'rendering purchased minutes report' do
      let(:report) { quota.purchased_minutes_report }

      context 'when extra minutes are assigned' do
        it 'returns the proper values for used and limit sections' do
          allow(user_group).to receive(:shared_runners_seconds).and_return(50 * 60)
          user_group.update!(extra_shared_runners_minutes_limit: 100)

          expect(helper.ci_minutes_report(report)).to match(%r{50 / 100})
        end
      end

      context 'when extra minutes are not assigned' do
        it 'returns the proper values for used and limit sections' do
          expect(helper.ci_minutes_report(report)).to match(%r{0 / 0})
        end
      end
    end
  end

  describe '#namespace_storage_usage_link' do
    subject { helper.namespace_storage_usage_link(namespace) }

    context 'when namespace is a group' do
      let(:namespace) { build(:group) }

      it { is_expected.to eq(group_usage_quotas_path(namespace, anchor: 'storage-quota-tab')) }
    end

    context 'when namespace is a user' do
      let(:namespace) { build(:namespace) }

      it { is_expected.to eq(profile_usage_quotas_path(anchor: 'storage-quota-tab')) }
    end
  end

  describe '#purchase_storage_url' do
    subject { helper.purchase_storage_url }

    context 'when on .com' do
      before do
        allow(::Gitlab).to receive(:com?).and_return(true)
      end

      it { is_expected.to eq(EE::SUBSCRIPTIONS_MORE_STORAGE_URL) }

      context 'when feature flag disabled' do
        before do
          stub_feature_flags(buy_storage_link: false)
        end

        it { is_expected.to be_nil }
      end
    end

    context 'when not on .com' do
      before do
        allow(::Gitlab).to receive(:com?).and_return(false)
      end

      it { is_expected.to be_nil }
    end
  end
end
