# frozen_string_literal: true

class SystemHooksService
  BUILDER_DRIVEN_EVENT_DATA_AVAILABLE_FOR_CLASSES = [GroupMember, Group].freeze

  def execute_hooks_for(model, event)
    data = build_event_data(model, event)

    model.run_after_commit_or_now do
      SystemHooksService.new.execute_hooks(data)
    end
  end

  def execute_hooks(data, hooks_scope = :all)
    SystemHook.hooks_for(hooks_scope).find_each do |hook|
      hook.async_execute(data, 'system_hooks')
    end

    Gitlab::FileHook.execute_all_async(data)
  end

  private

  def build_event_data(model, event)
    # return entire event data from its builder class, if available.
    return builder_driven_event_data(model, event) if builder_driven_event_data_available?(model)

    data = {
      event_name: build_event_name(model, event),
      created_at: model.created_at&.xmlschema,
      updated_at: model.updated_at&.xmlschema
    }

    case model
    when Key
      data.merge!(
        key: model.key,
        id: model.id
      )

      if model.user
        data[:username] = model.user.username
      end
    when Project
      data.merge!(project_data(model))

      if event == :rename || event == :transfer
        data[:old_path_with_namespace] = model.old_path_with_namespace
      end
    when User
      data.merge!(user_data(model))

      case event
      when :rename
        data[:old_username] = model.username_before_last_save
      when :failed_login
        data[:state] = model.state
      end
    when ProjectMember
      data.merge!(project_member_data(model))
    end

    data
  end

  def build_event_name(model, event)
    case model
    when ProjectMember
      return "user_add_to_team"      if event == :create
      return "user_remove_from_team" if event == :destroy
      return "user_update_for_team"  if event == :update
    else
      "#{model.class.name.downcase}_#{event}"
    end
  end

  def project_data(model)
    owner = model.owner

    {
      name: model.name,
      path: model.path,
      path_with_namespace: model.full_path,
      project_id: model.id,
      owner_name: owner.name,
      owner_email: owner.respond_to?(:email) ? owner.email : "",
      project_visibility: model.visibility.downcase
    }
  end

  def project_member_data(model)
    project = model.project || Project.unscoped.find(model.source_id)

    {
      project_name:                 project.name,
      project_path:                 project.path,
      project_path_with_namespace:  project.full_path,
      project_id:                   project.id,
      user_username:                model.user.username,
      user_name:                    model.user.name,
      user_email:                   model.user.email,
      user_id:                      model.user.id,
      access_level:                 model.human_access,
      project_visibility:           Project.visibility_levels.key(project.visibility_level_value).downcase
    }
  end

  def user_data(model)
    {
      name: model.name,
      email: model.email,
      user_id: model.id,
      username: model.username
    }
  end

  def builder_driven_event_data_available?(model)
    model.class.in?(BUILDER_DRIVEN_EVENT_DATA_AVAILABLE_FOR_CLASSES)
  end

  def builder_driven_event_data(model, event)
    builder_class = case model
                    when GroupMember
                      Gitlab::HookData::GroupMemberBuilder
                    when Group
                      Gitlab::HookData::GroupBuilder
                    end

    builder_class.new(model).build(event)
  end
end

SystemHooksService.prepend_if_ee('EE::SystemHooksService')
