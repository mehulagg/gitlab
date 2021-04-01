# frozen_string_literal: true

class UserGroupNotificationSettingsFinder
  def initialize(user, groups)
    @user = user
    @groups = groups
  end

  def execute
    # rubocop: disable CodeReuse/ActiveRecord
    groups_with_ancestors = Gitlab::ObjectHierarchy.new(Group.where(id: groups.select(:id))).base_and_ancestors
    # rubocop: enable CodeReuse/ActiveRecord

    @loaded_groups_with_ancestors = groups_with_ancestors.index_by(&:id)
    @loaded_notification_settings = user.notification_settings_for_groups(groups_with_ancestors).preload_source_route.index_by(&:source_id)

    preload_emails_disabled

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

    return user.notification_settings.build(source: group) unless parent_setting

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

  # This method preloads the `emails_disabled` strong memoized method for the given groups.
  #
  # For each group, look up the ancestor hierarchy and look for any group where emails_disabled is true.
  # The lookup is implemented as a LATERAL JOIN, so we can look up the ancestor chain for each group individually.
  # The query will return groups where at least one ancestor has the `emails_disabled` set to true.
  #
  # After the query, we set the instance variable.
  # rubocop: disable CodeReuse/ActiveRecord
  def preload_emails_disabled
    innner_query = Gitlab::ObjectHierarchy
      .new(Group.where('id = namespaces_with_emails_disabled.id'))
      .base_and_ancestors
      .where(emails_disabled: true)
      .select('1')
      .limit(1)
      .to_sql

    group_ids = Group
      .from('(SELECT * FROM namespaces) as namespaces_with_emails_disabled')
      .joins("INNER JOIN LATERAL (#{innner_query}) tbl ON TRUE")
      .where(namespaces_with_emails_disabled: { id: groups.to_a })
      .unscope(where: :type)
      .pluck(:id)

    group_ids_with_disabled_email = Set.new(group_ids)

    groups.each do |group|
      group.instance_variable_set("@emails_disabled", group_ids_with_disabled_email.include?(group.id)) if group.parent_id
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
