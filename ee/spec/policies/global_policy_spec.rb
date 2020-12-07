# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GlobalPolicy do
  include ExternalAuthorizationServiceHelpers

  let_it_be(:admin) { create(:admin) }

  let(:current_user) { create(:user) }
  let(:user) { create(:user) }

  subject { described_class.new(current_user, [user]) }

  describe 'reading operations dashboard' do
    context 'when licensed' do
      before do
        stub_licensed_features(operations_dashboard: true)
      end

      it { is_expected.to be_allowed(:read_operations_dashboard) }

      context 'and the user is not logged in' do
        let(:current_user) { nil }

        it { is_expected.not_to be_allowed(:read_operations_dashboard) }
      end
    end

    context 'when unlicensed' do
      before do
        stub_licensed_features(operations_dashboard: false)
      end

      it { is_expected.not_to be_allowed(:read_operations_dashboard) }
    end
  end

  it { is_expected.to be_disallowed(:read_licenses) }
  it { is_expected.to be_disallowed(:destroy_licenses) }
  it { is_expected.to be_disallowed(:read_all_geo) }

  context 'when admin mode enabled', :enable_admin_mode do
    it { expect(described_class.new(admin, [user])).to be_allowed(:read_licenses) }
    it { expect(described_class.new(admin, [user])).to be_allowed(:destroy_licenses) }
    it { expect(described_class.new(admin, [user])).to be_allowed(:read_all_geo) }
  end

  context 'when admin mode disabled' do
    it { expect(described_class.new(admin, [user])).to be_disallowed(:read_licenses) }
    it { expect(described_class.new(admin, [user])).to be_disallowed(:destroy_licenses) }
    it { expect(described_class.new(admin, [user])).to be_disallowed(:read_all_geo) }
  end

  shared_examples 'analytics policy' do |action|
    context 'anonymous user' do
      let(:current_user) { nil }

      it 'is not allowed' do
        is_expected.not_to be_allowed(action)
      end
    end

    context 'authenticated user' do
      it 'is allowed' do
        is_expected.to be_allowed(action)
      end
    end
  end

  describe 'view_productivity_analytics' do
    include_examples 'analytics policy', :view_productivity_analytics
  end

  describe 'update_max_pages_size' do
    context 'when feature is enabled' do
      before do
        stub_licensed_features(pages_size_limit: true)
      end

      it { is_expected.to be_disallowed(:update_max_pages_size) }

      context 'when admin mode enabled', :enable_admin_mode do
        it { expect(described_class.new(admin, [user])).to be_allowed(:update_max_pages_size) }
      end

      context 'when admin mode disabled' do
        it { expect(described_class.new(admin, [user])).to be_disallowed(:update_max_pages_size) }
      end
    end

    it { expect(described_class.new(admin, [user])).to be_disallowed(:update_max_pages_size) }
  end

  describe 'create_group_with_default_branch_protection' do
    context 'for an admin' do
      let(:current_user) { admin }

      context 'when the `default_branch_protection_restriction_in_groups` feature is available' do
        before do
          stub_licensed_features(default_branch_protection_restriction_in_groups: true)
        end

        context 'when the setting `group_owners_can_manage_default_branch_protection` is enabled' do
          before do
            stub_ee_application_setting(group_owners_can_manage_default_branch_protection: true)
          end

          it { is_expected.to be_allowed(:create_group_with_default_branch_protection) }
        end

        context 'when the setting `group_owners_can_manage_default_branch_protection` is disabled' do
          before do
            stub_ee_application_setting(group_owners_can_manage_default_branch_protection: false)
          end

          context 'when admin mode is enabled', :enable_admin_mode do
            it { is_expected.to be_allowed(:create_group_with_default_branch_protection) }
          end

          context 'when admin mode is disabled' do
            it { is_expected.to be_disallowed(:create_group_with_default_branch_protection) }
          end
        end
      end

      context 'when the `default_branch_protection_restriction_in_groups` feature is not available' do
        before do
          stub_licensed_features(default_branch_protection_restriction_in_groups: false)
        end

        context 'when the setting `group_owners_can_manage_default_branch_protection` is enabled' do
          before do
            stub_ee_application_setting(group_owners_can_manage_default_branch_protection: true)
          end

          it { is_expected.to be_allowed(:create_group_with_default_branch_protection) }
        end

        context 'when the setting `group_owners_can_manage_default_branch_protection` is disabled' do
          before do
            stub_ee_application_setting(group_owners_can_manage_default_branch_protection: false)
          end

          it { is_expected.to be_allowed(:create_group_with_default_branch_protection) }
        end
      end
    end

    context 'for a normal user' do
      let(:current_user) { create(:user) }

      context 'when the `default_branch_protection_restriction_in_groups` feature is available' do
        before do
          stub_licensed_features(default_branch_protection_restriction_in_groups: true)
        end

        context 'when the setting `group_owners_can_manage_default_branch_protection` is enabled' do
          before do
            stub_ee_application_setting(group_owners_can_manage_default_branch_protection: true)
          end

          it { is_expected.to be_allowed(:create_group_with_default_branch_protection) }
        end

        context 'when the setting `group_owners_can_manage_default_branch_protection` is disabled' do
          before do
            stub_ee_application_setting(group_owners_can_manage_default_branch_protection: false)
          end

          it { is_expected.to be_disallowed(:create_group_with_default_branch_protection) }
        end
      end

      context 'when the `default_branch_protection_restriction_in_groups` feature is not available' do
        before do
          stub_licensed_features(default_branch_protection_restriction_in_groups: false)
        end

        context 'when the setting `group_owners_can_manage_default_branch_protection` is enabled' do
          before do
            stub_ee_application_setting(group_owners_can_manage_default_branch_protection: true)
          end

          it { is_expected.to be_allowed(:create_group_with_default_branch_protection) }
        end

        context 'when the setting `group_owners_can_manage_default_branch_protection` is disabled' do
          before do
            stub_ee_application_setting(group_owners_can_manage_default_branch_protection: false)
          end

          it { is_expected.to be_allowed(:create_group_with_default_branch_protection) }
        end
      end
    end
  end

  describe 'list_removable_projects' do
    context 'when user is an admin', :enable_admin_mode do
      let_it_be(:current_user) { admin }

      before do
        stub_licensed_features(adjourned_deletion_for_projects_and_groups: licensed?)
      end

      context 'when licensed feature is enabled' do
        let(:licensed?) { true }

        it { is_expected.to be_allowed(:list_removable_projects) }
      end

      context 'when licensed feature is enabled' do
        let(:licensed?) { false }

        it { is_expected.to be_disallowed(:list_removable_projects) }
      end
    end

    context 'when user is a normal user' do
      let_it_be(:current_user) { create(:user) }

      before do
        stub_licensed_features(adjourned_deletion_for_projects_and_groups: licensed?)
      end

      context 'when licensed feature is enabled' do
        let(:licensed?) { true }

        it { is_expected.to be_disallowed(:list_removable_projects) }
      end

      context 'when licensed feature is enabled' do
        let(:licensed?) { false }

        it { is_expected.to be_disallowed(:list_removable_projects) }
      end
    end
  end

  describe 'export_user_permissions' do
    let(:licensed) { true }
    let(:flag_enabled) { true }

    shared_examples 'allowed to export user permissions' do
      it { is_expected.to be_allowed(:export_user_permissions) }
    end

    shared_examples 'not allowed to export user permissions' do
      it { is_expected.to be_disallowed(:export_user_permissions) }
    end

    before do
      stub_licensed_features(export_user_permissions: licensed)
      stub_feature_flags(export_user_permissions_feature_flag: flag_enabled)
    end

    context 'when user is an admin', :enable_admin_mode do
      let(:current_user) { admin }

      context 'when licensed and feature enabled' do
        it_behaves_like 'allowed to export user permissions'
      end

      context 'when not licensed' do
        let(:licensed) { false }

        it_behaves_like 'not allowed to export user permissions'
      end

      context 'when feature flag is not enabled' do
        let(:flag_enabled) { false }

        it_behaves_like 'not allowed to export user permissions'
      end
    end

    context 'when user is not an admin' do
      let(:current_user) { user }

      context 'when licensed' do
        it_behaves_like 'not allowed to export user permissions'
      end

      context 'when not licensed' do
        let(:licensed) { false }

        it_behaves_like 'not allowed to export user permissions'
      end
    end
  end
end
