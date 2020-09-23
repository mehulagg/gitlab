# frozen_string_literal: true

module Groups
  class CreateService < Groups::BaseService
    def initialize(user, params = {})
      @current_user, @params = user, params.dup
      @chat_team = @params.delete(:create_chat_team)
    end

    def execute
      remove_unallowed_params
      set_visibility_level

      @group = Group.new(params)

      after_build_hook(@group, params)

      unless can_use_visibility_level? && can_create_group?
        return @group
      end

      @group.name ||= @group.path.dup

      if create_chat_team?
        response = Mattermost::CreateTeamService.new(@group, current_user).execute
        return @group if @group.errors.any?

        @group.build_chat_team(name: response['name'], team_id: response['id'])
      end

      Group.transaction do
        if @group.save
          @group.add_owner(current_user)
          @group.create_namespace_settings
          create_services_from_active_default_integrations(@group)
        end
      end

      @group
    end

    private

    def after_build_hook(group, params)
      # overridden in EE
    end

    def remove_unallowed_params
      params.delete(:default_branch_protection) unless can?(current_user, :create_group_with_default_branch_protection)
    end

    def create_chat_team?
      Gitlab.config.mattermost.enabled && @chat_team && group.chat_team.nil?
    end

    def can_create_group?
      if @group.subgroup?
        unless can?(current_user, :create_subgroup, @group.parent)
          @group.parent = nil
          @group.errors.add(:parent_id, s_('CreateGroup|You don’t have permission to create a subgroup in this group.'))

          return false
        end
      else
        unless can?(current_user, :create_group)
          @group.errors.add(:base, s_('CreateGroup|You don’t have permission to create groups.'))

          return false
        end
      end

      true
    end

    def can_use_visibility_level?
      unless Gitlab::VisibilityLevel.allowed_for?(current_user, visibility_level)
        deny_visibility_level(@group)
        return false
      end

      true
    end

    def set_visibility_level
      return if visibility_level.present?

      params[:visibility_level] = Gitlab::CurrentSettings.current_application_settings.default_group_visibility
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def create_services_from_active_default_integrations(group)
      group_ids = group.ancestors.select(:id)

      Service.from_union([
        Service.active.where(instance: true),
        Service.active.where(group_id: group_ids)
      ]).order(by_type_group_ids_and_instance(group_ids)).group_by(&:type).each do |type, records|
        Service.build_from_integration(group.id, records.first, false).save!
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def by_type_group_ids_and_instance(group_ids)
      array = group_ids.to_sql.present? ? "array(#{group_ids.to_sql})" : 'ARRAY[]'

      Arel.sql("type ASC, array_position(#{array}::bigint[], services.group_id), instance DESC")
    end
  end
end

Groups::CreateService.prepend_if_ee('EE::Groups::CreateService')
