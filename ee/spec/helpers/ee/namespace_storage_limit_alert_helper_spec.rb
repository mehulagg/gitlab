# frozen_string_literal: true
require 'spec_helper'

RSpec.describe EE::NamespaceStorageLimitAlertHelper do
  using RSpec::Parameterized::TableSyntax

  let!(:admin) { create(:admin) }

  describe '#display_namespace_storage_limit_alert!' do
    it 'sets @display_namespace_storage_limit_alert to true' do
      expect(helper.instance_variable_get(:@display_namespace_storage_limit_alert)).to be nil

      helper.display_namespace_storage_limit_alert!

      expect(helper.instance_variable_get(:@display_namespace_storage_limit_alert)).to be true
    end
  end

  describe '#display_namespace_storage_limit_alert?' do
    let_it_be(:namespace) { build_stubbed(:namespace) }

    before do
      assign(:display_namespace_storage_limit_alert, display_namespace_storage_limit_alert)
    end

    context 'when display_namespace_storage_limit_alert is true' do
      let(:display_namespace_storage_limit_alert) { true }

      it 'returns false when in profile usage quota path' do
        allow(@request).to receive(:path) { profile_usage_quotas_path }

        expect(helper.display_namespace_storage_limit_alert?(namespace)).to eq(false)
      end

      it 'returns false when in namespace usage quota path' do
        allow(@request).to receive(:path) { group_usage_quotas_path(namespace) }

        expect(helper.display_namespace_storage_limit_alert?(namespace)).to eq(false)
      end

      it 'returns true when in other namespace path' do
        allow(@request).to receive(:path) { group_path(namespace) }

        expect(helper.display_namespace_storage_limit_alert?(namespace)).to eq(true)
      end
    end

    context 'when display_namespace_storage_limit_alert is false' do
      let(:display_namespace_storage_limit_alert) { false }

      it 'returns false' do
        allow(@request).to receive(:path) { group_path(namespace) }

        expect(helper.display_namespace_storage_limit_alert?(namespace)).to eq(false)
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

  describe '#can_purchase_storage?' do
    subject { helper.can_purchase_storage? }

    where(:enforcement_setting_enabled, :feature_enabled, :result) do
      false | false | false
      false | true  | false
      true  | false | false
      true  | true  | true
    end

    with_them do
      before do
        stub_application_setting(enforce_namespace_storage_limit: enforcement_setting_enabled)
        stub_feature_flags(buy_storage_link: feature_enabled)
      end

      it { is_expected.to eq(result) }
    end
  end

  describe '#purchase_storage_url' do
    subject { helper.purchase_storage_url }

    it { is_expected.to eq(EE::SUBSCRIPTIONS_MORE_STORAGE_URL) }
  end

  describe '#namespace_storage_alert' do
    subject { helper.namespace_storage_alert(namespace) }

    let(:namespace) { build(:namespace) }

    let(:payload) do
      {
        alert_level: :info,
        usage_message: "Usage",
        explanation_message: "Explanation",
        root_namespace: namespace
      }
    end

    where(:additional_repo_storage_by_namespace_enabled, :service_class_name) do
      false | Namespaces::CheckStorageSizeService
      true  | Namespaces::CheckExcessStorageSizeService
    end

    with_them do
      before do
        allow(namespace).to receive(:additional_repo_storage_by_namespace_enabled?)
          .and_return(additional_repo_storage_by_namespace_enabled)

        allow(helper).to receive(:current_user).and_return(admin)
        allow_next_instance_of(service_class_name, namespace, admin) do |service|
          expect(service).to receive(:execute).and_return(ServiceResponse.success(payload: payload))
        end
      end

      context 'when payload is not empty and no cookie is set' do
        it { is_expected.to eq(payload) }
      end

      context 'when there is no current_user' do
        before do
          allow(helper).to receive(:current_user).and_return(nil)
        end

        it { is_expected.to eq({}) }
      end

      context 'when payload is empty' do
        let(:payload) { {} }

        it { is_expected.to eq({}) }
      end

      context 'when cookie is set' do
        before do
          helper.request.cookies["hide_storage_limit_alert_#{namespace.id}_info"] = 'true'
        end

        it { is_expected.to eq({}) }
      end

      context 'when payload is empty and cookie is set' do
        let(:payload) { {} }

        before do
          helper.request.cookies["hide_storage_limit_alert_#{namespace.id}_info"] = 'true'
        end

        it { is_expected.to eq({}) }
      end
    end
  end

  describe '#namespace_storage_alert_style' do
    subject { helper.namespace_storage_alert_style(alert_level) }

    where(:alert_level, :result) do
      :info      | 'info'
      :warning   | 'warning'
      :error     | 'danger'
      :alert     | 'danger'
    end

    with_them do
      it { is_expected.to eq(result) }
    end
  end

  describe '#namespace_storage_alert_icon' do
    subject { helper.namespace_storage_alert_icon(alert_level) }

    where(:alert_level, :result) do
      :info      | 'information-o'
      :warning   | 'warning'
      :error     | 'error'
      :alert     | 'error'
    end

    with_them do
      it { is_expected.to eq(result) }
    end
  end

  describe '#can_purchase_storage_for_namespace?' do
    subject { helper.can_purchase_storage_for_namespace?(namespace) }

    let_it_be(:namespace) { build(:namespace) }

    where(:buy_storage_link_enabled, :additional_repo_storage_by_namespace_enabled, :result) do
      false | false | false
      false | true  | false
      true  | false | false
      true  | true  | true
    end

    with_them do
      before do
        stub_feature_flags(buy_storage_link: buy_storage_link_enabled)
        allow(namespace).to receive(:additional_repo_storage_by_namespace_enabled?)
          .and_return(additional_repo_storage_by_namespace_enabled)
      end

      it { is_expected.to eq(result) }
    end
  end
end
