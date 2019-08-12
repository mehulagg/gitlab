# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module EpicActions
        extend ActiveSupport::Concern
        include ::Gitlab::QuickActions::Dsl

        included do
          desc _('Add child epic to an epic')
          explanation do |epic_param|
            child_epic = extract_epic(epic_param)

            _("Adds %{epic_ref} as child epic.") % { epic_ref: child_epic.to_reference(quick_action_target) } if child_epic
          end
          types Epic
          condition { action_allowed? }
          params '<&epic | group&epic | Epic URL>'
          command :child_epic do |epic_param|
            child_epic = extract_epic(epic_param)

            if child_epic && !quick_action_target.child?(child_epic.id)
              EpicLinks::CreateService.new(quick_action_target, current_user, { target_issuable: child_epic }).execute
              @execution_message[:child_epic] = _("Added %{epic_ref} as child epic.") % { epic_ref: child_epic.to_reference(quick_action_target) }
            end
          end

          desc _('Remove child epic from an epic')
          explanation do |epic_param|
            child_epic = extract_epic(epic_param)

            _("Removes %{epic_ref} from child epics.") % { epic_ref: child_epic.to_reference(quick_action_target) }
          end
          types Epic
          condition { action_allowed? }
          params '<&epic | group&epic | Epic URL>'
          command :remove_child_epic do |epic_param|
            child_epic = extract_epic(epic_param)

            if child_epic && quick_action_target.child?(child_epic.id)
              EpicLinks::DestroyService.new(child_epic, current_user).execute
              @execution_message[:remove_child_epic] = _("Removed %{epic_ref} from child epics.") % { epic_ref: child_epic.to_reference(quick_action_target) }
            end
          end

          desc _('Set parent epic to an epic')
          explanation do |epic_param|
            parent_epic = extract_epic(epic_param)

            _("Sets %{epic_ref} as parent epic.") % { epic_ref: parent_epic.to_reference(quick_action_target) } if parent_epic
          end
          types Epic
          condition { action_allowed? }
          params '<&epic | group&epic | Epic URL>'
          command :parent_epic do |epic_param|
            parent_epic = extract_epic(epic_param)

            if parent_epic && !parent_epic.child?(quick_action_target.id)
              EpicLinks::CreateService.new(parent_epic, current_user, { target_issuable: quick_action_target }).execute
              @execution_message[:parent_epic] = _("Set %{epic_ref} as parent epic.") % { epic_ref: parent_epic.to_reference(quick_action_target) }
            end
          end

          desc _('Remove parent epic from an epic')
          explanation do
            parent_epic = quick_action_target.parent

            _('Removes parent epic %{epic_ref}.') % { epic_ref: parent_epic.to_reference(quick_action_target) }
          end
          types Epic
          condition do
            action_allowed? && quick_action_target.parent.present?
          end
          command :remove_parent_epic do
            parent_epic = quick_action_target.parent
            EpicLinks::DestroyService.new(quick_action_target, current_user).execute
            @execution_message[:remove_parent_epic] = _('Removed parent epic %{epic_ref}.') % { epic_ref: parent_epic.to_reference(quick_action_target) }
          end

          desc _('Move this epic to another group.')
          explanation do |target_group_path|
            _("Moves this epic to %{target_group_path}.") % { target_group_path: target_group_path }
          end
          params 'path/to/group'
          types Epic
          condition { ::Feature.enabled?(:move_epic_quick_action) && action_allowed? }
          command :move do |target_group_path|
            begin
              Epics::MoveService.new(quick_action_target, current_user).execute(target_group_path)
              @execution_message[:move] = _("Epic was moved to %{path_to_group}.") % { path_to_group: target_group_path }
            rescue Epics::MoveService::MoveError => error
              @execution_message[:move] = error.message
            end
          end

          private

          def extract_epic(params)
            return if params.nil?

            extract_references(params, :epic).first
          end

          def action_allowed?
            quick_action_target.group&.feature_available?(:epics) &&
              current_user.can?(:"admin_#{quick_action_target.to_ability_name}", quick_action_target)
          end
        end
      end
    end
  end
end
