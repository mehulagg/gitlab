# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::FrameworkPolicy do
  let_it_be(:framework) { create(:compliance_framework) }
  let(:user) { framework.namespace.owner }

  subject { described_class.new(user, framework) }

  context 'feature is licensed' do
    before do
      stub_licensed_features(custom_compliance_frameworks: true)
    end

    context 'user is namespace owner' do
      it { is_expected.to be_allowed(:manage_compliance_framework) }
    end

    context 'user is group owner' do
      let_it_be(:group) { create(:group) }
      let_it_be(:framework) { create(:compliance_framework, namespace: group) }
      let_it_be(:user) { create(:user) }

      before do
        group.add_owner(user)
      end

      it { is_expected.to be_allowed(:manage_compliance_framework) }
    end

    context 'user is not namespace owner' do
      let(:user) { build(:user) }

      it { is_expected.to be_disallowed(:manage_compliance_framework) }
    end

    context 'user is an admin', :enable_admin_mode do
      let(:user) { build(:admin) }

      it { is_expected.to be_allowed(:manage_compliance_framework) }
    end
  end

  context 'feature is unlicensed' do
    before do
      stub_licensed_features(custom_compliance_frameworks: false)
    end

    it { is_expected.to be_disallowed(:manage_compliance_framework) }
  end

  context 'feature is disabled' do
    before do
      stub_feature_flags(ff_custom_compliance_framework: false)
    end

    it { is_expected.to be_disallowed(:manage_compliance_framework) }
  end
end
