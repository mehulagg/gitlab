# frozen_string_literal: true

FactoryBot.define do
  factory :group_package_setting, class: 'GroupPackageSetting' do
    # Note: because of the group_id primary_key on
    # container_expiration_policies, and the create_group_package_setting
    # callback on Group, we need to build the group first before assigning
    # it to a group_package_setting.
    #
    # Also, if you wish to assign an existing group to a
    # group_package_setting, you will then have to destroy the group's
    # group_package_setting first.
    before(:create) do |group_package_setting|
      group_package_setting.group = build(:group) unless group_package_setting.group
    end

    maven_duplicates_allowed { true }
    maven_duplicate_exception_regex { 'SNAPSHOT' }
  end
end
