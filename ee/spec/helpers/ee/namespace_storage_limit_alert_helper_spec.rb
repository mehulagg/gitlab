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

    where(:is_dot_com, :enforcement_setting_enabled, :feature_enabled, :result) do
      false | false | false | nil
      false | false | true  | nil
      false | true  | false | nil
      true  | false | false | nil
      false | true  | true  | nil
      true  | true  | false | nil
      true  | false | true  | nil
      true  | true  | true  | EE::SUBSCRIPTIONS_MORE_STORAGE_URL
    end

    with_them do
      before do
        allow(::Gitlab).to receive(:com?).and_return(is_dot_com)
        stub_application_setting(enforce_namespace_storage_limit: enforcement_setting_enabled)
        stub_feature_flags(buy_storage_link: feature_enabled)
      end

      it { is_expected.to eq(result) }
    end
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

    where(:namespace_storage_limit_enabled, :additional_repo_storage_by_namespace_enabled, :service_class_name) do
      true  | false | Namespaces::CheckStorageSizeService
      true  | true  | Namespaces::CheckStorageSizeService
      false | true  | Namespaces::CheckExcessStorageSizeService
      false | false | Namespaces::CheckStorageSizeService
    end

    with_them do
      before do
        stub_feature_flags(namespace_storage_limit: namespace_storage_limit_enabled)
        stub_feature_flags(additional_repo_storage_by_namespace: additional_repo_storage_by_namespace_enabled)

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

  describe '#namespace_storage_purchase_link' do
    subject { helper.namespace_storage_purchase_link(namespace) }

    let(:namespace) { build(:namespace) }

    where(:is_dev_or_com, :auto_storage_allocation_enabled, :buy_storage_link_enabled, :additional_storage_enabled, :result) do
      true  | true  | true  | true  | EE::SUBSCRIPTIONS_MORE_STORAGE_URL
      true  | true  | true  | false | nil
      true  | true  | false | true  | nil
      true  | true  | false | false | nil
      true  | false | true  | true  | nil
      true  | false | true  | false | nil
      true  | false | false | true  | nil
      true  | false | false | false | nil
      false | true  | true  | true  | nil
      false | true  | true  | false | nil
      false | true  | false | true  | nil
      false | true  | false | false | nil
      false | false | true  | true  | nil
      false | false | true  | false | nil
      false | false | false | true  | nil
      false | false | false | false | nil
    end

    with_them do
      before do
        allow(::Gitlab).to receive(:dev_env_or_com?).and_return(is_dev_or_com)
        stub_application_setting(automatic_purchased_storage_allocation: auto_storage_allocation_enabled)
        stub_feature_flags(additional_repo_storage_by_namespace: additional_storage_enabled)
        stub_feature_flags(buy_storage_link: buy_storage_link_enabled)
      end

      it { is_expected.to eq(result) }
    end
  end
end
