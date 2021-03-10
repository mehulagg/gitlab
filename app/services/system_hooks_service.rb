# frozen_string_literal: true

class SystemHooksService
  BUILDER_DRIVEN_EVENT_DATA_AVAILABLE_FOR_CLASSES = [GroupMember, Group, ProjectMember, User].freeze

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

    data
  end

  def build_event_name(model, event)
    "#{model.class.name.downcase}_#{event}"
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

  def builder_driven_event_data_available?(model)
    model.class.in?(BUILDER_DRIVEN_EVENT_DATA_AVAILABLE_FOR_CLASSES)
  end

  def builder_driven_event_data(model, event)
    builder_class = case model
                    when GroupMember
                      Gitlab::HookData::GroupMemberBuilder
                    when Group
                      Gitlab::HookData::GroupBuilder
                    when ProjectMember
                      Gitlab::HookData::ProjectMemberBuilder
                    when User
                      Gitlab::HookData::UserBuilder
                    end

    builder_class.new(model).build(event)
  end
end

SystemHooksService.prepend_if_ee('EE::SystemHooksService')
