# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::FrameworkPolicy do
  let_it_be_with_refind(:framework) { create(:compliance_framework) }

  let(:user) { framework.namespace.owner }

  subject { described_class.new(user, framework) }

  context 'feature is licensed' do
    before do
      stub_licensed_features(custom_compliance_frameworks: true, evaluate_group_level_compliance_pipeline: true)
    end

    context 'user is namespace owner' do
      it { is_expected.to be_allowed(:manage_compliance_framework) }
      it { is_expected.to be_allowed(:manage_group_level_compliance_pipeline_config) }
    end

    context 'user is group owner' do
      let_it_be(:group) { create(:group) }
      let_it_be(:framework) { create(:compliance_framework, namespace: group) }
      let_it_be(:user) { create(:user) }

      before do
        group.add_owner(user)
      end

      it { is_expected.to be_allowed(:manage_compliance_framework) }
      it { is_expected.to be_allowed(:manage_group_level_compliance_pipeline_config) }
    end

    context 'user is not namespace owner' do
      let(:user) { build(:user) }

      it { is_expected.to be_disallowed(:manage_compliance_framework) }
      it { is_expected.to be_disallowed(:manage_group_level_compliance_pipeline_config) }
    end

    context 'user is an admin', :enable_admin_mode do
      let(:user) { build(:admin) }

      it { is_expected.to be_allowed(:manage_compliance_framework) }
      it { is_expected.to be_allowed(:manage_group_level_compliance_pipeline_config) }
    end
  end

  context 'feature is unlicensed' do
    before do
      stub_licensed_features(custom_compliance_frameworks: false, evaluate_group_level_compliance_pipeline: false)
    end

    it { is_expected.to be_disallowed(:manage_compliance_framework) }
    it { is_expected.to be_disallowed(:manage_group_level_compliance_pipeline_config) }
  end
end
