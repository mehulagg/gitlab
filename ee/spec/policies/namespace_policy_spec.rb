# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespacePolicy do
  let(:owner) { build_stubbed(:user) }
  let(:namespace) { build_stubbed(:namespace, owner: owner) }
  let(:owner_permissions) { [:create_projects, :admin_namespace, :read_namespace] }

  subject { described_class.new(current_user, namespace) }

  context 'auditor' do
    let(:current_user) { build_stubbed(:user, :auditor) }

    context 'owner' do
      let(:namespace) { build_stubbed(:namespace, owner: current_user) }

      it { is_expected.to be_allowed(*owner_permissions) }
    end

    context 'non-owner' do
      it { is_expected.to be_disallowed(*owner_permissions) }
    end
  end

  context 'custom_compliance_frameworks_enabled' do
    let(:current_user) { owner }

    context 'is licensed' do
      before do
        stub_licensed_features(custom_compliance_frameworks: true)
      end

      context 'current_user is namespace owner' do
        it { is_expected.to be_allowed(:create_custom_compliance_frameworks) }
      end

      context 'current_user is not namespace owner' do
        let(:current_user) { build_stubbed(:user) }

        it { is_expected.to be_disallowed(:create_custom_compliance_frameworks) }
      end

      context 'current_user is administrator', :enable_admin_mode do
        let(:current_user) { build_stubbed(:admin) }

        it { is_expected.to be_allowed(:create_custom_compliance_frameworks) }
      end
    end

    context 'not licensed' do
      before do
        stub_licensed_features(custom_compliance_frameworks: false)
      end

      it { is_expected.to be_disallowed(:create_custom_compliance_frameworks) }
    end
  end

  context ':over_storage_limit' do
    let(:current_user) { owner }

    before do
      allow(namespace).to receive(:over_storage_limit?).and_return(over_storage_limit)
    end

    context 'when the namespace has exceeded its storage limit' do
      let(:over_storage_limit) { true }

      it { is_expected.to(be_disallowed(:create_projects)) }
    end

    context 'when the namespace has not exceeded its storage limit' do
      let(:over_storage_limit) { false }

      it { is_expected.to(be_allowed(:create_projects)) }
    end
  end

  it_behaves_like 'update namespace limit policy'
end
