# frozen_string_literal: true

class UserGroupNotificationSettingsFinder
  def initialize(user, groups)
    @user = user
    @groups = groups
  end

  def execute
    groups_with_ancestors = Gitlab::ObjectHierarchy.new(groups).base_and_ancestors

    @loaded_groups_with_ancestors = groups_with_ancestors.index_by(&:id)
    @loaded_notification_settings = user.notification_settings_for_groups(groups_with_ancestors).preload_source_route.index_by(&:source_id)

    groups.map do |group|
      find_notification_setting_for(group)
    end
  end

  private

  attr_reader :user, :groups, :loaded_groups_with_ancestors, :loaded_notification_settings

  def find_notification_setting_for(group)
    return loaded_notification_settings[group.id] if loaded_notification_settings[group.id]
    return user.notification_settings.build(source: group) if group.parent_id.nil?

    parent_setting = loaded_notification_settings[group.parent_id]

    if should_copy?(parent_setting)
      user.notification_settings.build(source: group) do |ns|
        ns.assign_attributes(parent_setting.slice(*NotificationSetting.allowed_fields))
      end
    else
      find_notification_setting_for(loaded_groups_with_ancestors[group.parent_id])
    end
  end

  def should_copy?(parent_setting)
    return false unless parent_setting

    parent_setting.level != NotificationSetting.levels[:global] || parent_setting.notification_email.present?
  end
end
